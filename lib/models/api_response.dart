// lib/models/api_response.dart
/// Generic API Response Model
class ApiResponse<T> {
  final bool status;
  final String? message;
  final T? data;
  final Map<String, dynamic>? errors;

  ApiResponse({
    required this.status,
    this.message,
    this.data,
    this.errors,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse<T>(
      status: json['status'] as bool? ?? false,
      message: json['message'] as String?,
      data: json['data'] != null
          ? (fromJsonT != null ? fromJsonT(json['data']) : json['data'] as T)
          : null,
      errors: json['errors'] as Map<String, dynamic>?,
    );
  }

  bool get isSuccess => status == true;
  bool get hasError => status == false || errors != null;
}

/// API Error Response
class ApiError {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  ApiError({
    required this.message,
    this.statusCode,
    this.errors,
  });

  factory ApiError.fromJson(Map<String, dynamic> json, {int? statusCode}) {
    return ApiError(
      message: json['message'] as String? ?? 'An error occurred',
      statusCode: statusCode,
      errors: json['errors'] as Map<String, dynamic>?,
    );
  }

  @override
  String toString() => message;
}

