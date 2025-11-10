// lib/pages/auth/data/user_service.dart
import 'package:dio/dio.dart';
import 'package:mmsn/app/Dio/dio_client.dart';
import 'package:mmsn/app/globals/api_endpoint.dart';
import 'package:mmsn/models/user.dart';
import 'package:mmsn/models/exceptions.dart';
import 'package:mmsn/models/api_response.dart';

class UserService {
  final Dio _dio = DioClient.instance;
  
  // Singleton pattern
  static final UserService _instance = UserService._internal();
  static UserService get instance => _instance;
  
  UserService._internal();

  // Get current user from API
  Future<User> getCurrentUser() async {
    try {
      final response = await _dio.get(getCurrentUserEndpoint);
      final responseData = response.data as Map<String, dynamic>?;

      if (responseData == null) {
        throw ApiException('Invalid response from server');
      }

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        responseData,
        (data) => data as Map<String, dynamic>,
      );

      if (apiResponse.isSuccess && apiResponse.data != null) {
        final userData = apiResponse.data!;
        return User.fromJson(userData);
      } else {
        throw ApiException(
          apiResponse.message ?? 'Failed to fetch user data',
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.badResponse) {
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;
        
        if (statusCode == 401) {
          throw AuthenticationException(
            _extractErrorMessage(data) ?? 'Authentication failed',
            statusCode: statusCode,
            originalError: e,
          );
        } else if (statusCode == 404) {
          throw ApiException('User not found', statusCode: statusCode);
        }
      }
      throw ApiException(
        'Failed to fetch user: ${e.message}',
        originalError: e,
      );
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Failed to fetch user: ${e.toString()}');
    }
  }

  String? _extractErrorMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message'] as String?;
    }
    return null;
  }
}

