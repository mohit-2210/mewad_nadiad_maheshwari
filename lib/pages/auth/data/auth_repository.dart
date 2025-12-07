import 'package:mmsn/app/services/device_service.dart';
import 'package:mmsn/models/user.dart';
import 'package:mmsn/models/token_model.dart';
import 'package:mmsn/models/exceptions.dart';
import 'package:mmsn/models/api_response.dart';
import 'package:mmsn/pages/auth/services/auth_service.dart';
import 'package:mmsn/pages/auth/storage/auth_local_storage.dart';

enum UserExistsStatus {
  existsWithPinVerified,
  existsWithPinNotVerified,
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

      if (!apiResponse.isSuccess || apiResponse.data == null) {
        return CheckUserResult(status: UserExistsStatus.doesNotExist);
      }

      final userData = apiResponse.data!;
      final user = User.fromJson(userData);

      return CheckUserResult(
        status: UserExistsStatus.existsWithPinVerified,
        user: user,
      );
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        return CheckUserResult(status: UserExistsStatus.doesNotExist);
      }
      rethrow;
    } catch (e) {
      return CheckUserResult(status: UserExistsStatus.doesNotExist);
    }
  }

  // ==================== Login with Mobile ====================
  Future<User> loginWithMobile(String mobile) async {
    try {
      print('🔐 Logging in with mobile (no password)');

      final deviceId = DeviceService.instance.deviceId;
      final deviceToken = DeviceService.instance.deviceToken;

      if (deviceId == null || deviceToken == null) {
        throw AuthenticationException("Device details not ready");
      }

      final response = await _api.login(
        mobile,
        deviceId,
        deviceToken,
      );

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
          tokens.accessToken,
          tokens.refreshToken,
        );
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

  // ==================== Send Firebase Token to Backend (Step 4a) ====================
  /// This generates the otpVerificationToken
  Future<Map<String, dynamic>> sendFirebaseTokenToBackend({
    required String mobile,
    required String firebaseIdToken,
    required String tokenType,
  }) async {
    try {
      print('🔄 Sending Firebase ID token to backend');
      print('   - Mobile: $mobile');
      print('   - Token Type: $tokenType');

      final response = await _api.verifyFirebaseToken(
        mobile: mobile,
        firebaseIdToken: firebaseIdToken,
        tokenType: tokenType,
      );

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

        // Save the otpVerificationToken for Step 4b
        if (tokenType == 'OTP_VERIFICATION_TOKEN') {
          final otpToken = data['otpVerificationToken']?['token'];
          if (otpToken != null) {
            await AuthLocalStorage.saveOtpVerificationToken(otpToken);
            print('✓ OTP verification token saved');
          }
        } else if (tokenType == 'PASSWORD_RESET_TOKEN') {
          final passwordResetToken = data['passwordResetToken']?['token'] ??
              data['passwordToken']?['token'];
          if (passwordResetToken != null) {
            await AuthLocalStorage.savePasswordResetToken(passwordResetToken);
            print('✓ Password reset token saved');
          }
        }

        print('✅ Backend token generation complete');
        return data;
      } else {
        throw ApiException(
            apiResponse.message ?? 'Backend verification failed');
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        'Backend verification failed: ${e.toString()}',
        originalError: e,
      );
    }
  }

  // ==================== Update Verification Status (NEW - SIMPLIFIED) ====================
  /// This actually updates mobileVerification and emailVerification to ACCEPTED
  /// Uses the user update endpoint with access token
  Future<void> updateMobileVerificationStatus(String userId) async {
    try {
      print('📝 Updating verification status to ACCEPTED');
      print('   - User ID: $userId');

      final response = await _api.updateVerificationStatus(
        userId: userId,
      );

      final responseData = response.data as Map<String, dynamic>?;

      if (responseData == null) {
        throw ApiException('Invalid response from server');
      }

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        responseData,
        (data) => data as Map<String, dynamic>,
      );

      if (apiResponse.isSuccess) {
        print('✅ Verification status updated to ACCEPTED');
        // Clear any temporary tokens
        await AuthLocalStorage.clearOtpVerificationToken();
      } else {
        throw ApiException(
            apiResponse.message ?? 'Failed to update verification status');
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        'Failed to update verification: ${e.toString()}',
        originalError: e,
      );
    }
  }

  // ==================== Login with Firebase Token ====================
  Future<User> loginWithFirebaseToken(
      String mobile, String firebaseIdToken) async {
    try {
      print('🔐 Logging in with Firebase token');

      final deviceId = DeviceService.instance.deviceId;
      final deviceToken = DeviceService.instance.deviceToken;

      if (deviceId == null || deviceToken == null) {
        throw AuthenticationException("Device details not ready");
      }

      final response = await _api.loginWithFirebaseToken(
        mobile,
        firebaseIdToken,
        deviceId,
        deviceToken,
      );

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

  // ==================== Register ====================
  Future<User> register(Map<String, dynamic> userData) async {
    try {
      final registrationData = Map<String, dynamic>.from(userData);
      registrationData.remove('password');

      final response = await _api.register(registrationData);
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
