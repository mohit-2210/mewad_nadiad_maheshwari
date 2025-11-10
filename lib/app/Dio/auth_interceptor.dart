// lib/app/Dio/auth_interceptor.dart
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:mmsn/pages/auth/storage/auth_local_storage.dart';
import 'package:mmsn/pages/auth/data/auth_repository.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;
  bool _isRefreshing = false;
  final List<_PendingRequest> _pendingRequests = [];

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
      '/api/v1/auth/refreshTokens',
      '/api/v1/auth/logout',
      '/api/v1/auth/forgetPassword',
      '/api/v1/auth/resetPassword',
    ];

    final isAuthEndpoint = authEndpoints.any(
      (endpoint) => options.path.contains(endpoint),
    );

    if (!isAuthEndpoint) {
      // Add token for protected endpoints
      final token = await AuthLocalStorage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle 401 Unauthorized - token expired
    if (err.response?.statusCode == 401) {
      // Don't retry on auth endpoints
      final authEndpoints = [
        '/api/v1/auth/login',
        '/api/v1/auth/register',
        '/api/v1/auth/refreshTokens',
      ];
      
      final isAuthEndpoint = authEndpoints.any(
        (endpoint) => err.requestOptions.path.contains(endpoint),
      );

      if (isAuthEndpoint) {
        return handler.next(err);
      }

      // If already refreshing, queue this request
      if (_isRefreshing) {
        final completer = Completer<Response>();
        _pendingRequests.add(_PendingRequest(err.requestOptions, completer));
        return completer.future.then(
          (response) => handler.resolve(response),
          onError: (error) => handler.next(err),
        );
      }

      _isRefreshing = true;

      try {
        // Try to refresh token
        final authRepo = AuthRepository();
        await authRepo.refreshAccessToken();

        // Retry all pending requests
        final token = await AuthLocalStorage.getAccessToken();
        if (token != null && token.isNotEmpty) {
          // Update original request
          err.requestOptions.headers['Authorization'] = 'Bearer $token';

          // Retry original request
          final opts = Options(
            method: err.requestOptions.method,
            headers: err.requestOptions.headers,
          );

          final cloneReq = await dio.request(
            err.requestOptions.path,
            options: opts,
            data: err.requestOptions.data,
            queryParameters: err.requestOptions.queryParameters,
          );

          // Process pending requests
          _processPendingRequests(token);

          _isRefreshing = false;
          _pendingRequests.clear();

          return handler.resolve(cloneReq);
        } else {
          throw Exception('Token refresh failed - no token received');
        }
      } catch (e) {
        // Refresh failed - clear tokens and logout user
        _isRefreshing = false;
        _pendingRequests.clear();
        await AuthLocalStorage.clear();
        return handler.next(err);
      }
    }

    return handler.next(err);
  }

  void _processPendingRequests(String token) {
    for (final pendingRequest in _pendingRequests) {
      pendingRequest.requestOptions.headers['Authorization'] = 'Bearer $token';
      final opts = Options(
        method: pendingRequest.requestOptions.method,
        headers: pendingRequest.requestOptions.headers,
      );

      dio
          .request(
            pendingRequest.requestOptions.path,
            options: opts,
            data: pendingRequest.requestOptions.data,
            queryParameters: pendingRequest.requestOptions.queryParameters,
          )
          .then(
            (response) => pendingRequest.completer.complete(response),
            onError: (error) => pendingRequest.completer.completeError(error),
          );
    }
  }
}

class _PendingRequest {
  final RequestOptions requestOptions;
  final Completer<Response> completer;

  _PendingRequest(this.requestOptions, this.completer);
}