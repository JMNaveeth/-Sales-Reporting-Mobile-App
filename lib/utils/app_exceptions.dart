/// Base exception for all application-level errors
class AppException implements Exception {
  const AppException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Network-level errors (timeouts, no connection)
class NetworkException extends AppException {
  const NetworkException(super.message);
}

/// 401 / 403 authentication errors
class AuthException extends AppException {
  const AuthException(super.message);
}

/// 404 not-found errors
class NotFoundException extends AppException {
  const NotFoundException(super.message);
}

/// 422 / 400 validation errors
class ValidationException extends AppException {
  const ValidationException(super.message);
}

/// 5xx server errors
class ServerException extends AppException {
  const ServerException(super.message);
}
