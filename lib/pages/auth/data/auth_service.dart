import 'package:dio/dio.dart';
import 'package:mmsn/app/Dio/dio_client.dart';
import 'package:mmsn/app/globals/api_endpoint.dart';
import 'package:mmsn/models/user.dart';
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
  }

  // Save user data to storage
  Future<void> _saveUserData(User user, String accessToken, String refreshToken) async {
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

  // Get stored tokens
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  // Check if user exists and has PIN
  Future<Response> checkUser(String mobile) async {
    return await _dio.post(
      checkUserEndpoint,
      data: {"mobile": mobile},
    );
  }

  // Login with mobile and password/PIN
  Future<Response> login(String mobile, String password) async {
    final response = await _dio.post(
      loginEndpoint,
      data: {
        "mobile": mobile,
        "password": password,
      },
    );

    // Save user data after successful login
    if (response.statusCode == 200 && response.data != null) {
      final data = response.data;
      if (data['user'] != null && data['accessToken'] != null && data['refreshToken'] != null) {
        final user = User.fromJson(data['user']);
        await _saveUserData(user, data['accessToken'], data['refreshToken']);
      }
    }

    return response;
  }

  // Send OTP to mobile
  Future<Response> sendOtp(String mobile) async {
    return await _dio.post(
      sendOtpEndpoint,
      data: {"mobile": mobile},
    );
  }

  // Verify OTP
  Future<Response> verifyOtp(String mobile, String otp) async {
    return await _dio.post(
      verifyOtpEndpoint,
      data: {
        "mobile": mobile,
        "otp": otp,
      },
    );
  }

  // Set PIN for existing user (after OTP verification)
  Future<Response> setPin(String mobile, String pin) async {
    return await _dio.post(
      setPinEndpoint,
      data: {
        "mobile": mobile,
        "pin": pin,
      },
    );
  }

  // Register new user
  Future<Response> register(Map<String, dynamic> data) async {
    final response = await _dio.post(registerEndpoint, data: data);

    // Save user data after successful registration
    if (response.statusCode == 201 && response.data != null) {
      final responseData = response.data;
      if (responseData['user'] != null && responseData['accessToken'] != null && responseData['refreshToken'] != null) {
        final user = User.fromJson(responseData['user']);
        await _saveUserData(user, responseData['accessToken'], responseData['refreshToken']);
      }
    }

    return response;
  }

  // Logout - updated to work without parameters
  Future<void> logout() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken != null) {
        await _dio.post(
          logoutEndpoint,
          data: {"refreshToken": refreshToken},
        );
      }
    } catch (e) {
      print('Error during logout API call: $e');
    } finally {
      // Always clear local data, even if API call fails
      await clearUserData();
    }
  }

  // Refresh token
  Future<Response> refreshToken(String refreshToken) async {
    final response = await _dio.post(
      refreshTokenEndpoint,
      data: {"refreshToken": refreshToken},
    );

    // Update tokens after refresh
    if (response.statusCode == 200 && response.data != null) {
      final data = response.data;
      if (data['accessToken'] != null && data['refreshToken'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_accessTokenKey, data['accessToken']);
        await prefs.setString(_refreshTokenKey, data['refreshToken']);
      }
    }

    return response;
  }

  // Change password
  Future<Response> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    return await _dio.post(
      changePasswordEndpoint,
      data: {
        "oldPassword": oldPassword,
        "newPassword": newPassword,
      },
    );
  }

  // Forgot password
  Future<Response> forgotPassword(String mobile) async {
    return await _dio.post(
      forgetPasswordEndpoint,
      data: {"mobile": mobile},
    );
  }

  // Update current user (for profile updates)
  Future<void> updateCurrentUser(User user) async {
    final accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();
    
    if (accessToken != null && refreshToken != null) {
      await _saveUserData(user, accessToken, refreshToken);
    } else {
      _currentUser = user;
    }
  }

  // Check if user is logged in
  bool get isLoggedIn => _currentUser != null;
}