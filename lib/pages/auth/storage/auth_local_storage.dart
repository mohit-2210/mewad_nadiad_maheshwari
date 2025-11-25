import 'package:shared_preferences/shared_preferences.dart';
import 'package:mmsn/models/user.dart';

/// Centralized authentication and token storage
class AuthLocalStorage {
  static const _accessTokenKey = "access_token";
  static const _refreshTokenKey = "refresh_token";
  static const _otpSessionKey = "otp_session_token";
  static const _userKey = "user_profile";

  // ==================== Access Token ====================
  
  static Future<void> saveAccessToken(String token) async {
    if (token.isEmpty) throw Exception('Cannot save empty access token');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, token);
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  static Future<void> removeAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
  }

  // ==================== Refresh Token ====================
  
  static Future<void> saveRefreshToken(String token) async {
    if (token.isEmpty) throw Exception('Cannot save empty refresh token');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_refreshTokenKey, token);
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  static Future<void> removeRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_refreshTokenKey);
  }

  // ==================== Auth Tokens (Access + Refresh) ====================
  
  static Future<void> saveTokens(String access, String refresh) async {
    if (access.isEmpty || refresh.isEmpty) {
      throw Exception('Cannot save empty tokens');
    }
    
    await saveAccessToken(access);
    await saveRefreshToken(refresh);
    
    // Verify tokens were saved
    final savedAccess = await getAccessToken();
    final savedRefresh = await getRefreshToken();
    
    if (savedAccess == null || savedRefresh == null) {
      throw Exception('Failed to save tokens to storage');
    }
    print('✓ Access & Refresh tokens saved');
  }

  // ==================== OTP Session Token ====================
  
  static Future<void> saveOtpSession(String otpSession) async {
    if (otpSession.isEmpty) {
      throw Exception('Cannot save empty OTP session');
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_otpSessionKey, otpSession);
    print('✓ OTP session saved: ${otpSession.substring(0, 20)}...');
  }

  static Future<String?> getOtpSession() async {
    final prefs = await SharedPreferences.getInstance();
    final session = prefs.getString(_otpSessionKey);
    if (session != null) {
      print('✓ Retrieved OTP session: ${session.substring(0, 20)}...');
    } else {
      print('⚠️ No OTP session found');
    }
    return session;
  }

  static Future<void> clearOtpSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_otpSessionKey);
    print('✓ OTP session cleared');
  }

  // ==================== User Management ====================

  static Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, user.toJsonString());
    print('✓ User saved to storage');
  }

  static Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_userKey);
    if (json == null) return null;
    return User.fromJsonString(json);
  }

  static Future<void> removeUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  // ==================== Auth Status ====================

  static Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    final user = await getUser();
    return token != null && user != null;
  }

  static Future<bool> hasAuthTokens() async {
    final accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();
    return accessToken != null && refreshToken != null;
  }

  // ==================== Clear All ====================

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_otpSessionKey);
    await prefs.remove(_userKey);
    print('✓ All auth data cleared');
  }

  static Future<void> clearAllTokens() async {
    await removeAccessToken();
    await removeRefreshToken();
    await clearOtpSession();
    print('✓ All tokens cleared');
  }
}