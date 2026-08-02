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

### Changed
- Pinned `flutter_riverpod`/`riverpod` to the 2.6.1 stable line — Riverpod 3.x's current release
  pulls a `test`/`analyzer` chain that conflicts with `json_serializable` under this Flutter SDK.
- Dropped `riverpod_generator`, `hive_generator`, `custom_lint`/`riverpod_lint` after confirming real
  version conflicts (documented in `docs/ARCHITECTURE.md`); Riverpod providers are hand-written and
  Hive stores JSON via the existing Freezed `toJson`/`fromJson` instead of generated TypeAdapters.
