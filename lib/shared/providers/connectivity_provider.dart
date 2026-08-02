import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naqirgiftbox/shared/providers/service_locator_providers.dart';

/// Emits `true`/`false` as real internet reachability changes. Widgets that
/// need an offline banner watch this rather than polling.
final connectivityStatusProvider = StreamProvider<bool>((ref) {
  final networkInfo = ref.watch(networkInfoProvider);
  return networkInfo.onConnectivityChanged;
});
