// lib/pages/auth/data/auth_repository.dart
import 'package:mmsn/models/user.dart';
import 'package:mmsn/pages/auth/data/auth_service.dart';
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

class TokenModel {
  final String accessToken;
  final String refreshToken;

  TokenModel({
    required this.accessToken,
    required this.refreshToken,
  });

  factory TokenModel.fromJson(Map<String, dynamic> json) {
    return TokenModel(
      accessToken: json['accessToken'] ?? json['access_token'] ?? '',
      refreshToken: json['refreshToken'] ?? json['refresh_token'] ?? '',
    );
  }
}

class AuthRepository {
  final AuthApiService _api = AuthApiService.instance;

  // Check if user exists and status
  Future<CheckUserResult> checkUser(String mobile) async {
    try {
      final response = await _api.checkUser(mobile);

      if (response.data["status"] == true) {
        final userData = response.data["data"];
        
        if (userData == null) {
          return CheckUserResult(status: UserExistsStatus.doesNotExist);
        }

        final user = User.fromJson(userData);
        final hasPin = userData["hasPin"] == true || user.pin != null;

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
      } else {
        return CheckUserResult(status: UserExistsStatus.doesNotExist);
      }
    } catch (e) {
      // If 404 or user not found
      return CheckUserResult(status: UserExistsStatus.doesNotExist);
    }
  }

  // Login with mobile and PIN
  Future<User> login(String mobile, String pin) async {
    final response = await _api.login(mobile, pin);

    if (response.data["status"] == true) {
      final user = User.fromJson(response.data["data"]["user"]);
      final tokens = TokenModel.fromJson(response.data["data"]);
      
      await AuthLocalStorage.saveTokens(tokens.accessToken, tokens.refreshToken);
      await AuthLocalStorage.saveUser(user);
      
      return user;
    } else {
      throw Exception(response.data["message"] ?? "Login failed");
    }
  }

  // Send OTP
  Future<void> sendOtp(String mobile) async {
    final response = await _api.sendOtp(mobile);
    
    if (response.data["status"] != true) {
      throw Exception(response.data["message"] ?? "Failed to send OTP");
    }
  }

  // Verify OTP
  Future<bool> verifyOtp(String mobile, String otp) async {
    final response = await _api.verifyOtp(mobile, otp);
    
    if (response.data["status"] == true) {
      return true;
    } else {
      throw Exception(response.data["message"] ?? "Invalid OTP");
    }
  }

  // Set PIN for existing user
  Future<User> setPin(String mobile, String pin) async {
    final response = await _api.setPin(mobile, pin);

    if (response.data["status"] == true) {
      final user = User.fromJson(response.data["data"]["user"]);
      final tokens = TokenModel.fromJson(response.data["data"]);
      
      await AuthLocalStorage.saveTokens(tokens.accessToken, tokens.refreshToken);
      await AuthLocalStorage.saveUser(user);
      
      return user;
    } else {
      throw Exception(response.data["message"] ?? "Failed to set PIN");
    }
  }

  // Register new user
  Future<User> register(Map<String, dynamic> userData) async {
    final response = await _api.register(userData);

    if (response.data["status"] == true) {
      final user = User.fromJson(response.data["data"]["user"]);
      final tokens = TokenModel.fromJson(response.data["data"]);
      
      await AuthLocalStorage.saveTokens(tokens.accessToken, tokens.refreshToken);
      await AuthLocalStorage.saveUser(user);
      
      return user;
    } else {
      throw Exception(response.data["message"] ?? "Registration failed");
    }
  }

  // Logout - FIXED: No longer passes refreshToken parameter
  Future<void> logout() async {
    try {
      // AuthApiService.logout() now handles getting the refresh token internally
      await _api.logout();
    } catch (e) {
      // Continue with local logout even if API fails
      print('Logout API error: $e');
    }
    
    // Clear local storage
    await AuthLocalStorage.clear();
  }

  // Get current user
  Future<User?> getCurrentUser() async {
    return await AuthLocalStorage.getUser();
  }

  // Refresh token
  Future<void> refreshAccessToken() async {
    final refreshToken = await AuthLocalStorage.getRefreshToken();
    
    if (refreshToken == null) {
      throw Exception("No refresh token available");
    }

    final response = await _api.refreshToken(refreshToken);

    if (response.data["status"] == true) {
      final tokens = TokenModel.fromJson(response.data["data"]);
      await AuthLocalStorage.saveTokens(tokens.accessToken, tokens.refreshToken);
    } else {
      throw Exception("Failed to refresh token");
    }
  }
}