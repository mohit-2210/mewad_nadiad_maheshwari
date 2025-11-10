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
      RequestOptions options, RequestInterceptorHandler handler) async {
    final nonAuthEndpoints = [
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

    final skipAuth = nonAuthEndpoints.any((ep) => options.path.contains(ep));

    if (!skipAuth) {
      final token = await AuthLocalStorage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // don't retry auth endpoints
      final isAuth = ['/login', '/register', '/refreshTokens']
          .any((ep) => err.requestOptions.path.contains(ep));

      if (isAuth) {
        return handler.next(err);
      }

      if (_isRefreshing) {
        // Queue request
        final completer = Completer<Response>();
        _pendingRequests.add(_PendingRequest(err.requestOptions, completer));

        return completer.future.then(
          (value) => handler.resolve(value),
          onError: (e) => handler.next(err),
        );
      }

      _isRefreshing = true;

      try {
        // refresh token
        final authRepo = AuthRepository();
        await authRepo.refreshAccessToken();

        final newToken = await AuthLocalStorage.getAccessToken();
        if (newToken == null || newToken.isEmpty) {
          throw Exception("Refresh returned empty token");
        }

        // Retry original request
        final response = await _retry(err.requestOptions, newToken);

        // Retry queued requests
        _processPendingRequests(newToken);

        _pendingRequests.clear();
        _isRefreshing = false;

        return handler.resolve(response);
      } catch (e) {
        _isRefreshing = false;
        _pendingRequests.clear();
        await AuthLocalStorage.clear();
        return handler.next(err);
      }
    }

    return handler.next(err);
  }

  Future<Response> _retry(RequestOptions requestOptions, String newToken) {
    final options = Options(
      method: requestOptions.method,
      headers: {
        ...requestOptions.headers,
        'Authorization': 'Bearer $newToken',
      },
    );

    return dio.request(
      requestOptions.path,
      options: options,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
    );
  }

  void _processPendingRequests(String token) {
    for (final p in _pendingRequests) {
      final opts = Options(
        method: p.requestOptions.method,
        headers: {
          ...p.requestOptions.headers,
          'Authorization': 'Bearer $token',
        },
      );

      dio
          .request(
            p.requestOptions.path,
            options: opts,
            data: p.requestOptions.data,
            queryParameters: p.requestOptions.queryParameters,
          )
          .then(
            p.completer.complete,
            onError: p.completer.completeError,
          );
    }
  }
}

class _PendingRequest {
  final RequestOptions requestOptions;
  final Completer<Response> completer;
  _PendingRequest(this.requestOptions, this.completer);
}