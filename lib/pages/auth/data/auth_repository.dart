// lib/pages/auth/data/auth_repository.dart
import 'package:mmsn/app/services/device_service.dart';
import 'package:mmsn/models/user.dart';
import 'package:mmsn/models/token_model.dart';
import 'package:mmsn/models/exceptions.dart';
import 'package:mmsn/models/api_response.dart';
import 'package:mmsn/pages/auth/services/auth_service.dart';
import 'package:mmsn/pages/auth/storage/auth_local_storage.dart';

enum UserExistsStatus {
  existsWithPin,
  existsWithoutPin,
  doesNotExist,
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

      // No user found
      if (!apiResponse.isSuccess || apiResponse.data == null) {
        return CheckUserResult(status: UserExistsStatus.doesNotExist);
      }

      final userData = apiResponse.data!;

      // Safely parse user model (your class)
      final user = User.fromJson(userData);

      // Save OTP session IF it exists (only in auth users)
      final otpSession = userData["otpSession"];
      if (otpSession != null && otpSession.toString().isNotEmpty) {
        await AuthLocalStorage.saveOtpVerificationToken(otpSession.toString());
        print("✓ OTP session saved");
      }

      // Logic: User exists → does he have PIN/password?
      final password = userData["password"];
      final hasPassword = password != null && password.toString().isNotEmpty;

      final hasPin = hasPassword ||
          userData["hasPin"] == true ||
          userData["has_pin"] == true ||
          (user.pin != null && user.pin!.isNotEmpty);

      // CASE 1 → User exists WITH PIN
      if (hasPin) {
        return CheckUserResult(
          status: UserExistsStatus.existsWithPin,
          user: user,
        );
      }

      // CASE 2 → User exists WITHOUT PIN
      return CheckUserResult(
        status: UserExistsStatus.existsWithoutPin,
        user: user,
      );
    }

    // API 404 → User does not exist
    on ApiException catch (e) {
      if (e.statusCode == 404) {
        return CheckUserResult(status: UserExistsStatus.doesNotExist);
      }
      rethrow;
    }

    // Any other error → treat as does not exist
    catch (e) {
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
      final response =
          await _api.login(mobile, password, deviceId, deviceToken);
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

        // Extract user
        final userData = data['user'] as Map<String, dynamic>? ?? data;
        final user = User.fromJson(userData);

        // Extract tokens
        final tokens = TokenModel.fromJson(data);

        if (tokens.accessToken.isEmpty || tokens.refreshToken.isEmpty) {
          throw AuthenticationException('Token data is missing');
        }

        // Save tokens and user
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

  Future<void> sendOtp(String mobile) async {
    try {
      final response = await _api.sendOtp(mobile);
      final responseData = response.data as Map<String, dynamic>?;

      if (responseData == null) {
        throw ApiException('Invalid response from server');
      }

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        responseData,
        (data) => data as Map<String, dynamic>,
      );

      if (apiResponse.isSuccess) {
        // Save OTP verification token from sendOtp response
        final otpToken = apiResponse.data?['otpVerificationToken']?['token'];
        if (otpToken != null && otpToken.toString().isNotEmpty) {
          await AuthLocalStorage.saveOtpVerificationToken(otpToken.toString());
          print('✓ OTP verification token saved from sendOtp');
        }

        print('✓ OTP sent successfully');
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

  Future<Map<String, dynamic>?> verifyOtp(String otp,
      {bool includeTokens = true}) async {
    try {
      final otpToken = await AuthLocalStorage.getOtpVerificationToken();

      if (otpToken == null || otpToken.isEmpty) {
        throw AuthenticationException(
            "OTP session expired. Please request new OTP.");
      }

      final response = await _api.verifyOtp(
        otp,
        otpToken,
        includeTokens: includeTokens,
      );

      final res = response.data as Map<String, dynamic>?;
      if (res == null || res["status"] != true) {
        throw AuthenticationException("Invalid OTP");
      }

      final data = res["data"];

      // ✅ Extract and save passwordResetToken if it exists
      final tokens = data?["tokens"];
      if (tokens != null) {
        final passwordResetToken = tokens["passwordResetToken"]?["token"];
        if (passwordResetToken != null &&
            passwordResetToken.toString().isNotEmpty) {
          await AuthLocalStorage.savePasswordResetToken(
              passwordResetToken.toString());
          print("✓ Password reset token saved from verifyOtp");
        }
      }

      print("✓ OTP verified successfully");
      return data;
    } catch (e) {
      throw AuthenticationException("OTP verification failed: $e");
    }
  }

  // Request password reset token (called after OTP verification for PIN setup)
  Future<void> requestPasswordResetToken(String mobile) async {
    try {
      final response = await _api.sendOtp(mobile, isReset: true);
      final responseData = response.data as Map<String, dynamic>?;

      if (responseData == null) {
        throw ApiException('Invalid response from server');
      }

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        responseData,
        (data) => data as Map<String, dynamic>,
      );

      if (apiResponse.isSuccess) {
        // passwordResetToken is already saved in AuthApiService.sendOtp
        print('✓ Password reset token obtained for PIN setup');
      } else {
        throw ApiException(
            apiResponse.message ?? 'Failed to get password reset token');
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        'Failed to get password reset token: ${e.toString()}',
        originalError: e,
      );
    }
  }

// ==================== Set PIN  ====================

  Future<User> setPin(String mobile, String pin) async {
    try {
      // Now resetPassword will have the passwordResetToken already saved!
      final response = await _api.resetPassword(
        mobile: mobile,
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
