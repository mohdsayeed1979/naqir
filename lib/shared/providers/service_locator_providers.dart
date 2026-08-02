import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naqirgiftbox/core/config/app_config.dart';
import 'package:naqirgiftbox/core/di/injector.dart';
import 'package:naqirgiftbox/core/network/network_info.dart';

/// Bridges GetIt-registered cross-cutting services into Riverpod so
/// ViewModels only ever depend on `ref`, never reach into GetIt directly.
/// Feature repository providers follow the same pattern colocated in each
/// feature's `presentation/providers` folder.
final appConfigProvider = Provider<AppConfig>((ref) => getIt<AppConfig>());

final networkInfoProvider = Provider<NetworkInfo>(
  (ref) => getIt<NetworkInfo>(),
);
