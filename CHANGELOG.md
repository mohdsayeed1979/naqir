# Changelog

All notable changes to this project are documented here.
Format loosely follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]

### Added
- Project analysis of naqirgiftbox.com (Zid-powered storefront) and full architecture plan
  (`docs/ARCHITECTURE.md`, `PROJECT_PROGRESS.md`).
- Flutter project scaffold (Android/iOS/Web/Windows) with full dependency set: Riverpod, go_router,
  Dio, Freezed/json_serializable, get_it, Hive, flutter_secure_storage, cached_network_image,
  photo_view, connectivity_plus, google_fonts, Firebase (core/messaging/analytics/crashlytics),
  flutter_local_notifications, reactive_forms, shimmer, and supporting utility packages.
- Clean-architecture folder structure (`core/`, `shared/`, `features/*` with data/domain/presentation
  layers).
- Brand assets: app icon, adaptive icon, and light/dark splash logo (generated gift-box mark in the
  brand palette); native launcher icons and splash screens wired for Android/iOS.
- Localization scaffolding: `l10n.yaml` + English/Arabic ARB source files covering the core app
  shell, auth, home, products, cart, checkout, orders, profile, and settings copy.
- Git repository initialized.

- Core infrastructure: Material 3 theme (explicit brand `ColorScheme`, locale-aware typography),
  go_router `StatefulShellRoute` bottom-nav shell with auth-gated redirects, GetIt+Riverpod DI
  bridge, Dio network layer (auth-refresh/retry/logging interceptors, typed `Result`/`Failure`
  error mapping), Hive-backed local storage, `runZonedGuarded` error boundary.
- Full feature set running end-to-end against mock data: splash, onboarding, authentication
  (login/register/OTP/forgot-password), home, categories, product listing (filters/sort/infinite
  scroll), product details (zoomable gallery, variants, specs, reviews, related/recently-viewed),
  search (history/trending/voice), wishlist, cart (coupons), checkout (address book/shipping),
  orders (history/detail/tracking timeline), profile & settings (dark mode, language switch,
  About/Contact/FAQ/Privacy/Terms).
- Payment architecture: `PaymentGateway` interface + factory; Cash on Delivery is a real working
  gateway, Stripe/Moyasar/HyperPay/Apple Pay/Google Pay are registered as clearly-labeled
  unconfigured stubs pending merchant credentials.
- Real product/category/review mock catalog (15 products across 6 categories) with generated,
  on-brand placeholder imagery — no external image hosts or hotlinked assets.
- One real widget test (`test/widget_test.dart`) covering `PrimaryButton`; full suite tracked as
  its own milestone.

### Changed
- Pinned `flutter_riverpod`/`riverpod` to the 2.6.1 stable line — Riverpod 3.x's current release
  pulls a `test`/`analyzer` chain that conflicts with `json_serializable` under this Flutter SDK.
- Dropped `riverpod_generator`, `hive_generator`, `custom_lint`/`riverpod_lint` after confirming real
  version conflicts (documented in `docs/ARCHITECTURE.md`); Riverpod providers are hand-written and
  Hive stores JSON via the existing Freezed `toJson`/`fromJson` instead of generated TypeAdapters.

## [Unreleased] (continued 2)

### Changed
- Replaced the generated placeholder gift-box glyph with the real "نقير التمر" brand logo
  (confirmed by the user) across the launcher icon, splash screen, and in-app brand mark — same
  asset file paths, so no Dart code changed.
- Dropped the Android adaptive-icon config: the real logo has no transparent-background version to
  use as an adaptive-icon foreground layer. A flat (non-adaptive) launcher icon works fine without
  one; revisit once a proper source asset exists.

### Known issue
- The supplied logo source is only 252×240px. Generated icons at or below that size (app launcher,
  favicon, most in-app uses) look correct; icons that must scale *above* it — notably the 1024×1024
  iOS App Store icon and 512×512 Android Play Store icon — show visible softness. Get a high-
  resolution (1024×1024 minimum, ideally vector) source from the business before store submission.

## [Unreleased] (continued)

### Added
- `NotificationService` (FCM + `flutter_local_notifications`), Firebase-gated the same way payment
  gateways are — every method safely no-ops until `AppConfig.firebaseEnabled` is on and a real
  Firebase project is wired via `flutterfire configure`.
- Notification preferences screen (order updates / promotions / new arrivals), reachable from both
  Profile and Settings, replacing a dead placeholder toggle that didn't persist anything.
- App-wide offline banner (`OfflineBanner`, wired into `MaterialApp.router`'s `builder`) — the
  `connectivityStatusProvider` built earlier was wired up but never actually consumed until now.
- Automated test suite: unit tests for `Result`, `CartNotifier` (add/increment/remove/coupon
  apply-and-fail/clear), and `ProductRepositoryImpl` (success/failure/pagination mapping); widget
  tests for `PrimaryButton` and `ProductCard`; one `integration_test` happy path (browse → product
  detail → add to cart → cart tab).

### Fixed
- `permission_handler` pinned to `12.0.3` (pulling `permission_handler_android ^13.0.0`) — the
  default `14.0.0` requires AGP 9.x/Kotlin 2.3.x, newer than the AGP 8.9.1/Kotlin 2.1.0 this
  project (and most current stable Flutter Android projects) run on. Confirmed by an actual
  `flutter build apk` failure, not a hypothetical.
- Enabled Android core library desugaring (`android/app/build.gradle.kts`) — required by
  `flutter_local_notifications`' use of `java.time` APIs below API 26.
- Fixed two real bugs in `NotificationService` caught by `flutter analyze` after being missed
  initially: `FlutterLocalNotificationsPlugin.initialize()`/`.show()` take named parameters, not
  positional ones.

### Verified
- `flutter analyze`: zero issues across the full codebase (~150 files).
- `flutter build web --release`: succeeds (dart2js + tree-shaking + Wasm-compatibility dry run).
- `flutter build apk --debug`: succeeds, after accepting Android SDK licenses and the
  `permission_handler` fix above.
- `flutter build windows --debug`: succeeds, after installing Visual Studio Build Tools 2022 with
  the "Desktop development with C++" workload plus the ATL component specifically (the default
  workload install doesn't include ATL, which `flutter_local_notifications_windows` and
  `flutter_secure_storage_windows` both need).
- `flutter test`: 19 tests, all passing.
- Runtime smoke check via browser devtools: Hive opens all boxes, DI configures, the widget tree
  builds through to the splash screen (confirmed by its asset being fetched), zero console errors.
  Pixel-level visual verification is still pending — the Browser preview pane wasn't displayed this
  session, which prevents frame compositing independent of app correctness.
