import 'package:dio/dio.dart';
import 'package:mmsn/app/Dio/dio_client.dart';
import 'package:mmsn/app/globals/api_endpoint.dart';
import 'package:mmsn/models/user.dart';
import 'package:mmsn/models/exceptions.dart';
import 'package:mmsn/pages/auth/storage/auth_local_storage.dart';

class AuthApiService {
  final Dio _dio = DioClient.instance;

  static final AuthApiService _instance = AuthApiService._internal();
  static AuthApiService get instance => _instance;

  AuthApiService._internal();

  User? _currentUser;
  User? get currentUser => _currentUser;

  // ==================== Error Handling ====================

  ApiException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException(
          'Connection timeout. Please check your internet connection.',
          originalError: error,
        );
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;

        if (statusCode == 401) {
          return AuthenticationException(
            _extractErrorMessage(data) ?? 'Authentication failed',
            statusCode: statusCode,
            originalError: error,
          );
        } else if (statusCode == 403) {
          return AuthorizationException(
            _extractErrorMessage(data) ?? 'Access denied',
            statusCode: statusCode,
            originalError: error,
          );
        } else if (statusCode == 400 || statusCode == 422) {
          return ValidationException(
            _extractErrorMessage(data) ?? 'Validation failed',
            errors: _extractErrors(data),
            statusCode: statusCode,
            originalError: error,
          );
        } else if (statusCode != null && statusCode >= 500) {
          return ServerException(
            _extractErrorMessage(data) ??
                'Server error. Please try again later.',
            statusCode: statusCode,
            originalError: error,
          );
        } else {
          return ApiException(
            _extractErrorMessage(data) ?? 'An error occurred',
            statusCode: statusCode,
            originalError: error,
          );
        }
      case DioExceptionType.cancel:
        return ApiException('Request cancelled', originalError: error);
      case DioExceptionType.unknown:
        if (error.error?.toString().contains('SocketException') == true ||
            error.error?.toString().contains('Network is unreachable') ==
                true) {
          return NetworkException(
            'No internet connection. Please check your network settings.',
            originalError: error,
          );
        }
        return UnknownException('An unexpected error occurred',
            originalError: error);
      default:
        return UnknownException(
          'An unexpected error occurred: ${error.message}',
          originalError: error,
        );
    }
  }

  String? _extractErrorMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message'] as String?;
    }
    return null;
  }

  Map<String, dynamic>? _extractErrors(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['errors'] as Map<String, dynamic>?;
    }
    return null;
  }

  // ==================== API Calls ====================

  /// Check if user exists
  Future<Response> checkUser(String mobile) async {
    try {
      final accessToken = await AuthLocalStorage.getAccessToken();
      final response = await _dio.post(
        checkUserEndpoint,
        data: {"mobile": mobile},
        options: Options(
          headers: {
            "Authorization": "Bearer $accessToken",
          },
        ),
      );

      if (response.statusCode == 200 && response.data['status'] == true) {
        return response;
      }

      throw Exception(response.data['message'] ?? 'Failed to check user');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Login with mobile and password
  Future<Response> login(
    String mobile,
    String password,
    String deviceId,
    String deviceToken,
  ) async {
    try {
      final response = await _dio.post(
        loginEndpoint,
        data: {
          "mobile": mobile,
          "password": password,
          "deviceId": deviceId,
          "deviceToken": deviceToken,
        },
      );

      // Save tokens from login response
      final data = response.data as Map<String, dynamic>?;
      if (data != null && data['status'] == true) {
        final responseData = data['data'] as Map<String, dynamic>?;
        if (responseData != null) {
          final accessToken = responseData['tokens']?['access']?['token'];
          final refreshToken = responseData['tokens']?['refresh']?['token'];

          if (accessToken != null && refreshToken != null) {
            await AuthLocalStorage.saveTokens(accessToken, refreshToken);
          }
        }
      }

      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Send OTP to mobile
  Future<Response> sendOtp(String mobile, {bool isReset = false}) async {
    try {
      final accessToken = await AuthLocalStorage.getAccessToken();
      final body = {
        "mobile": mobile,
      };

      if (isReset) {
        body["tokenType"] = "PASSWORD_RESET_TOKEN"; // For password reset
      }
      final response = await _dio.post(
        sendOtpEndpoint,
        data: body,
        options: Options(
          headers: {
            "Authorization": "Bearer $accessToken",
          },
        ),
      );
      // ------ HANDLE RESPONSE ------
      if (response.statusCode == 200 && response.data["status"] == true) {
        final data = response.data["data"];

        if (!isReset) {
          // NORMAL LOGIN — store otpVerificationToken
          if (data?["otpVerificationToken"]?["token"] != null) {
            final otpToken = data["otpVerificationToken"]["token"];
            await AuthLocalStorage.saveOtpVerificationToken(otpToken);
            print(
                "✓ OTP Verification Token Saved: ${otpToken.substring(0, 20)}...");
          }
        } else {
          // RESET PASSWORD — store passwordResetToken
          if (data?["passwordResetToken"]?["token"] != null) {
            final resetToken = data["passwordResetToken"]["token"];
            await AuthLocalStorage.savePasswordResetToken(resetToken);
            print(
                "✓ Password Reset Token Saved: ${resetToken.substring(0, 20)}...");
          }
        }
      }
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Verify OTP
  Future<Response> verifyOtp(
    String otp,
    String otpSession, {
    bool includeTokens = true,
    String? otpType, // e.g. "FORGET_PASSWORD" for reset flow
  }) async {
    try {
      print('🔑 Verifying OTP with session: ${otpSession.substring(0, 20)}...');

      final body = {
        "otp": otp,
        "isIncludeTokens": includeTokens,
      };

      if (otpType != null) {
        body["otpType"] = otpType;
      }

      final response = await _dio.post(
        verifyOtpEndpoint,
        data: body,
        options: Options(
          headers: {
            "Authorization": "Bearer $otpSession",
          },
        ),
      );

      if (includeTokens) {
        final data = response.data["data"];
        final tokens = data?["tokens"];

        if (tokens != null) {
          final accessToken = tokens["accessToken"]?["token"];
          final refreshToken = tokens["refreshToken"]?["token"];
          final passwordResetToken = tokens["passwordResetToken"]?["token"];

          if (accessToken is String) {
            await AuthLocalStorage.saveAccessToken(accessToken);
            print("✓ Access token saved from verifyOtp");
          }

          if (refreshToken is String) {
            await AuthLocalStorage.saveRefreshToken(refreshToken);
            print("✓ Refresh token saved from verifyOtp");
          }

          if (passwordResetToken is String) {
            await AuthLocalStorage.savePasswordResetToken(passwordResetToken);
            print("✓ Password reset token saved from verifyOtp");
          }
        }
      }

      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Register new user
  Future<Response> register(Map<String, dynamic> data) async {
    try {
      return await _dio.post(registerEndpoint, data: data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Reset/Set password (for existing users without PIN)
  Future<Response> resetPassword({
    // required String mobile,
    required String newPassword,
    String? otp,
  }) async {
    try {
      final passwordResetToken = await AuthLocalStorage.getPasswordResetToken();

      if (passwordResetToken == null) {
        throw AuthenticationException(
          "Password Reset session expired. Please request OTP again.",
        );
      }

      final data = {
        // "mobile": mobile,
        "newPassword": newPassword,
      };

      if (otp != null && otp.isNotEmpty) {
        data["otp"] = otp;
      }

      final response = await _dio.post(
        resetPasswordEndpoint,
        data: data,
        options: Options(
          headers: {
            "Authorization": "Bearer $passwordResetToken",
          },
        ),
      );

      await AuthLocalStorage.clearPasswordResetToken();

      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Change password (for logged-in users)
  Future<Response> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final accessToken = await AuthLocalStorage.getAccessToken();

      if (accessToken == null) {
        throw AuthenticationException('Not authenticated. Please login again.');
      }

      return await _dio.post(
        changePasswordEndpoint,
        data: {
          "oldPassword": oldPassword,
          "newPassword": newPassword,
        },
        options: Options(
          headers: {
            "Authorization": "Bearer $accessToken",
          },
        ),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Refresh access token
  Future<Response> refreshToken(String refreshToken) async {
    try {
      final response = await _dio.post(
        refreshTokenEndpoint,
        data: {"refreshToken": refreshToken},
      );

      // Save new tokens
      final data = response.data as Map<String, dynamic>?;
      if (data != null && data['status'] == true) {
        final tokens = data['data'];
        if (tokens != null) {
          final newAccessToken = tokens['access']?['token'];
          final newRefreshToken = tokens['refresh']?['token'];

          if (newAccessToken != null && newRefreshToken != null) {
            await AuthLocalStorage.saveTokens(newAccessToken, newRefreshToken);
          }
        }
      }

      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      final accessToken = await AuthLocalStorage.getAccessToken();
      final refreshToken = await AuthLocalStorage.getRefreshToken();

      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          await _dio.post(
            logoutEndpoint,
            data: {"refreshToken": refreshToken},
            options: Options(
              headers: {
                "Authorization": "Bearer $accessToken",
                "Content-Type": "application/json",
              },
            ),
          );
        } on DioException catch (e) {
          print('Error during logout API call: ${e.message}');
        }
      }
    } catch (e) {
      print('Error in logout(): $e');
    } finally {
      await AuthLocalStorage.clear();
      _currentUser = null;
    }
  }

  /// Update current user in memory
  void updateCurrentUser(User user) {
    _currentUser = user;
  }

  /// Clear current user
  void clearCurrentUser() {
    _currentUser = null;
  }

  /// Check if user is logged in
  bool get isLoggedIn => _currentUser != null;
}
