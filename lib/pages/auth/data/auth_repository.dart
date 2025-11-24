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

  // Check if user exists and status
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

      if (apiResponse.isSuccess && apiResponse.data != null) {
        final userData = apiResponse.data!;

        try {
          final user = User.fromJson(userData);

          final password = userData["password"];
          final hasPassword = password != null &&
              password.toString().isNotEmpty &&
              password.toString() != 'null';

          final hasPin = hasPassword ||
              userData["hasPin"] == true ||
              userData["has_pin"] == true ||
              (user.pin != null && user.pin!.isNotEmpty);

          if (hasPin) {
            return CheckUserResult(
              status: UserExistsStatus.existsWithPin,
              user: user,
            );
          } else {
            return CheckUserResult(
              status: UserExistsStatus.existsWithoutPin,
              user: user,
            );
          }
        } catch (e) {
          return CheckUserResult(status: UserExistsStatus.doesNotExist);
        }
      } else {
        return CheckUserResult(status: UserExistsStatus.doesNotExist);
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

  // Login with mobile and PIN
  Future<User> login(String mobile, String password, String deviceId,
      String deviceToken) async {
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

        final userData = data['user'] as Map<String, dynamic>? ?? data;
        final user = User.fromJson(userData);

        final tokens = TokenModel.fromJson(data);

        if (tokens.accessToken.isEmpty || tokens.refreshToken.isEmpty) {
          throw AuthenticationException('Token data is missing');
        }

        await AuthLocalStorage.saveTokens(
            tokens.accessToken, tokens.refreshToken);
        await AuthLocalStorage.saveUser(user);
        await _api.updateCurrentUser(user);

        return user;
      } else {
        throw AuthenticationException(
          apiResponse.message ?? 'Login failed',
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw AuthenticationException(
        'Login failed: ${e.toString()}',
        originalError: e,
      );
    }
  }

  // Send OTP
  Future<void> sendOtp(String mobile) async {
    try {
      final response = await _api.sendOtp(mobile);
      final responseData = response.data as Map<String, dynamic>?;

      if (responseData == null) {
        throw ApiException('Invalid response from server');
      }

      final apiResponse = ApiResponse.fromJson(responseData, null);

      if (!apiResponse.isSuccess) {
        throw ApiException(
          apiResponse.message ?? 'Failed to send OTP',
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        'Failed to send OTP: ${e.toString()}',
        originalError: e,
      );
    }
  }

  // Verify OTP
  Future<bool> verifyOtp(String otp) async {
    try {
      final response = await _api.verifyOtp(otp);

      final responseData = response.data as Map<String, dynamic>?;

      if (responseData == null) {
        throw AuthenticationException('Invalid response from server');
      }

      final apiResponse = ApiResponse.fromJson(responseData, null);

      if (apiResponse.isSuccess) {
        return true;
      } else {
        throw AuthenticationException(
          apiResponse.message ?? 'Invalid OTP',
        );
      }
    } catch (e) {
      throw AuthenticationException('OTP verification failed: $e');
    }
  }

  // Set PIN for existing user (after OTP verification)
  Future<User> setPin(String mobile, String pin, {String? otp}) async {
    try {
      final response = await _api.resetPassword(
        mobile: mobile,
        newPassword: pin,
        otp: otp,
      );

      final responseData = response.data as Map<String, dynamic>?;

      if (responseData == null) {
        throw AuthenticationException('Invalid response from server');
      }

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        responseData,
        (data) => data as Map<String, dynamic>,
      );

      if (apiResponse.isSuccess) {
        final deviceId = DeviceService.instance.deviceId;
        final deviceToken = DeviceService.instance.deviceToken;

        if (deviceId == null || deviceToken == null) {
          throw AuthenticationException("Device details not ready");
        }

        // Login after setting PIN
        final loggedInUser = await login(mobile, pin, deviceId, deviceToken);
        return loggedInUser;
      } else {
        throw AuthenticationException(
          apiResponse.message ?? 'Failed to set PIN',
        );
      }
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

  // Register new user - ONLY creates user, does NOT log them in
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

        final userDataFromResponse =
            data['user'] as Map<String, dynamic>? ?? data;
        final user = User.fromJson(userDataFromResponse);

        // DON'T save tokens or log in - just return the user
        // OTP verification and login will happen next
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
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        'Registration failed: ${e.toString()}',
        originalError: e,
      );
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _api.logout();
    } catch (e) {
      print('Logout API error: $e');
    }

    await AuthLocalStorage.clear();
  }

  // Get current user
  Future<User?> getCurrentUser() async {
    return await AuthLocalStorage.getUser();
  }

  // Refresh token
  Future<void> refreshAccessToken() async {
    try {
      final refreshToken = await AuthLocalStorage.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        throw AuthenticationException('No refresh token available');
      }

      final response = await _api.refreshToken(refreshToken);
      final responseData = response.data as Map<String, dynamic>?;

      if (responseData == null) {
        throw AuthenticationException('Invalid response from server');
      }

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        responseData,
        (data) => data as Map<String, dynamic>,
      );

      if (apiResponse.isSuccess && apiResponse.data != null) {
        final tokens = TokenModel.fromJson(apiResponse.data!);

        if (tokens.accessToken.isEmpty || tokens.refreshToken.isEmpty) {
          throw AuthenticationException('Token data is missing');
        }

        await AuthLocalStorage.saveTokens(
            tokens.accessToken, tokens.refreshToken);
      } else {
        throw AuthenticationException(
          apiResponse.message ?? 'Failed to refresh token',
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw AuthenticationException(
        'Failed to refresh token: ${e.toString()}',
        originalError: e,
      );
    }
  }

// AuthRepository.dart
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
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException("Failed to change password: ${e.toString()}");
    }
  }
}
