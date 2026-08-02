import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Single-line request/response logging. Deliberately never logs headers or
/// bodies — the Authorization header carries the bearer token and must never
/// end up in logs.
class LoggingInterceptor extends Interceptor {
  final _stopwatches = <RequestOptions, Stopwatch>{};

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _stopwatches[options] = Stopwatch()..start();
    debugPrint('→ ${options.method} ${options.uri}');
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final elapsedMs = _stopwatches
        .remove(response.requestOptions)
        ?.elapsedMilliseconds;
    debugPrint(
      '← ${response.statusCode} ${response.requestOptions.uri} (${elapsedMs}ms)',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final elapsedMs = _stopwatches
        .remove(err.requestOptions)
        ?.elapsedMilliseconds;
    debugPrint(
      '✕ ${err.response?.statusCode ?? '-'} ${err.requestOptions.uri} '
      '(${elapsedMs}ms): ${err.message}',
    );
    handler.next(err);
  }
}
