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
- 🔒 Push notifications (needs user's Firebase project — not started)

## Phase 5 — Quality & Platforms
- ⬜ Offline support polish pass (cached images, connectivity banners)
- 🚧 Automated tests (one real widget test in place; full suite is its own milestone)
- 🚧 Web build verified — `flutter analyze` clean, `flutter build web --release` succeeds; visual
  smoke test blocked this session because the Browser preview pane wasn't displayed (frame
  compositing needs the pane visible) — code-level verification only, not yet eyeballed
- ⬜ Android build verified
- 🔒 iOS build (needs macOS/Xcode — not available on this machine)
- 🔒 Windows desktop build (needs Visual Studio C++ workload — needs confirmation before install)

## Phase 6 — Documentation
- 🚧 Architecture doc in place; README, installation guide, API docs, deployment guide, folder
  structure doc still to write

## Known blockers (see [docs/ARCHITECTURE.md §11](docs/ARCHITECTURE.md#11-known-gaps-requiring-the-users-own-accountshardware))
1. No Zid Partner API credentials yet → app runs on realistic mock data.
2. No Firebase project yet → push notifications not started.
3. No payment merchant keys yet → payment architecture complete, native SDKs not wired.
4. Windows machine → iOS cannot be compiled here; Windows desktop build needs Visual Studio.
5. Web visual verification pending — needs the Browser pane displayed to compare against a
   screenshot in a future turn, or the user running `flutter run -d chrome` locally.
