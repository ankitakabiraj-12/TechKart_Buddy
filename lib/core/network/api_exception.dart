class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic details;

  const ApiException({
    required this.message,
    this.statusCode,
    this.details,
  });

  @override
  String toString() {
    return 'ApiException(statusCode: $statusCode, message: $message, details: $details)';
  }
}

class NetworkException extends ApiException {
  const NetworkException({
    super.message = 'Unable to connect to server. Please check your internet connection or server status.',
  }) : super(statusCode: 0);
}

class ConnectionTimeoutException extends ApiException {
  const ConnectionTimeoutException({
    super.message = 'Connection timed out while establishing link to server.',
  }) : super(statusCode: 408);
}

class ResponseTimeoutException extends ApiException {
  const ResponseTimeoutException({
    super.message = 'Server took too long to respond. Request timed out.',
  }) : super(statusCode: 504);
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException({
    super.message = 'Session expired or unauthorized. Please log in again.',
    super.details,
  }) : super(statusCode: 401);
}

class ForbiddenException extends ApiException {
  const ForbiddenException({
    super.message = 'Access forbidden. You do not have seller/admin permissions for this resource.',
    super.details,
  }) : super(statusCode: 403);
}

class NotFoundException extends ApiException {
  const NotFoundException({
    super.message = 'Requested resource was not found.',
    super.details,
  }) : super(statusCode: 404);
}

class ValidationException extends ApiException {
  const ValidationException({
    required super.message,
    super.details,
  }) : super(statusCode: 422);
}

class ServerException extends ApiException {
  const ServerException({
    super.message = 'Internal server error. Please try again later.',
    super.statusCode = 500,
    super.details,
  });
}
