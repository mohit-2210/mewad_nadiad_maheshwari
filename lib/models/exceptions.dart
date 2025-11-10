// lib/models/exceptions.dart
/// Base exception class for API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  ApiException(this.message, {this.statusCode, this.originalError});

  @override
  String toString() => message;
}

/// Network-related exceptions
class NetworkException extends ApiException {
  NetworkException(String message, {dynamic originalError})
      : super(message, originalError: originalError);
}

/// Authentication exceptions
class AuthenticationException extends ApiException {
  AuthenticationException(String message, {int? statusCode, dynamic originalError})
      : super(message, statusCode: statusCode, originalError: originalError);
}

/// Authorization exceptions
class AuthorizationException extends ApiException {
  AuthorizationException(String message, {int? statusCode, dynamic originalError})
      : super(message, statusCode: statusCode, originalError: originalError);
}

/// Validation exceptions
class ValidationException extends ApiException {
  final Map<String, dynamic>? errors;

  ValidationException(String message, {this.errors, int? statusCode, dynamic originalError})
      : super(message, statusCode: statusCode, originalError: originalError);
}

/// Server exceptions
class ServerException extends ApiException {
  ServerException(String message, {int? statusCode, dynamic originalError})
      : super(message, statusCode: statusCode, originalError: originalError);
}

/// Timeout exceptions
class TimeoutException extends ApiException {
  TimeoutException(String message, {dynamic originalError})
      : super(message, originalError: originalError);
}

/// Unknown exceptions
class UnknownException extends ApiException {
  UnknownException(String message, {dynamic originalError})
      : super(message, originalError: originalError);
}

