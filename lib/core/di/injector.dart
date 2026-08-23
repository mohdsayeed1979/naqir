import 'package:dio/dio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:naqirgiftbox/core/config/app_config.dart';
import 'package:naqirgiftbox/core/network/api_client.dart';
import 'package:naqirgiftbox/core/network/dio_factory.dart';
import 'package:naqirgiftbox/core/network/network_info.dart';
import 'package:naqirgiftbox/core/storage/hive/hive_boxes.dart';
import 'package:naqirgiftbox/core/storage/local_user_data.dart';
import 'package:naqirgiftbox/core/storage/secure/secure_storage_service.dart';
import 'package:naqirgiftbox/features/authentication/data/datasources/auth_mock_data_source.dart';
import 'package:naqirgiftbox/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:naqirgiftbox/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:naqirgiftbox/features/authentication/domain/repositories/auth_repository.dart';
import 'package:naqirgiftbox/features/categories/data/datasources/category_mock_data_source.dart';
import 'package:naqirgiftbox/features/categories/data/datasources/category_remote_data_source.dart';
import 'package:naqirgiftbox/features/categories/data/repositories/category_repository_impl.dart';
import 'package:naqirgiftbox/features/categories/domain/repositories/category_repository.dart';
import 'package:naqirgiftbox/features/notifications/data/notification_service.dart';
import 'package:naqirgiftbox/features/payment/data/gateways/cash_on_delivery_gateway.dart';
import 'package:naqirgiftbox/features/payment/data/gateways/unconfigured_gateway.dart';
import 'package:naqirgiftbox/features/payment/data/repositories/payment_gateway_factory.dart';
import 'package:naqirgiftbox/features/payment/domain/entities/payment.dart';
import 'package:naqirgiftbox/features/products/data/datasources/product_mock_data_source.dart';
import 'package:naqirgiftbox/features/products/data/datasources/product_remote_data_source.dart';
import 'package:naqirgiftbox/features/products/data/repositories/product_repository_impl.dart';
import 'package:naqirgiftbox/features/products/domain/repositories/product_repository.dart';

final GetIt getIt = GetIt.instance;

/// Registers every cross-cutting service, then each feature's data
/// sources/repositories via a private `_configureXFeature()` helper below —
/// one per feature, called from here as each feature is built.
Future<void> configureDependencies() async {
  final config = AppConfig.fromEnvironment();
  getIt.registerSingleton<AppConfig>(config);

  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );
  getIt.registerLazySingleton<SecureStorageService>(
    () => SecureStorageService(getIt<FlutterSecureStorage>()),
  );
  getIt.registerLazySingleton<LocalUserDataStore>(
    () => LocalUserDataStore(getIt<SecureStorageService>()),
  );

  getIt.registerLazySingleton<InternetConnection>(InternetConnection.new);
  getIt.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(getIt<InternetConnection>()),
  );

  getIt.registerLazySingleton<Dio>(
    () => buildDio(
      config: getIt<AppConfig>(),
      secureStorage: getIt<SecureStorageService>(),
    ),
  );
  getIt.registerLazySingleton<ApiClient>(() => ApiClient(getIt<Dio>()));

  _configureAuthFeature();
  _configureProductsFeature();
  _configureCategoriesFeature();
  _configurePaymentFeature();
  _configureNotificationsFeature();
}

void _configureAuthFeature() {
  getIt.registerLazySingleton<AuthMockDataSource>(AuthMockDataSource.new);
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      config: getIt<AppConfig>(),
      remoteDataSource: getIt<AuthRemoteDataSource>(),
      mockDataSource: getIt<AuthMockDataSource>(),
      secureStorage: getIt<SecureStorageService>(),
      localUserData: getIt<LocalUserDataStore>(),
      settingsBox: HiveBoxes.settings,
    ),
  );
}

void _configureProductsFeature() {
  getIt.registerLazySingleton<ProductMockDataSource>(ProductMockDataSource.new);
  getIt.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSource(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(
      config: getIt<AppConfig>(),
      remoteDataSource: getIt<ProductRemoteDataSource>(),
      mockDataSource: getIt<ProductMockDataSource>(),
    ),
  );
}

void _configureCategoriesFeature() {
  getIt.registerLazySingleton<CategoryMockDataSource>(
    CategoryMockDataSource.new,
  );
  getIt.registerLazySingleton<CategoryRemoteDataSource>(
    () => CategoryRemoteDataSource(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(
      config: getIt<AppConfig>(),
      remoteDataSource: getIt<CategoryRemoteDataSource>(),
      mockDataSource: getIt<CategoryMockDataSource>(),
    ),
  );
}

void _configurePaymentFeature() {
  getIt.registerLazySingleton<PaymentGatewayFactory>(
    () => PaymentGatewayFactory({
      PaymentMethodType.cashOnDelivery: CashOnDeliveryGateway(),
      PaymentMethodType.creditCard: const UnconfiguredGateway(
        PaymentMethodType.creditCard,
        'Card payments',
      ),
      PaymentMethodType.applePay: const UnconfiguredGateway(
        PaymentMethodType.applePay,
        'Apple Pay',
      ),
      PaymentMethodType.googlePay: const UnconfiguredGateway(
        PaymentMethodType.googlePay,
        'Google Pay',
      ),
    }),
  );
}

void _configureNotificationsFeature() {
  getIt.registerLazySingleton<FlutterLocalNotificationsPlugin>(
    FlutterLocalNotificationsPlugin.new,
  );
  getIt.registerLazySingleton<NotificationService>(
    () => NotificationService(getIt<FlutterLocalNotificationsPlugin>()),
  );
}
