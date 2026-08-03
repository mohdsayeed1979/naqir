# Folder Structure

```
lib/
├── main.dart                    Entry point — just calls bootstrap()
├── bootstrap.dart                Hive/DI init, error-zone boundary, runApp
├── app.dart                      MaterialApp.router, theme/locale wiring, offline banner
│
├── core/                         Framework-agnostic infrastructure. No feature imports this
│   ├── config/                   AppConfig (flavor, base URL, feature flags from --dart-define)
│   ├── constants/                Colors, spacing/radius scale, durations, asset paths, API paths
│   ├── di/                       GetIt registration (injector.dart) — one _configureXFeature() per feature
│   ├── error/                    AppException (data layer) → Failure (presentation) → Result<T>
│   ├── network/                  Dio wrapper (ApiClient), interceptors, connectivity check
│   ├── router/                   go_router config, route path constants
│   ├── storage/                  Hive box registry, secure storage wrapper
│   ├── theme/                    Material 3 ColorScheme + locale-aware typography
│   └── localization/gen/         Generated AppLocalizations (gitignored, regenerated on pub get)
│
├── l10n/                         ARB source files (app_en.arb, app_ar.arb) — edit these, not the gen/ output
│
├── shared/                       Reusable across features, but still app-specific (unlike core/)
│   ├── providers/                Cross-cutting Riverpod providers (connectivity, theme mode, locale,
│   │                             GetIt→Riverpod bridges)
│   └── widgets/                  ProductCard, ProductRail, AppImage, shimmer skeletons, empty/error
│                                 states, buttons, the bottom-nav shell
│
└── features/                     One directory per feature, each internally layered:
    │                             data/ (datasources, models/DTOs, repository impls)
    │                             domain/ (entities, repository interfaces, use cases where real
    │                             orchestration exists)
    │                             presentation/ (providers/notifiers, screens, widgets)
    │
    ├── splash/                   presentation only — no data/domain, nothing to fetch
    ├── onboarding/                presentation only
    ├── authentication/            full stack — login/register/OTP/forgot-password, session caching
    ├── home/                      presentation + providers only — composes products/categories repos
    ├── categories/                full stack
    ├── products/                  full stack — listing, detail, search reuses this feature's
    │                             entities/repository, reviews (mock-generated), recently-viewed
    ├── search/                    presentation + local history repository (no remote calls yet)
    ├── wishlist/                  local-only (Hive) — no mock/remote split, see ARCHITECTURE.md
    ├── cart/                      local-only (Hive) — same rationale as wishlist
    ├── checkout/                  address book (local-only) + checkout screen
    ├── payment/                   PaymentGateway interface, factory, CashOnDelivery + stub gateways
    ├── orders/                    local-only order history (created at checkout) + tracking UI
    ├── profile/                   edit profile, addresses screen, About/Contact/FAQ/Privacy/Terms
    ├── settings/                  dark mode, language switch, links to notification prefs
    └── notifications/             NotificationService (FCM + local), preferences screen
```

## Why some features skip the data/domain split

`Product`/`Category`/`User` have a **DTO** (`data/models/*_dto.dart`, wire format, snake_case) kept
separate from the **domain entity** (`domain/entities/*.dart`, camelCase, no JSON awareness)
because they have a real remote counterpart with a genuinely different shape.

`Cart`/`Wishlist`/`Address`/`Order`/`RecentlyViewed`/`SearchHistory` are **local-only device
state** — there's no remote API for them yet (see `docs/API.md`), so introducing a DTO that would
just mirror the entity 1:1 forever would be premature abstraction. Their entities carry
`fromJson`/`toJson` directly and persist straight to Hive as JSON strings.

## `test/` and `integration_test/`

```
test/
├── core/error/                   Pure-logic unit tests (Result<T>)
├── features/
│   ├── cart/                     CartNotifier unit tests (mocktail-mocked repository)
│   └── products/                 ProductRepositoryImpl unit tests
├── shared/widgets/                Widget tests (ProductCard)
└── widget_test.dart               Widget test (PrimaryButton) — kept at root, Flutter's default location

integration_test/
└── app_test.dart                  Full-app happy path: browse → product detail → add to cart → cart tab
```

## Root-level files

| File | Purpose |
|---|---|
| `l10n.yaml` | `flutter gen-l10n` config (points at `lib/l10n/*.arb`) |
| `analysis_options.yaml` | Lint rules (`flutter_lints`) |
| `.claude/launch.json` | Dev-server launch configs used during this build (not required to run the app) |
| `docs/` | Architecture, installation, API, deployment, folder-structure docs (this file) |
| `PROJECT_PROGRESS.md` | Live milestone tracker |
| `CHANGELOG.md` | Chronological record, including every real bug/conflict hit and how it was fixed |
