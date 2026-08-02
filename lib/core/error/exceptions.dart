/// Exceptions thrown by data sources (remote/local). Repositories catch these
/// and map them to [Failure]s — the presentation layer never sees an
/// [AppException] directly.
sealed class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}

final class NetworkException extends AppException {
  const NetworkException([super.message = 'No internet connection.']);
}

final class ServerException extends AppException {
  const ServerException(super.message, {this.statusCode});

  final int? statusCode;
}

final class UnauthorizedException extends AppException {
  const UnauthorizedException([
    super.message = 'Session expired. Please log in again.',
  ]);
}

final class ValidationException extends AppException {
  const ValidationException(super.message, {this.fieldErrors = const {}});

  final Map<String, String> fieldErrors;
}

final class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Not found.']);
}

final class CacheException extends AppException {
  const CacheException([super.message = 'Unable to read local data.']);
}

final class UnknownException extends AppException {
  const UnknownException([super.message = 'Something went wrong.']);
}
