# Deployment Guide

Everything in this app runs against mock data today. This is the checklist for turning each piece
on for real, plus release/store submission steps.

## 1. Backend (Zid Partner API or custom)

1. Register a Zid Partner Application for the store (or stand up a custom backend implementing
   [docs/API.md](API.md)'s contract).
2. Set `AppConfig.apiBaseUrl` via `--dart-define=API_BASE_URL=https://...` at build time.
3. Set `--dart-define=FLAVOR=production` (or `development`) — this flips
   `AppConfig.useMockData` to `false`, which switches every repository from its
   `MockDataSource` to its `RemoteDataSource`. No other code changes.
4. If the real API's auth flow differs from `docs/API.md` (e.g., Zid's OAuth2 dance instead of
   simple bearer tokens), adapt `AuthRemoteDataSource`
   (`lib/features/authentication/data/datasources/auth_remote_data_source.dart`) — it's the only
   place that needs to change.

## 2. Firebase (push notifications, analytics, crashlytics)

1. Create a Firebase project.
2. Run `flutterfire configure` from the project root — this needs the Firebase CLI and your own
   Google account login, so it must be run by the business, not handed off. It generates
   `lib/firebase_options.dart` and the platform config files
   (`google-services.json`, `GoogleService-Info.plist`) — all deliberately gitignored (see
   `.gitignore`) since they're per-project.
3. Pass `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)` in
   `lib/bootstrap.dart`'s `_initializeFirebaseIfEnabled()` (currently calls the no-args overload,
   which relies on native config files existing).
4. Build/run with `--dart-define=FIREBASE_ENABLED=true`.
5. **Android only**: apply the `com.google.gms.google-services` Gradle plugin in
   `android/settings.gradle.kts` and `android/app/build.gradle.kts` — deliberately **not** applied
   yet, because doing so before `google-services.json` exists breaks the Android build for anyone
   without a Firebase project.
6. Wire Crashlytics: `lib/bootstrap.dart` has a marked hook point in `FlutterError.onError` to call
   `FirebaseCrashlytics.instance.recordFlutterError`/`.recordError`.

## 3. Payments

`lib/features/payment/` has the full architecture: `PaymentGateway` interface,
`PaymentGatewayFactory`, and a working `CashOnDeliveryGateway`. The other four methods
(`lib/features/payment/data/gateways/unconfigured_gateway.dart`) return a clear "not connected
yet" failure until wired. To add a real one:

1. Add the SDK: `flutter pub add flutter_stripe` (or the Moyasar/HyperPay equivalent — HyperPay
   has no official Flutter SDK; budget time for a platform-channel wrapper or a community package
   audit).
2. Implement `PaymentGateway` for it (mirror `CashOnDeliveryGateway`'s shape).
3. Register it in `_configurePaymentFeature()` (`lib/core/di/injector.dart`), replacing the
   matching `UnconfiguredGateway` entry.
4. Follow the SDK's native setup (Android Gradle/iOS Podfile changes, API keys via
   `--dart-define`, never hardcoded).

No checkout UI changes are needed — the payment method list in `CheckoutScreen`
(`lib/features/checkout/presentation/screens/checkout_screen.dart`) already iterates
`PaymentMethodType.values`.

**Apple Pay / Google Pay** additionally need merchant IDs registered with Apple/Google and
platform-specific entitlements (`Runner.entitlements` for Apple Pay; `<meta-data>` in
`AndroidManifest.xml` for Google Pay) — follow `flutter_stripe`'s (or your chosen SDK's) setup
guide for those, since they piggyback on the card-payment SDK rather than being separate.

## 4. Android release

1. Generate an upload keystore (never commit it — already covered by `.gitignore`):
   ```bash
   keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
2. Create `android/key.properties` (gitignored) pointing at it.
3. Wire `android/app/build.gradle.kts`'s `signingConfigs` to read `key.properties` (currently
   signs release builds with the debug key so `flutter run --release` works out of the box —
   replace before shipping).
4. `flutter build appbundle --release` and upload to Play Console.
5. Accept the Android SDK licenses on any new build machine:
   `flutter doctor --android-licenses`.

## 5. iOS release

Requires a Mac with Xcode — not available on the machine this project was built on. The code is
iOS-ready (no Windows-only APIs used); once on a Mac:

1. Open `ios/Runner.xcworkspace` in Xcode, set your Team/Bundle ID.
2. `flutter build ipa --release`.
3. Upload via Xcode Organizer or `xcrun altool`/Transporter.

## 6. Windows release

1. Install Visual Studio Build Tools 2022, "Desktop development with C++" workload **plus the ATL
   component** (see [INSTALLATION.md](INSTALLATION.md#windows-desktop-build-gotcha) — the default
   workload install is missing it, confirmed by an actual build failure).
2. `flutter build windows --release`.
3. Package `build/windows/x64/runner/Release/` — MSIX (`flutter pub add msix` as a dev dependency)
   is the modern path for Microsoft Store distribution; a plain installer (Inno Setup, etc.) works
   for direct distribution.

## 7. Web hosting

```bash
flutter build web --release
```

Deploy `build/web/` to any static host (Firebase Hosting pairs naturally if Firebase is already in
use; Cloudflare Pages, Netlify, S3+CloudFront, or the business's existing infrastructure all work
equally well). No server-side rendering is required.

## 8. Brand assets

The real logo supplied (`assets/icons/logo.jpg`) is 252×240px, which is below the recommended
source size for app icons (1024×1024 for iOS App Store, 512×512 for Play Store) — generated icons
at those sizes are visibly soft. Get a higher-resolution (ideally vector/AI/EPS) source from the
business, then re-run:

```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

A transparent-background version would also let you re-enable the Android adaptive icon
foreground/background split in `pubspec.yaml`'s `flutter_launcher_icons` config (removed for now —
see CHANGELOG).

## 9. Certificate pinning

`lib/core/network/dio_factory.dart` has a marked hook point for certificate pinning once the real
API host is known — pinning against a placeholder host would just break every request today, so
it's deliberately left disabled.
