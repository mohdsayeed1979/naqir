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
- `flutter build ios --no-codesign`: succeeds (`Runner.app` 49.2MB built in 50.7s on Xcode 26.6 / macOS).
- `flutter build ipa --release` (Build 2): succeeds with `MinimumOSVersion = 15.0`, `CFBundleVersion = 2`, `CFBundleShortVersionString = 1.0.0`, verified signed with production App Store profile `Naqir Gift Box App Store`.
- `flutter build windows --debug`: succeeds, after installing Visual Studio Build Tools 2022 with
  the "Desktop development with C++" workload plus the ATL component specifically (the default
  workload install doesn't include ATL, which `flutter_local_notifications_windows` and
  `flutter_secure_storage_windows` both need).
- `flutter test`: 19 tests, all passing.
- Runtime smoke check via browser devtools: Hive opens all boxes, DI configures, the widget tree
  builds through to the splash screen (confirmed by its asset being fetched), zero console errors.
  Pixel-level visual verification is still pending — the Browser preview pane wasn't displayed this
  session, which prevents frame compositing independent of app correctness.

## [Unreleased] — Real product catalog & images

### Added
- Replaced the 15-product invented placeholder catalog with the real 191-product catalog scraped
  from naqirgiftbox.com's own public, unauthenticated storefront API (`/api/v1/products`) — real
  SKUs, names, prices, stock quantities, and original-resolution photos for every product, including
  per-variant photos for the 73 "available in several options" products (182/189 variants resolved
  to their own distinct photo; the remainder fall back to the parent product's gallery).
- `ProductImageMapping` (`lib/features/products/data/datasources/product_image_mapping.dart`):
  SKU → bundled local asset path, plus remote gallery/variant image maps for the extended
  photos that are served live rather than bundled (see rationale below).
- 191 real product photos downloaded, re-encoded to JPEG (longest edge capped at 1000px, quality 82)
  and bundled at `assets/images/products/<SKU>.jpg` — replacing the 7 generated placeholder box
  images, which were deleted.
- Three real product-line categories (Termeh Box / Termeh Chest / Gift Box), replacing the 6
  invented ones — derived directly from the real product naming already present in every SKU/slug,
  since the live storefront itself only exposes one "Gift box" category.
- `scripts/scraping/` — the reproducible pipeline that produced the above (`fetch_catalog.py`
  pulls the raw API data, `build_catalog.py` consolidates it, `download_images.py` downloads and
  compresses the photos, `generate_dart.py` regenerates the three Dart files above). Kept as an
  audit trail / re-run path, not an app dependency.

### Changed
- `pubspec.yaml`: moved `integration_test` and `flutter_native_splash` from `dev_dependencies` to
  regular `dependencies` — see Fixed below.

### Fixed
- Real, reproducible Android **release** build failure (`flutter build apk --release`), unrelated
  to the catalog work above but blocking it: `GeneratedPluginRegistrant.java` unconditionally
  references every plugin with an Android `pluginClass`, while the Flutter Gradle plugin correctly
  excludes `dev_dependency`-only plugins from the release compile classpath — the two disagree,
  so the release build fails with "package ... does not exist" for any dev-dependency plugin that
  declares an Android plugin class (here: `integration_test`, standard Flutter SDK boilerplate, and
  `flutter_native_splash`). Root-caused by reading the installed Flutter 3.35.3 SDK's own
  `flutter_tools` source (`_writeAndroidPluginRegistrant` doesn't apply the same dev-dependency
  filter the Gradle-side `PluginHandler.kt` does) — this is a genuine SDK inconsistency, not a
  project misconfiguration, and would affect any Flutter 3.35.3 project using either package.
  Neither package is called at runtime by `lib/`, so moving them to regular dependencies has no
  behavioral effect beyond fixing the classpath mismatch.

### Architecture note — why images aren't all bundled locally
Each product's **primary** photo is a bundled local asset (fast, offline-capable, what every
listing/card surface uses). Extended galleries and per-variant photos are served through the
existing `CachedNetworkImage` path (`AppImage`'s tier 2) straight from the original
`media.zid.store` URLs instead of also being bundled — bundling all ~580 gallery/variant photos
locally would have added on the order of 150–250MB to the app; this way the release APK grew by
~11MB (55.8MB → 67.0MB) while every surface still shows a real, correct photo, just via two tiers
depending on where it's shown, matching the specified local-asset → remote → placeholder fallback
chain.

### Verified
- `flutter analyze`: zero issues.
- `flutter test`: 19/19 passing (two test fixtures updated to reference a real asset filename
  after the placeholder images were removed).
- `flutter build apk --release`: succeeds, 67.0MB (`build/app/outputs/flutter-apk/app-release.apk`).
- Data pipeline self-verified: 191/191 products matched to a real website image, 191/191 downloaded
  successfully (0 failures), 191/191 mapped in `ProductImageMapping`. See
  `scripts/scraping/verification_table.csv` for the full per-product table.
- UI wiring verified by reading (not modifying) the consuming widgets: `ProductCard`/`AppImage`
  already resolve asset-vs-network per string prefix, and `product_detail_screen.dart` already
  merges `product.images` with every `variant.imageUrl` into one deduped gallery — so populating
  real image data was sufficient with zero UI code changes needed on Home, Listing, Details,
  Search, Categories, Cart, or Wishlist.
- Pixel-level visual verification via the Browser preview tools was attempted (web build compiled
  and ran cleanly — Hive boxes opened, all product/category/cart modules loaded with zero console
  errors) but screenshot/semantics-tree capture wasn't available in this session (same "Browser
  pane not displayed" limitation noted above) — the signed release APK was built and provided
  directly for on-device visual confirmation instead.
