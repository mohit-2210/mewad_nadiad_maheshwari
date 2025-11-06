// lib/app/Dio/auth_interceptor.dart
import 'package:dio/dio.dart';
import 'package:mmsn/pages/auth/storage/auth_local_storage.dart';
import 'package:mmsn/pages/auth/data/auth_repository.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;

  AuthInterceptor(this.dio);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip token for auth endpoints
    final authEndpoints = [
      '/api/v1/auth/login',
      '/api/v1/auth/register',
      '/api/v1/auth/sendOtp',
      '/api/v1/auth/verifyOtp',
      '/api/v1/auth/checkUser',
    ];

    if (!authEndpoints.any((endpoint) => options.path.contains(endpoint))) {
      // Add token for protected endpoints
      final token = await AuthLocalStorage.getAccessToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle 401 Unauthorized
    if (err.response?.statusCode == 401) {
      try {
        // Try to refresh token
        final authRepo = AuthRepository();
        await authRepo.refreshAccessToken();

        // Retry original request
        final opts = Options(
          method: err.requestOptions.method,
          headers: err.requestOptions.headers,
        );
        
        final token = await AuthLocalStorage.getAccessToken();
        if (token != null) {
          opts.headers?['Authorization'] = 'Bearer $token';
        }

        final cloneReq = await dio.request(
          err.requestOptions.path,
          options: opts,
          data: err.requestOptions.data,
          queryParameters: err.requestOptions.queryParameters,
        );

        return handler.resolve(cloneReq);
      } catch (e) {
        // Refresh failed - logout user
        await AuthLocalStorage.clear();
        return handler.next(err);
      }
    }

    return handler.next(err);
  }
}