import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

/// Abstraction over connectivity so repositories/notifiers don't depend on
/// a specific package directly (and tests can fake it easily).
abstract class NetworkInfo {
  Future<bool> get isConnected;
  Stream<bool> get onConnectivityChanged;
}

/// Backed by [InternetConnection] (`internet_connection_checker_plus`) which
/// verifies actual reachability rather than just radio/adapter state — a
/// device can be Wi-Fi-connected with no real internet access.
class NetworkInfoImpl implements NetworkInfo {
  NetworkInfoImpl(this._checker);

  final InternetConnection _checker;

  @override
  Future<bool> get isConnected => _checker.hasInternetAccess;

  @override
  Stream<bool> get onConnectivityChanged => _checker.onStatusChange.map(
    (status) => status == InternetStatus.connected,
  );
}
