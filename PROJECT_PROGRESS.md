# Project Progress

Living milestone tracker for the Naqir Gift Box Flutter app. Updated after every milestone.
See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for the technical plan and
[CHANGELOG.md](CHANGELOG.md) for a chronological record.

Legend: ✅ done · 🚧 in progress · ⬜ not started · 🔒 blocked on user-supplied credentials/hardware

## Phase 1 — Analysis & Planning
- ✅ Website & platform analysis (naqirgiftbox.com runs on Zid; private API identified and
  deliberately not used — see architecture doc §1)
- ✅ Architecture & folder structure plan

## Phase 2 — Project Foundation
- ✅ Flutter project scaffold + dependencies (Android/iOS/Web/Windows)
- ✅ Clean architecture folder structure
- ✅ Brand assets (icon, adaptive icon, splash logo light/dark) + native icon/splash generation
- ✅ Localization scaffolding (`l10n.yaml`, English + Arabic ARB source)
- ✅ Git init + commits per milestone

## Phase 3 — Core Infrastructure
- ✅ Theming (Material 3, light/dark, brand palette, locale-aware typography)
- ✅ Localization wiring (EN/AR, RTL-by-construction via directional widgets)
- ✅ Navigation (go_router, `StatefulShellRoute` bottom-nav shell, auth-gated redirects)
- ✅ Dependency injection & app bootstrap (GetIt + Riverpod bridge, error-zone boundary)
- ✅ Network layer (Dio, auth/retry/logging interceptors, typed `Result`/`Failure` mapping)
- ✅ Local storage layer (Hive boxes, secure storage for tokens)

## Phase 4 — Features (all functional against mock data; see docs/ARCHITECTURE.md §1)
- ✅ Splash (animated) & onboarding (3-page carousel, first-run only)
- ✅ Authentication — login, register, OTP, forgot password, session caching
- ✅ Home — banner carousel, category rail, featured/new/best-seller rails, shimmer skeletons
- ✅ Categories — grid + category-filtered listing
- ✅ Product listing — filters (price/discount), sort, infinite scroll
- ✅ Product details — zoomable gallery, variants, quantity, specs, reviews, related, recently
  viewed, share
- ✅ Search — debounced results, history, trending, voice search (speech_to_text)
- ✅ Wishlist — offline-persisted, reactive across the app
- ✅ Cart — offline-persisted, coupon codes, quantity edit
- ✅ Checkout — address book (add/select/default), shipping method, order summary
- ✅ Payment architecture — gateway interface + factory; Cash on Delivery fully functional,
  Stripe/Moyasar/HyperPay/Apple Pay/Google Pay wired as clearly-labeled unconfigured stubs
- ✅ Orders — history, detail, status tracking timeline
- ✅ Profile & settings — edit profile, dark mode (system/light/dark), language switch, About,
  Contact, FAQ, Privacy Policy, Terms
- ✅ Notification preferences UI + `NotificationService` (FCM + local notifications), inert until
  a Firebase project is wired — see gap below
- ✅ Offline connectivity banner (real-reachability check via `connectivityStatusProvider`)

## Phase 5 — Quality & Platforms
- ✅ Offline support (wishlist/cart/recently-viewed/search-history/addresses all Hive-backed;
  connectivity banner wired app-wide)
- ✅ Automated tests: unit tests (`Result`, `CartNotifier`, `ProductRepositoryImpl`), widget tests
  (`PrimaryButton`, `ProductCard`), and one `integration_test` happy-path (browse → add to cart →
  cart tab) — written and passing where runnable locally; the integration test needs a connected
  device/emulator to execute and hasn't been run in this session (see CHANGELOG)
- ✅ Web build verified — `flutter analyze` clean, `flutter build web --release` succeeds; pixel
  visual check still pending (Browser preview pane wasn't displayed this session)
- ✅ Android build verified — `flutter build apk --debug` succeeds (SDK licenses accepted;
  `permission_handler` pinned to 12.0.3 after 13.0.0's `permission_handler_android` 14.0.0
  required AGP 9.x, newer than the project's AGP 8.9.1 — see CHANGELOG)
- ✅ Windows build verified — `flutter build windows --debug` succeeds (Visual Studio Build Tools +
  ATL component installed; `flutter_local_notifications`/`flutter_secure_storage` Windows plugins
  need it)
- 🔒 iOS build (needs macOS/Xcode — not available on this machine; code is iOS-ready)

## Phase 6 — Documentation
- 🚧 Architecture doc in place; README, installation guide, API docs, deployment guide, folder
  structure doc still to write

## Known blockers (see [docs/ARCHITECTURE.md §11](docs/ARCHITECTURE.md#11-known-gaps-requiring-the-users-own-accountshardware))
1. No Zid Partner API credentials yet → app runs on realistic mock data.
2. No Firebase project yet → push notifications code-complete but inactive (`NotificationService`
   no-ops safely without one).
3. No payment merchant keys yet → payment architecture complete, native SDKs not wired.
4. Windows machine → iOS cannot be compiled here.
5. Web visual verification pending — needs the Browser pane displayed to compare against a
   screenshot in a future turn, or the user running `flutter run -d chrome` locally.
6. `integration_test/app_test.dart` needs a connected device/emulator to actually execute.
