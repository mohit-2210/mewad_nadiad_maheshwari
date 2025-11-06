// lib/app/Dio/dio_client.dart
import 'package:dio/dio.dart';
import 'package:mmsn/app/globals/api_endpoint.dart';
import 'package:mmsn/app/Dio/auth_interceptor.dart';

class DioClient {
  static Dio? _dio;

  static Dio get instance {
    if (_dio == null) {
      _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      // Add interceptors
      _dio!.interceptors.add(
        LogInterceptor(
          request: true,
          requestBody: true,
          responseBody: true,
          error: true,
          logPrint: (obj) => print(obj), // Use print or your logger
        ),
      );

      // Add auth interceptor
      _dio!.interceptors.add(AuthInterceptor(_dio!));
    }

    return _dio!;
  }
}