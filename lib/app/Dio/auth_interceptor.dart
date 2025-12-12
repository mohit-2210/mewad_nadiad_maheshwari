import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mmsn/app/globals/app_navigator.dart';
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
    // Handle API Timeout with AUTO-RETRY (no dialog)
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      print("⏳ API timeout on: ${err.requestOptions.path}");

      // Show subtle loading indicator in global overlay
      _showLoadingOverlay("Server is taking longer than usual...");

      try {
        // Auto-retry after timeout
        print("🔁 Auto-retrying after timeout...");

        // Add small delay before retry
        await Future.delayed(const Duration(seconds: 2));

        final response = await dio.fetch(err.requestOptions);

        _hideLoadingOverlay();
        return handler.resolve(response);
      } catch (e) {
        _hideLoadingOverlay();

        // If still fails, try one more time
        try {
          print("🔁 Second retry attempt...");
          await Future.delayed(const Duration(seconds: 3));

          final response = await dio.fetch(err.requestOptions);
          return handler.resolve(response);
        } catch (finalError) {
          // After 2 retries, show error
          print("❌ Failed after retries");
          return handler.next(e as DioException);
        }
      }
    }

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

  // Global loading overlay
  OverlayEntry? _overlayEntry;

  void _showLoadingOverlay(String message) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    _hideLoadingOverlay(); // Remove any existing overlay

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideLoadingOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

class _PendingRequest {
  final RequestOptions requestOptions;
  final Completer<Response> completer;

  _PendingRequest(this.requestOptions, this.completer);
}
