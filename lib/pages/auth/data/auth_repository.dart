import 'package:mmsn/app/services/device_service.dart';
import 'package:mmsn/models/user.dart';
import 'package:mmsn/models/token_model.dart';
import 'package:mmsn/models/exceptions.dart';
import 'package:mmsn/models/api_response.dart';
import 'package:mmsn/pages/auth/services/auth_service.dart';
import 'package:mmsn/pages/auth/storage/auth_local_storage.dart';

enum UserExistsStatus {
  existsWithPinVerified,     // Has PIN and phone is verified
  existsWithPinNotVerified,  // Has PIN but phone not verified
  existsWithoutPin,          // No PIN set
  doesNotExist,              // User not registered
}

class CheckUserResult {
  final UserExistsStatus status;
  final User? user;

  CheckUserResult({required this.status, this.user});
}

class AuthRepository {
  final AuthApiService _api = AuthApiService.instance;

  // ==================== Check User ====================

  Future<CheckUserResult> checkUser(String mobile) async {
    try {
      final response = await _api.checkUser(mobile);
      final responseData = response.data as Map<String, dynamic>?;

      if (responseData == null) {
        return CheckUserResult(status: UserExistsStatus.doesNotExist);
      }

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        responseData,
        (data) => data as Map<String, dynamic>,
      );

      if (!apiResponse.isSuccess || apiResponse.data == null) {
        return CheckUserResult(status: UserExistsStatus.doesNotExist);
      }

      final userData = apiResponse.data!;
      final user = User.fromJson(userData);

      // Save OTP session if exists
      final otpSession = userData["otpSession"];
      if (otpSession != null && otpSession.toString().isNotEmpty) {
        await AuthLocalStorage.saveOtpVerificationToken(otpSession.toString());
        print("✓ OTP session saved");
      }

      // Check if user has PIN/password
      final password = userData["password"];
      final hasPassword = password != null && password.toString().isNotEmpty;
      final hasPin = hasPassword ||
          userData["hasPin"] == true ||
          userData["has_pin"] == true ||
          (user.pin != null && user.pin!.isNotEmpty);

      // Check if phone is verified
      // Use the mobileVerification field from API
      final mobileVerification = userData["mobileVerification"]?.toString()?.toUpperCase() ??
          userData["mobile_verification"]?.toString()?.toUpperCase() ?? '';
      final isPhoneVerified = mobileVerification == 'ACCEPTED' || user.isPhoneVerified;

      if (!hasPin) {
        // User exists but has no PIN
        return CheckUserResult(
          status: UserExistsStatus.existsWithoutPin,
          user: user,
        );
      }

      if (isPhoneVerified) {
        // User has PIN and phone is verified - can login directly
        return CheckUserResult(
          status: UserExistsStatus.existsWithPinVerified,
          user: user,
        );
      } else {
        // User has PIN but phone not verified - needs OTP verification first
        return CheckUserResult(
          status: UserExistsStatus.existsWithPinNotVerified,
          user: user,
        );
      }
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        return CheckUserResult(status: UserExistsStatus.doesNotExist);
      }
      rethrow;
    } catch (e) {
      return CheckUserResult(status: UserExistsStatus.doesNotExist);
    }
  }

  // ==================== Login ====================

  Future<User> login(
    String mobile,
    String password,
    String deviceId,
    String deviceToken,
  ) async {
    try {
      final response = await _api.login(mobile, password, deviceId, deviceToken);
      final responseData = response.data as Map<String, dynamic>?;

      if (responseData == null) {
        throw AuthenticationException('Invalid response from server');
      }

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        responseData,
        (data) => data as Map<String, dynamic>,
      );

      if (apiResponse.isSuccess && apiResponse.data != null) {
        final data = apiResponse.data!;
        final userData = data['user'] as Map<String, dynamic>? ?? data;
        final user = User.fromJson(userData);
        final tokens = TokenModel.fromJson(data);

        if (tokens.accessToken.isEmpty || tokens.refreshToken.isEmpty) {
          throw AuthenticationException('Token data is missing');
        }

        await AuthLocalStorage.saveTokens(
            tokens.accessToken, tokens.refreshToken);
        await AuthLocalStorage.saveUser(user);
        _api.updateCurrentUser(user);

        print('✓ Login successful');
        return user;
      } else {
        throw AuthenticationException(apiResponse.message ?? 'Login failed');
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw AuthenticationException(
        'Login failed: ${e.toString()}',
        originalError: e,
      );
    }
  }

  // ==================== Send OTP ====================

  Future<void> sendOtp(String mobile, {bool isReset = false}) async {
    try {
      final response = await _api.sendOtp(mobile, isReset: isReset);
      final responseData = response.data as Map<String, dynamic>?;

      if (responseData == null) {
        throw ApiException('Invalid response from server');
      }

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        responseData,
        (data) => data as Map<String, dynamic>,
      );

      if (apiResponse.isSuccess) {
        print('✓ OTP sent successfully${isReset ? ' (for PIN setup)' : ''}');
      } else {
        throw ApiException(apiResponse.message ?? 'Failed to send OTP');
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        'Failed to send OTP: ${e.toString()}',
        originalError: e,
      );
    }
  }

  // ==================== Verify OTP ====================

  Future<Map<String, dynamic>?> verifyOtp(
    String otp, {
    bool includeTokens = true,
  }) async {
    try {
      final otpToken = await AuthLocalStorage.getOtpVerificationToken();
      final resetToken = await AuthLocalStorage.getPasswordResetToken();

      // Use whichever token is available
      final sessionToken = resetToken ?? otpToken;

      if (sessionToken == null || sessionToken.isEmpty) {
        throw AuthenticationException(
            "OTP session expired. Please request new OTP.");
      }

      print("🔐 Using token for verification: ${sessionToken.substring(0, 20)}...");

      final response = await _api.verifyOtp(
        otp,
        sessionToken,
        includeTokens: includeTokens,
      );

      final res = response.data as Map<String, dynamic>?;
      if (res == null || res["status"] != true) {
        throw AuthenticationException("Invalid OTP");
      }

      print("✓ OTP verified successfully");
      return res["data"];
    } catch (e) {
      throw AuthenticationException("OTP verification failed: $e");
    }
  }

  // ==================== Set PIN ====================

  Future<User> setPin(String mobile, String pin) async {
    try {
      print('🔑 Setting PIN using password reset token');
      
      final response = await _api.resetPassword(
        // mobile: mobile,
        newPassword: pin,
      );

      final responseData = response.data as Map<String, dynamic>?;

      if (responseData == null) {
        throw AuthenticationException('Invalid response from server');
      }

      final apiResponse = ApiResponse.fromJson(responseData, null);

      if (!apiResponse.isSuccess) {
        throw AuthenticationException(
            apiResponse.message ?? 'Failed to set PIN');
      }

      // After setting PIN, login the user
      final deviceId = DeviceService.instance.deviceId;
      final deviceToken = DeviceService.instance.deviceToken;

      if (deviceId == null || deviceToken == null) {
        throw AuthenticationException("Device details not ready");
      }

      final user = await login(mobile, pin, deviceId, deviceToken);
      print('✓ PIN set and user logged in');
      return user;
    } on ApiException {
      rethrow;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw AuthenticationException(
        'Failed to set PIN: ${e.toString()}',
        originalError: e,
      );
    }
  }

  // ==================== Register ====================

  Future<User> register(Map<String, dynamic> userData) async {
    try {
      final response = await _api.register(userData);
      final responseData = response.data as Map<String, dynamic>?;

      if (responseData == null) {
        throw ApiException('Invalid response from server');
      }

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        responseData,
        (data) => data as Map<String, dynamic>,
      );

      if (apiResponse.isSuccess && apiResponse.data != null) {
        final data = apiResponse.data!;

        // Save OTP verification token from registration
        final otpToken = data['tokens']?['otpVerificationToken']?['token'];
        if (otpToken != null && otpToken.toString().isNotEmpty) {
          await AuthLocalStorage.saveOtpVerificationToken(otpToken.toString());
          print('✓ OTP verification token saved from registration');
        }

        final userDataFromResponse =
            data['user'] as Map<String, dynamic>? ?? data;
        final user = User.fromJson(userDataFromResponse);

        print('✓ User registered successfully');
        return user;
      } else {
        throw ValidationException(
          apiResponse.message ?? 'Registration failed',
          errors: apiResponse.errors,
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        'Registration failed: ${e.toString()}',
        originalError: e,
      );
    }
  }

  // ==================== Login After Registration ====================

  Future<User> loginAfterRegistration(String mobile, String pin) async {
    final deviceId = DeviceService.instance.deviceId;
    final deviceToken = DeviceService.instance.deviceToken;

    if (deviceId == null || deviceToken == null) {
      throw AuthenticationException("Device details not ready");
    }

    return await login(mobile, pin, deviceId, deviceToken);
  }

  // ==================== Change Password ====================

  Future<void> changePassword(String oldPassword, String newPassword) async {
    try {
      final response = await _api.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );

      final data = response.data as Map?;

      if (data == null || data['status'] != true) {
        throw ApiException(data?['message'] ?? "Failed to change password");
      }

      print('✓ Password changed successfully');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException("Failed to change password: ${e.toString()}");
    }
  }

  // ==================== Logout ====================

  Future<void> logout() async {
    try {
      await _api.logout();
    } catch (e) {
      print('Logout error: $e');
    } finally {
      await AuthLocalStorage.clear();
      _api.clearCurrentUser();
      print('✓ Logged out successfully');
    }
  }

  // ==================== Get Current User ====================

  Future<User?> getCurrentUser() async {
    return await AuthLocalStorage.getUser();
  }

  // ==================== Refresh Token ====================

  Future<void> refreshAccessToken() async {
    try {
      final refreshToken = await AuthLocalStorage.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        throw AuthenticationException('No refresh token available');
      }

      await _api.refreshToken(refreshToken);
      print('✓ Access token refreshed');
    } on ApiException {
      rethrow;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw AuthenticationException(
        'Failed to refresh token: ${e.toString()}',
        originalError: e,
      );
    }
  }
}