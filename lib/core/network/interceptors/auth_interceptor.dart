import 'dart:async';

import 'package:dio/dio.dart';
import 'package:naqirgiftbox/core/constants/api_endpoints.dart';
import 'package:naqirgiftbox/core/storage/secure/secure_storage_service.dart';

/// Attaches the bearer token to every request and transparently refreshes it
/// once on a 401 before retrying the original request. Concurrent 401s share
/// a single in-flight refresh via [_refreshCompleter] rather than each firing
/// their own refresh call.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.dio, required this.secureStorage});

  final Dio dio;
  final SecureStorageService secureStorage;

  static const _retriedKey = 'authRetried';

  Completer<String?>? _refreshCompleter;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await secureStorage.readAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final isUnauthorized = err.response?.statusCode == 401;
    final alreadyRetried = err.requestOptions.extra[_retriedKey] == true;

    if (!isUnauthorized || alreadyRetried) {
      handler.next(err);
      return;
    }

    final newToken = await _refreshToken();
    if (newToken == null) {
      await secureStorage.clearTokens();
      handler.next(err);
      return;
    }

    try {
      final retryOptions = err.requestOptions;
      retryOptions.extra[_retriedKey] = true;
      retryOptions.headers['Authorization'] = 'Bearer $newToken';
      final response = await dio.fetch<dynamic>(retryOptions);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  Future<String?> _refreshToken() {
    final pending = _refreshCompleter;
    if (pending != null) return pending.future;

    final completer = Completer<String?>();
    _refreshCompleter = completer;
    unawaited(_performRefresh(completer));
    return completer.future;
  }

  Future<void> _performRefresh(Completer<String?> completer) async {
    try {
      final refreshToken = await secureStorage.readRefreshToken();
      if (refreshToken == null) {
        completer.complete(null);
        return;
      }

      final response = await dio.post<Map<String, dynamic>>(
        ApiEndpoints.refreshToken,
        data: {'refresh_token': refreshToken},
        options: Options(extra: {_retriedKey: true}),
      );

      final newAccessToken = response.data?['access_token'] as String?;
      final newRefreshToken = response.data?['refresh_token'] as String?;
      if (newAccessToken != null) {
        await secureStorage.saveTokens(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
        );
      }
      completer.complete(newAccessToken);
    } catch (_) {
      completer.complete(null);
    } finally {
      _refreshCompleter = null;
    }
  }
}
