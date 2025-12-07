import 'dart:io';
import 'package:dio/dio.dart';
import 'package:mmsn/app/Dio/dio_client.dart';
import 'package:mmsn/app/globals/api_endpoint.dart';
import 'package:mmsn/models/exceptions.dart';
import 'package:mmsn/pages/auth/storage/auth_local_storage.dart';

final Dio _dio = DioClient.instance;

/// Upload any file (image, pdf, etc.) and return its URL.
Future<String> uploadFile(File file) async {
  try {
    final token = await AuthLocalStorage.getAccessToken();

    final fileName = file.path.split(Platform.pathSeparator).last;

    final formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(
        file.path,
        filename: fileName,
      ),
    });

    final response = await _dio.post(
      uploadEndpoint,
      data: formData,
      options: Options(
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "multipart/form-data",
        },
      ),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return _extractFileUrl(response.data);
    }

    throw ApiException("Upload failed: ${response.statusCode}");
  } on DioException catch (e) {
    throw _handleDioError(e);
  } catch (e) {
    throw ApiException("Upload failed: ${e.toString()}");
  }
}

String _extractFileUrl(dynamic data) {
  if (data is! Map<String, dynamic>) {
    throw ApiException("Invalid response format");
  }

  final list = data["data"];

  if (list is List && list.isNotEmpty) {
    final first = list.first;

    if (first is Map<String, dynamic>) {
      final url = first["url"] ?? first["filePath"];

      if (url != null && url.toString().isNotEmpty) {
        return url.toString();
      }
    }
  }

  throw ApiException("File URL missing in response");
}

ApiException _handleDioError(DioException e) {
  final status = e.response?.statusCode;
  final data = e.response?.data;

  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return TimeoutException("Connection timeout", originalError: e);

    case DioExceptionType.badResponse:
      return ApiException(
        _extractErrorMessage(data) ?? "Server error ($status)",
        statusCode: status,
        originalError: e,
      );

    case DioExceptionType.cancel:
      return ApiException("Upload cancelled", originalError: e);

    case DioExceptionType.unknown:
      if (e.error.toString().contains("SocketException")) {
        return NetworkException("No internet connection", originalError: e);
      }
      return UnknownException("Unexpected error", originalError: e);

    default:
      return UnknownException("Error: ${e.message}", originalError: e);
  }
}

String? _extractErrorMessage(dynamic data) {
  if (data is Map<String, dynamic>) {
    return data["message"] as String?;
  }
  return null;
}
