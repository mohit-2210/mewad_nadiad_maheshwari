// lib/pages/auth/storage/auth_local_storage.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mmsn/models/user.dart';

class AuthLocalStorage {
  static const _accessTokenKey = "access_token";
  static const _refreshTokenKey = "refresh_token";
  static const _userKey = "user_profile";

  // Save tokens
  static Future<void> saveTokens(String access, String refresh) async {
    if (access.isEmpty || refresh.isEmpty) {
      throw Exception('Cannot save empty tokens');
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, access);
    await prefs.setString(_refreshTokenKey, refresh);
    
    // Verify tokens were saved
    final savedAccess = prefs.getString(_accessTokenKey);
    final savedRefresh = prefs.getString(_refreshTokenKey);
    
    if (savedAccess == null || savedRefresh == null) {
      throw Exception('Failed to save tokens to storage');
    }
  }

  // Save user
  static Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, user.toJsonString());
  }

  // Get access token
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  // Get refresh token
  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  // Get user
  static Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_userKey);
    if (json == null) return null;
    return User.fromJsonString(json);
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    final user = await getUser();
    return token != null && user != null;
  }

  // Clear all data
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userKey);
  }
}