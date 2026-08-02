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
- ✅ Flutter project scaffold + dependencies (Android/iOS/Web/Windows; see CHANGELOG for the two
  version-pin decisions made to keep `pub get` conflict-free)
- ✅ Clean architecture folder structure
- ✅ Brand assets (icon, adaptive icon, splash logo light/dark) + native icon/splash generation
- ✅ Localization scaffolding (`l10n.yaml`, English + Arabic ARB source)
- ✅ Git init + first commit

## Phase 3 — Core Infrastructure
- ⬜ Theming (Material 3, light/dark, brand palette)
- ⬜ Localization (English/Arabic, RTL)
- ⬜ Navigation (go_router)
- ⬜ Dependency injection & app bootstrap / environment config
- ⬜ Network layer (Dio, interceptors, typed error handling)
- ⬜ Local storage layer (Hive, secure storage)

## Phase 4 — Features
- ⬜ Splash & onboarding
- ⬜ Authentication (login, OTP, register, forgot password)
- ⬜ Home screen
- ⬜ Categories & subcategories
- ⬜ Product listing (filters, sort, pagination)
- ⬜ Product details (gallery, reviews, related, recently viewed)
- ⬜ Search (suggestions, history, voice)
- ⬜ Wishlist
- ⬜ Cart
- ⬜ Checkout (address, shipping)
- ⬜ Payment integration layer (architecture only — see gaps)
- ⬜ Orders & tracking
- ⬜ Profile & settings
- 🔒 Push notifications (needs user's Firebase project)

## Phase 5 — Quality & Platforms
- ⬜ Offline support & caching polish
- ⬜ Automated tests (unit/widget/integration)
- ⬜ Web build verified
- ⬜ Android build verified
- 🔒 iOS build (needs macOS/Xcode — not available on this machine)
- 🔒 Windows desktop build (needs Visual Studio C++ workload — needs confirmation before install)

## Phase 6 — Documentation
- ⬜ README, installation guide, API docs, deployment guide, folder structure doc

## Known blockers (see [docs/ARCHITECTURE.md §11](docs/ARCHITECTURE.md#11-known-gaps-requiring-the-users-own-accountshardware))
1. No Zid Partner API credentials yet → app runs on realistic mock data.
2. No Firebase project yet → push notifications code-complete but inactive.
3. No payment merchant keys yet → payment architecture complete, native SDKs not wired.
4. Windows machine → iOS cannot be compiled here; Windows desktop build needs Visual Studio.
