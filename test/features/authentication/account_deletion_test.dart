import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:naqirgiftbox/core/config/app_config.dart';
import 'package:naqirgiftbox/core/error/exceptions.dart';
import 'package:naqirgiftbox/core/error/failures.dart';
import 'package:naqirgiftbox/core/storage/local_user_data.dart';
import 'package:naqirgiftbox/core/storage/secure/secure_storage_service.dart';
import 'package:naqirgiftbox/features/authentication/data/datasources/auth_data_source.dart';
import 'package:naqirgiftbox/features/authentication/data/repositories/auth_repository_impl.dart';

class _MockAuthDataSource extends Mock implements AuthDataSource {}

class _MockSecureStorage extends Mock implements SecureStorageService {}

class _MockLocalUserData extends Mock implements LocalUserDataStore {}

class _MockSettingsBox extends Mock implements Box<String> {}

const _config = AppConfig(
  flavor: Flavor.mock,
  apiBaseUrl: 'https://example.test/v1',
  firebaseEnabled: false,
  enableRequestLogging: false,
);

const _userJson = {
  'id': 'user-1',
  'full_name': 'Test User',
  'email': 'test@example.com',
};

void main() {
  late _MockAuthDataSource remote;
  late _MockAuthDataSource mock;
  late _MockSecureStorage secureStorage;
  late _MockLocalUserData localUserData;
  late _MockSettingsBox settingsBox;
  late AuthRepositoryImpl repository;

  AuthRepositoryImpl build() => AuthRepositoryImpl(
    config: _config,
    remoteDataSource: remote,
    mockDataSource: mock,
    secureStorage: secureStorage,
    localUserData: localUserData,
    settingsBox: settingsBox,
  );

  void signedIn() {
    when(() => secureStorage.hasSession).thenAnswer((_) async => true);
    when(() => settingsBox.get('cached_user')).thenReturn(jsonEncode(_userJson));
  }

  void signedOut() {
    when(() => secureStorage.hasSession).thenAnswer((_) async => false);
  }

  setUp(() {
    remote = _MockAuthDataSource();
    mock = _MockAuthDataSource();
    secureStorage = _MockSecureStorage();
    localUserData = _MockLocalUserData();
    settingsBox = _MockSettingsBox();
    when(() => localUserData.clearAll()).thenAnswer((_) async {});
    when(() => settingsBox.delete(any())).thenAnswer((_) async {});
    repository = build();
  });

  group('deleteAccount', () {
    test('fails with UnauthorizedFailure and wipes nothing when signed out',
        () async {
      signedOut();

      final result = await repository.deleteAccount();

      expect(result.failureOrNull, isA<UnauthorizedFailure>());
      verifyNever(() => mock.deleteAccount());
      verifyNever(() => localUserData.clearAll());
    });

    test('erases all local data and succeeds when the backend call succeeds',
        () async {
      signedIn();
      when(() => mock.deleteAccount()).thenAnswer((_) async {});

      final result = await repository.deleteAccount();

      expect(result.isSuccess, isTrue);
      verify(() => mock.deleteAccount()).called(1);
      verify(() => localUserData.clearAll()).called(1);
    });

    test('keeps local data intact and reports failure when backend throws',
        () async {
      signedIn();
      when(() => mock.deleteAccount())
          .thenThrow(const ServerException('server said no'));

      final result = await repository.deleteAccount();

      expect(result.failureOrNull, isA<ServerFailure>());
      // The honest-failure contract: nothing is wiped if deletion failed.
      verifyNever(() => localUserData.clearAll());
    });
  });
}
