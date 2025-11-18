import 'package:dio/dio.dart';
import 'package:mmsn/app/Dio/dio_client.dart';
import 'package:mmsn/app/globals/api_endpoint.dart';
import 'package:mmsn/models/user.dart';
import 'package:mmsn/models/exceptions.dart';
import 'package:mmsn/pages/auth/storage/auth_local_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthApiService {
  final Dio _dio = DioClient.instance;

  // Singleton pattern
  static final AuthApiService _instance = AuthApiService._internal();
  static AuthApiService get instance => _instance;

  AuthApiService._internal();

  // Current user state
  User? _currentUser;
  User? get currentUser => _currentUser;

  // Token storage keys
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';

  // Initialize - load user from storage
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString(_userDataKey);

      if (userData != null) {
        try {
          _currentUser = User.fromJson(json.decode(userData));
        } catch (e) {
          print('Error loading user data: $e');
          await clearUserData();
        }
      }

      // Also sync with AuthLocalStorage
      final storedUser = await AuthLocalStorage.getUser();
      if (storedUser != null && _currentUser == null) {
        _currentUser = storedUser;
        // Save to this service's storage too
        await _saveUserData(
          storedUser,
          await getAccessToken() ?? '',
          await getRefreshToken() ?? '',
        );
      }
    } catch (e) {
      print('Error initializing AuthApiService: $e');
    }
  }

  // Save user data to storage
  Future<void> _saveUserData(
      User user, String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userDataKey, json.encode(user.toJson()));
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
    _currentUser = user;
  }

  // Clear user data from storage
  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userDataKey);
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    _currentUser = null;
  }

  // Get stored tokens - sync with AuthLocalStorage
  Future<String?> getAccessToken() async {
    // First try AuthLocalStorage (source of truth)
    final token = await AuthLocalStorage.getAccessToken();
    if (token != null) return token;

    // Fallback to local storage
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    // First try AuthLocalStorage (source of truth)
    final token = await AuthLocalStorage.getRefreshToken();
    if (token != null) return token;

    // Fallback to local storage
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  // Helper method to handle Dio errors
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
        return ApiException(
          'Request cancelled',
          originalError: error,
        );
      case DioExceptionType.unknown:
        if (error.error?.toString().contains('SocketException') == true ||
            error.error?.toString().contains('Network is unreachable') ==
                true) {
          return NetworkException(
            'No internet connection. Please check your network settings.',
            originalError: error,
          );
        }
        return UnknownException(
          'An unexpected error occurred',
          originalError: error,
        );
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

  // Check if user exists and has PIN
  Future<Response> checkUser(String mobile) async {
    try {
      return await _dio.post(
        checkUserEndpoint,
        data: {
          "mobile": mobile,
        },
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Login with mobile and password/PIN with deviceId and deviceToken
  Future<Response> login(String mobile, String password, String deviceId,
      String deviceToken) async {
    try {
      return await _dio.post(
        loginEndpoint,
        data: {
          "mobile": mobile,
          "password": password,
          "deviceId": deviceId,
          "deviceToken": deviceToken,
        },
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Send OTP to mobile
  Future<Response> sendOtp(String mobile) async {
    try {
      return await _dio.post(
        sendOtpEndpoint,
        //To change in prod data: {"mobile": mobile},
        data: {
          "email": "test12@yopmail.com",
        },
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Verify OTP
  Future<Response> verifyOtp(String mobile, String otp) async {
    try {
      return await _dio.post(
        verifyOtpEndpoint,
        data: {
          "mobile": mobile,
          "otp": otp,
        },
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Reset/Set password (used for setting PIN after OTP verification)
  Future<Response> resetPassword({
    required String mobile,
    required String newPassword,
    String? otp,
  }) async {
    try {
      final data = {
        "mobile": mobile,
        "newPassword": newPassword,
      };

      // Include OTP if provided (for setting password after OTP verification)
      if (otp != null && otp.isNotEmpty) {
        data["otp"] = otp;
      }

      return await _dio.post(
        resetPasswordEndpoint,
        data: data,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Register new user
  Future<Response> register(Map<String, dynamic> data) async {
    try {
      return await _dio.post(
        registerEndpoint,
        data: data,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Logout - updated to work without parameters
  Future<void> logout() async {
    try {
      final accessToken = await AuthLocalStorage.getAccessToken();
      final refreshToken = await AuthLocalStorage.getRefreshToken();

      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          await _dio.post(
            logoutEndpoint,
            data: {
              "refreshToken": refreshToken,
            },
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
      } else {
        print('No refresh token found for logout');
      }
    } catch (e) {
      print('Error in logout(): $e');
    } finally {
      await clearUserData();
      await AuthLocalStorage.clear();
    }
  }

  // Refresh token
  Future<Response> refreshToken(String refreshToken) async {
    try {
      return await _dio.post(
        refreshTokenEndpoint,
        data: {
          "refreshToken": refreshToken,
        },
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Change password
  Future<Response> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      return await _dio.post(
        changePasswordEndpoint,
        data: {
          "oldPassword": oldPassword,
          "newPassword": newPassword,
        },
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Forgot password
  Future<Response> forgotPassword(String mobile) async {
    try {
      return await _dio.post(
        forgetPasswordEndpoint,
        data: {
          "mobile": mobile,
        },
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Update current user (for profile updates)
  Future<void> updateCurrentUser(User user) async {
    // Get tokens from AuthLocalStorage (source of truth)
    final accessToken = await AuthLocalStorage.getAccessToken();
    final refreshToken = await AuthLocalStorage.getRefreshToken();

    if (accessToken != null && refreshToken != null) {
      await _saveUserData(user, accessToken, refreshToken);
    } else {
      // If no tokens, just update the in-memory user
      _currentUser = user;
    }
  }

  // Check if user is logged in
  bool get isLoggedIn => _currentUser != null;
}
