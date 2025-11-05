import 'package:dio/dio.dart';
import 'package:mmsn/app/globals/api_endpoint.dart';

class DioClient {

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  )..interceptors.add(LogInterceptor(
      request: true,
      requestBody: true,
      responseBody: true,
      error: true,
    ));

  static Dio get instance => _dio;
}
