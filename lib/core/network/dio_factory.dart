import 'package:dio/dio.dart';
import 'package:naqirgiftbox/core/config/app_config.dart';
import 'package:naqirgiftbox/core/network/interceptors/auth_interceptor.dart';
import 'package:naqirgiftbox/core/network/interceptors/logging_interceptor.dart';
import 'package:naqirgiftbox/core/network/interceptors/retry_interceptor.dart';
import 'package:naqirgiftbox/core/storage/secure/secure_storage_service.dart';

Dio buildDio({
  required AppConfig config,
  required SecureStorageService secureStorage,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: config.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      headers: const {'Accept': 'application/json'},
    ),
  );

  dio.interceptors.addAll([
    if (config.enableRequestLogging) LoggingInterceptor(),
    RetryInterceptor(),
    AuthInterceptor(dio: dio, secureStorage: secureStorage),
  ]);

  // Certificate-pinning hook point: once the real API host is known, attach
  // an HttpClientAdapter here that validates against pinned certificates
  // (see docs/ARCHITECTURE.md §10). Left disabled — pinning against an
  // unknown/placeholder host would just break every request.

  return dio;
}
