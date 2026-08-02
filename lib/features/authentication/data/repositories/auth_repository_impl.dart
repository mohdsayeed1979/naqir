import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:naqirgiftbox/core/config/app_config.dart';
import 'package:naqirgiftbox/core/error/exceptions.dart';
import 'package:naqirgiftbox/core/error/failures.dart';
import 'package:naqirgiftbox/core/error/result.dart';
import 'package:naqirgiftbox/core/storage/secure/secure_storage_service.dart';
import 'package:naqirgiftbox/features/authentication/data/datasources/auth_data_source.dart';
import 'package:naqirgiftbox/features/authentication/data/models/user_dto.dart';
import 'package:naqirgiftbox/features/authentication/domain/entities/user.dart';
import 'package:naqirgiftbox/features/authentication/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AppConfig config,
    required AuthDataSource remoteDataSource,
    required AuthDataSource mockDataSource,
    required SecureStorageService secureStorage,
    required Box<String> settingsBox,
  }) : _config = config,
       _remoteDataSource = remoteDataSource,
       _mockDataSource = mockDataSource,
       _secureStorage = secureStorage,
       _settingsBox = settingsBox;

  static const _cachedUserKey = 'cached_user';

  final AppConfig _config;
  final AuthDataSource _remoteDataSource;
  final AuthDataSource _mockDataSource;
  final SecureStorageService _secureStorage;
  final Box<String> _settingsBox;

  AuthDataSource get _dataSource =>
      _config.useMockData ? _mockDataSource : _remoteDataSource;

  @override
  Future<Result<User>> login({
    required String emailOrPhone,
    required String password,
  }) => _guard(
    () => _dataSource.login(emailOrPhone: emailOrPhone, password: password),
  );

  @override
  Future<Result<User>> register({
    required String fullName,
    required String email,
    required String password,
  }) => _guard(
    () => _dataSource.register(
      fullName: fullName,
      email: email,
      password: password,
    ),
  );

  @override
  Future<Result<void>> requestOtp({required String phone}) async {
    try {
      await _dataSource.requestOtp(phone: phone);
      return const Result.success(null);
    } on AppException catch (e) {
      return Result.failure(e.toFailure());
    } catch (_) {
      return const Result.failure(UnknownFailure());
    }
  }

  @override
  Future<Result<User>> verifyOtp({
    required String phone,
    required String code,
  }) => _guard(() => _dataSource.verifyOtp(phone: phone, code: code));

  @override
  Future<Result<void>> forgotPassword({required String email}) async {
    try {
      await _dataSource.forgotPassword(email: email);
      return const Result.success(null);
    } on AppException catch (e) {
      return Result.failure(e.toFailure());
    } catch (_) {
      return const Result.failure(UnknownFailure());
    }
  }

  @override
  Future<Result<User>> updateProfile({
    required String fullName,
    String? phone,
  }) async {
    final cached = await getCachedUser();
    if (cached == null) return const Result.failure(UnauthorizedFailure());

    try {
      final updated = await _dataSource.updateProfile(
        userId: cached.id,
        email: cached.email,
        fullName: fullName,
        phone: phone,
      );
      await _settingsBox.put(_cachedUserKey, jsonEncode(updated.toJson()));
      return Result.success(updated.toEntity());
    } on AppException catch (e) {
      return Result.failure(e.toFailure());
    } catch (_) {
      return const Result.failure(UnknownFailure());
    }
  }

  @override
  Future<User?> getCachedUser() async {
    final hasSession = await _secureStorage.hasSession;
    if (!hasSession) return null;
    final raw = _settingsBox.get(_cachedUserKey);
    if (raw == null) return null;
    try {
      return UserDto.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      ).toEntity();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> logout() async {
    await _secureStorage.clearTokens();
    await _settingsBox.delete(_cachedUserKey);
  }

  Future<Result<User>> _guard(Future<AuthResultDto> Function() action) async {
    try {
      final result = await action();
      await _secureStorage.saveTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );
      await _settingsBox.put(_cachedUserKey, jsonEncode(result.user.toJson()));
      return Result.success(result.user.toEntity());
    } on AppException catch (e) {
      return Result.failure(e.toFailure());
    } catch (_) {
      return const Result.failure(UnknownFailure());
    }
  }
}
