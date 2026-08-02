import 'dart:math';

import 'package:dio/dio.dart';

/// Retries idempotent (GET) requests on transient network failures with
/// exponential backoff. Never retries POST/PUT/PATCH/DELETE — retrying a
/// non-idempotent request risks double-submitting (e.g. placing an order
/// twice).
class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    this.maxRetries = 2,
    this.baseDelay = const Duration(milliseconds: 500),
  });

  final int maxRetries;
  final Duration baseDelay;

  static const _attemptKey = 'retryAttempt';

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final attempt = (options.extra[_attemptKey] as int?) ?? 0;

    final canRetry =
        options.method.toUpperCase() == 'GET' &&
        _isTransient(err) &&
        attempt < maxRetries;

    if (!canRetry) {
      handler.next(err);
      return;
    }

    await Future<void>.delayed(baseDelay * pow(2, attempt));

    try {
      options.extra[_attemptKey] = attempt + 1;
      final retryDio = Dio(BaseOptions(baseUrl: options.baseUrl));
      final response = await retryDio.fetch<dynamic>(options);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  bool _isTransient(DioException err) => switch (err.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.receiveTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.connectionError => true,
    _ => false,
  };
}
