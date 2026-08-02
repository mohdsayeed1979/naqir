/// Which data source backs every repository. See docs/ARCHITECTURE.md §1.
enum Flavor { mock, development, production }

/// Central, immutable runtime configuration. Built once at bootstrap from
/// `--dart-define` values and registered in GetIt — nothing in the app reads
/// environment variables directly.
class AppConfig {
  const AppConfig({
    required this.flavor,
    required this.apiBaseUrl,
    required this.firebaseEnabled,
    required this.enableRequestLogging,
  });

  factory AppConfig.fromEnvironment() {
    const flavorName = String.fromEnvironment('FLAVOR', defaultValue: 'mock');
    final flavor = Flavor.values.firstWhere(
      (f) => f.name == flavorName,
      orElse: () => Flavor.mock,
    );
    return AppConfig(
      flavor: flavor,
      apiBaseUrl: const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'https://api.naqirgiftbox.example/v1',
      ),
      firebaseEnabled: const bool.fromEnvironment('FIREBASE_ENABLED'),
      enableRequestLogging: flavor != Flavor.production,
    );
  }

  final Flavor flavor;
  final String apiBaseUrl;
  final bool firebaseEnabled;
  final bool enableRequestLogging;

  /// When true, repositories read from in-memory/fixture data instead of
  /// calling [apiBaseUrl]. Defaults to true until real backend credentials
  /// (Zid Partner API OAuth, or another backend) are available.
  bool get useMockData => flavor == Flavor.mock;
}
