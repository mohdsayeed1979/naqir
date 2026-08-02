import 'package:naqirgiftbox/core/error/exceptions.dart';

/// Presentation-facing error type. ViewModels switch on [Failure], never on
/// the underlying [AppException] — that stays inside the data layer.
sealed class Failure {
  const Failure(this.message);

  final String message;
}

final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection.']);
}

final class ServerFailure extends Failure {
  const ServerFailure(super.message, {this.statusCode});

  final int? statusCode;
}

final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([
    super.message = 'Session expired. Please log in again.',
  ]);
}

final class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {this.fieldErrors = const {}});

  final Map<String, String> fieldErrors;
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Not found.']);
}

final class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Unable to load local data.']);
}

final class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Something went wrong.']);
}

extension AppExceptionToFailure on AppException {
  /// Maps a data-layer exception to its presentation-facing [Failure].
  Failure toFailure() => switch (this) {
    NetworkException(:final message) => NetworkFailure(message),
    ServerException(:final message, :final statusCode) => ServerFailure(
      message,
      statusCode: statusCode,
    ),
    UnauthorizedException(:final message) => UnauthorizedFailure(message),
    ValidationException(:final message, :final fieldErrors) =>
      ValidationFailure(message, fieldErrors: fieldErrors),
    NotFoundException(:final message) => NotFoundFailure(message),
    CacheException(:final message) => CacheFailure(message),
    UnknownException(:final message) => UnknownFailure(message),
  };
}
