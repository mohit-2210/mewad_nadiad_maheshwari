// lib/models/token_model.dart
class TokenModel {
  final String accessToken;
  final String refreshToken;

  TokenModel({required this.accessToken, required this.refreshToken});

  factory TokenModel.fromJson(Map<String, dynamic> json) {
    // Handle different response structures
    
    // Structure 1: { tokens: { accessToken: { token: "..." }, refreshToken: { token: "..." } } }
    if (json.containsKey('tokens') && json['tokens'] is Map<String, dynamic>) {
      final tokens = json['tokens'] as Map<String, dynamic>;
      
      // Extract accessToken
      String? accessToken;
      if (tokens.containsKey('accessToken')) {
        final accessTokenData = tokens['accessToken'];
        if (accessTokenData is Map<String, dynamic>) {
          accessToken = accessTokenData['token']?.toString();
        } else if (accessTokenData is String) {
          accessToken = accessTokenData;
        }
      }
      
      // Extract refreshToken
      String? refreshToken;
      if (tokens.containsKey('refreshToken')) {
        final refreshTokenData = tokens['refreshToken'];
        if (refreshTokenData is Map<String, dynamic>) {
          refreshToken = refreshTokenData['token']?.toString();
        } else if (refreshTokenData is String) {
          refreshToken = refreshTokenData;
        }
      }
      
      return TokenModel(
        accessToken: accessToken ?? '',
        refreshToken: refreshToken ?? '',
      );
    } 
    // Structure 2: { accessToken: "...", refreshToken: "..." } or { access_token: "...", refresh_token: "..." }
    else if (json.containsKey('accessToken') || json.containsKey('access_token')) {
      return TokenModel(
        accessToken: json['accessToken']?.toString() ?? json['access_token']?.toString() ?? '',
        refreshToken: json['refreshToken']?.toString() ?? json['refresh_token']?.toString() ?? '',
      );
    } 
    // Structure 3: { data: { accessToken: "...", refreshToken: "..." } } or nested in data
    else {
      final data = json['data'] as Map<String, dynamic>? ?? json;
      if (data.containsKey('tokens')) {
        // Recursive call if tokens are nested in data
        return TokenModel.fromJson(data);
      }
      return TokenModel(
        accessToken: data['accessToken']?.toString() ?? data['access_token']?.toString() ?? '',
        refreshToken: data['refreshToken']?.toString() ?? data['refresh_token']?.toString() ?? '',
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }
}