import 'package:dio/dio.dart';
import 'package:naqirgiftbox/core/error/exceptions.dart';

/// Thin wrapper around [Dio] that maps every [DioException] to a typed
/// [AppException] at the boundary — repositories never handle raw Dio
/// exceptions.
class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) => _guard(() => _dio.get<T>(path, queryParameters: queryParameters));

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) => _guard(
    () => _dio.post<T>(path, data: data, queryParameters: queryParameters),
  );

  Future<Response<T>> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) => _guard(
    () => _dio.put<T>(path, data: data, queryParameters: queryParameters),
  );

  Future<Response<T>> patch<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) => _guard(
    () => _dio.patch<T>(path, data: data, queryParameters: queryParameters),
  );

  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) => _guard(
    () => _dio.delete<T>(path, data: data, queryParameters: queryParameters),
  );

  Future<Response<T>> _guard<T>(Future<Response<T>> Function() request) async {
    try {
      return await request();
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  AppException _mapDioException(DioException error) => switch (error.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout ||
    DioExceptionType.connectionError => const NetworkException(),
    DioExceptionType.badCertificate => const NetworkException(
      'Secure connection failed.',
    ),
    DioExceptionType.cancel => const UnknownException('Request cancelled.'),
    DioExceptionType.badResponse => _mapStatusCode(error.response),
    DioExceptionType.unknown => const NetworkException(),
    _ => const NetworkException(),
  };

  AppException _mapStatusCode(Response<dynamic>? response) {
    final statusCode = response?.statusCode;
    final message =
        _extractMessage(response) ?? 'Server error. Please try again.';
    return switch (statusCode) {
      400 => ValidationException(
        message,
        fieldErrors: _extractFieldErrors(response),
      ),
      401 => UnauthorizedException(message),
      404 => NotFoundException(message),
      _ => ServerException(message, statusCode: statusCode),
    };
  }

  String? _extractMessage(Response<dynamic>? response) {
    final data = response?.data;
    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }
    return null;
  }

  Map<String, String> _extractFieldErrors(Response<dynamic>? response) {
    final data = response?.data;
    if (data is Map && data['errors'] is Map) {
      final errors = data['errors'] as Map;
      return errors.map(
        (key, value) => MapEntry(
          key.toString(),
          value is List && value.isNotEmpty
              ? value.first.toString()
              : value.toString(),
        ),
      );
    }
    return const {};
  }
}
