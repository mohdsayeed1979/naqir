# Naqir Gift Box — Flutter App Architecture

## 1. Source analysis

`naqirgiftbox.com` (نقير التمر) is a gift-box / dates-gift retailer in Riyadh, running on **Zid** — a
licensed Saudi Arabia e-commerce SaaS platform (footer: "Powered by Zid", `zid.sa`). Observed IA:

- **Catalog**: ~191 products under a primary "Gift Box" category, most products are color/size
  variants of a base design (e.g. `Termeh box-T01-Red/Green/Blue`), priced 50–270 SAR.
- **Product listing**: grid, filter drawer (price range, "discounted only"), sort (Newest, Most
  popular, Low→High, High→Low), pagination.
- **Product detail**: gallery image, short + expandable long description, SKU, stock-aware
  quantity stepper, Add to Cart / Buy Now / Share, "You May Also Like" related products.
- **Cart/Auth**: cart is server-side per session; add-to-cart surfaces a login prompt (Zid
  storefront default). Login screen supports email/phone.
- **Footer**: policy pages (Privacy, Exchange & Return, Shipping), store location (Google Maps),
  phone/email/WhatsApp contact, commercial register number.
- **Storefront API**: the live site calls an internal `/api/v1/...` REST API (`auth/login-status`,
  `products/bundle-offers`, `cart`, `account`, `storewhatsapp/widget`). This is Zid's **private,
  session-cookie-authenticated storefront API** — undocumented, unversioned for third parties, and
  not intended for external consumption. It is **not** used by this app.

### API strategy

Zid publishes an official **Partner/Store OpenAPI** (OAuth2, documented, rate-limited, meant for
third-party apps) at `docs.zid.sa`. The correct production path is to register a Zid Partner
Application against the merchant's store and obtain OAuth credentials.

Since those credentials aren't available yet, every feature is built against a **repository
interface** with two interchangeable data sources, selected at runtime by `AppConfig`:

- `MockDataSource` — realistic in-app fixture data (same shape as the real catalog: gift boxes,
  dates trays, categories, variants) so the app is fully functional and demoable today.
- `RemoteDataSource` — a Dio client wired to `ApiEndpoints` + `AppConfig.baseUrl`, ready to point
  at the Zid Partner API (or any REST backend) the moment credentials exist. No screen or
  view-model code changes when the switch happens — only DI registration changes.

This satisfies the brief's "do not hardcode, use repository pattern" requirement app-wide, not
just for payments.

## 2. Tech stack

| Concern | Package | Notes |
|---|---|---|
| State management | `flutter_riverpod` (2.6.1, hand-written `Notifier`/`AsyncNotifier`) | see version note below — no codegen |
| Routing | `go_router` | typed path constants, `ShellRoute` for bottom nav, redirect-based auth guard |
| Networking | `dio` | interceptors for auth header, logging, retry/backoff |
| Immutable models/DTOs | `freezed` + `json_serializable` | domain entities + data DTOs kept separate |
| DI | `get_it` | manual registration per layer (see §16) |
| Local structured storage | `hive` + `hive_flutter` | cart, wishlist, recently-viewed, search history — see version note below |
| Secure storage | `flutter_secure_storage` | auth tokens only |
| Image loading/caching | `cached_network_image` | disk+memory cache, shimmer placeholder |
| Image zoom | `photo_view` | product gallery |
| Connectivity | `connectivity_plus` + `internet_connection_checker_plus` | true reachability, not just radio state |
| Fonts | `google_fonts` | locale-aware pairing, see §9 |
| Push | `firebase_messaging`, `firebase_analytics`, `firebase_crashlytics` | gated behind `AppConfig.firebaseEnabled`, see §12 |
| Local notifications | `flutter_local_notifications` | foreground FCM display |
| Forms | `reactive_forms` | checkout/address/auth forms |
| Loading UI | `shimmer` | skeleton loaders |
| Voice search | `speech_to_text` + `permission_handler` | mic permission flow |
| Share | `share_plus` | share product |
| Misc | `url_launcher`, `package_info_plus`, `path_provider`, `intl` | contact links, About screen, Hive init dir, date/number formatting |

All versions are resolved live via `flutter pub add` (latest stable at scaffold time), not
hand-typed, per "use latest packages" — with two deliberate exceptions found while scaffolding:

- **`flutter_riverpod`/`riverpod` pinned to `2.6.1`.** The freshly-released Riverpod 3.x line
  pulls in a `test`/`analyzer` dependency chain that conflicts with `json_serializable` under
  Flutter 3.35.3's pinned `meta` version — a real `pub get` failure, not a style choice. 2.6.1 is
  still the current production-recommended stable line. Revisit once Riverpod 3.x's dependency
  graph settles.
- **No `riverpod_generator` / `hive_generator`.** `riverpod_generator` needs a newer `analyzer`
  than the Flutter SDK allows here, and `hive_generator` is built on `source_gen ^1.0.0`, which
  conflicts with the modern `json_serializable`/`source_gen 4.x` used for DTOs. Providers are
  hand-written `Notifier`/`AsyncNotifier` classes (fully supported, no codegen required), and Hive
  boxes store JSON strings through the *same* Freezed-generated `toJson`/`fromJson` already used
  for network DTOs — one serialization mechanism instead of two, and it avoids the conflict
  entirely.

## 3. Layering — Clean Architecture + MVVM

```
presentation (View + ViewModel)  →  domain (entities + repository contracts [+ use cases for
       ↑ Riverpod Notifier            multi-step orchestration only])  →  data (DTOs + repository
       ↓ watches state                                                     impl + data sources)
     Widgets (View)
```

- **View** — `ConsumerWidget`/`ConsumerStatefulWidget`, no business logic.
- **ViewModel** — a Riverpod `Notifier`/`AsyncNotifier`, one per screen/feature slice. Calls the
  repository interface directly for simple CRUD-shaped operations.
- **UseCase** — added only where real orchestration exists across repositories (e.g.
  `PlaceOrderUseCase` coordinates cart + address + payment; `VerifyOtpUseCase` coordinates auth +
  token storage + guest-cart merge). A use-case class that would just forward one call to one
  repository method is skipped — the Notifier calls the repository directly instead. This keeps
  the domain layer honest without boilerplate ceremony.
- **Repository (domain)** — abstract interface, returns a sealed `Result<T>` (see §7).
- **Repository (data) impl** — picks `MockDataSource` or `RemoteDataSource` per `AppConfig`,
  optionally layers a `LocalDataSource` (Hive) for offline-first reads (cart, wishlist, recently
  viewed).

## 4. Folder structure

```
lib/
  main.dart                     entrypoint (imports flavor-neutral bootstrap)
  bootstrap.dart                 shared init: Hive, DI, error zone, runApp
  app.dart                       MaterialApp.router, theme/locale wiring
  core/
    config/                      AppConfig, Flavor, dart-define reader
    constants/                   asset paths, api paths, durations, radii
    di/                          get_it setup, per-layer registration modules
    error/                       Failure, AppException, Result<T> sealed class
    network/                     ApiClient (Dio), interceptors, NetworkInfo
    router/                      GoRouter config, route paths, redirect guards
    storage/                     Hive box registry + adapters, SecureStorageService
    theme/                       ColorSchemes, TextTheme, ThemeData, ThemeExtension
    localization/                locale provider, RTL helpers
    utils/                       validators, formatters, debouncer, logger
  l10n/                          app_en.arb, app_ar.arb
  shared/
    widgets/                     buttons, cards, shimmer loaders, empty/error states
    providers/                   connectivity, theme-mode, locale providers
  features/
    splash/  onboarding/  authentication/  home/  categories/  products/  search/
    wishlist/  cart/  checkout/  payment/  orders/  profile/  settings/  notifications/
      └─ data/{datasources,models,repositories}  domain/{entities,repositories,usecases}
         presentation/{providers,screens,widgets}
```

## 5. Error handling

A hand-rolled sealed `Result<T>` (Dart 3 pattern matching) is used instead of `dartz`/`fpdart` —
one fewer third-party dependency for a concept Dart's type system now expresses natively:

```dart
sealed class Result<T> {
  const factory Result.success(T data) = Success<T>;
  const factory Result.failure(Failure failure) = Error<T>;
}
```

`ApiClient` catches `DioException`, maps it to a typed `Failure` (`NetworkFailure`,
`ServerFailure`, `UnauthorizedFailure`, `ValidationFailure`, ...), and every repository method
returns `Result<T>`. ViewModels switch on the result — no try/catch leaking into the UI layer.

## 6. Theming

Explicit `ColorScheme` (not `ColorScheme.fromSeed`) built from the brand palette so exact hex
values are respected:

| Token | Light | Dark |
|---|---|---|
| Primary | `#9D6B3F` | `#D6B98C` |
| Secondary | `#D6B98C` | `#9D6B3F` |
| Background/Surface | `#FFFDF8` | `#1E1B18` |
| Accent (tertiary) | `#C99846` | `#C99846` |
| On-surface (text) | `#222222` | `#F2EDE6` |

Typography pairs a display serif with a clean sans for body — but only for Latin script; Arabic
has no equivalent classic-serif webfont, so the pairing is **locale-aware**:

- `en`: `GoogleFonts.marcellus` (display/headings) + `GoogleFonts.inter` (body/UI)
- `ar`: `GoogleFonts.cairo` for both display and body (modern, warm, wide weight range — reads as
  premium in Arabic the way a serif does in Latin)

## 7. Localization & RTL

`flutter gen-l10n` (ARB-based, official Flutter tooling — no extra i18n package needed) with
`en`/`ar`. Locale persisted in Hive. Layout code uses `EdgeInsetsDirectional`,
`Alignment.centerStart/End`, and `TextDirection`-aware widgets throughout `shared/widgets` so RTL
is correct by construction rather than patched per screen.

## 8. Payment architecture

`PaymentGateway` interface with `Future<Result<PaymentOutcome>> pay(PaymentRequest req)`.
`PaymentGatewayFactory` resolves the active gateway(s) from `AppConfig.enabledPaymentMethods`.
Stub implementations exist for `StripeGateway`, `MoyasarGateway`, `HyperPayGateway`,
`ApplePayGateway`, `GooglePayGateway` — the checkout UI, method-selection screen, and repository
plumbing are complete, but the native SDKs (`flutter_stripe`, etc.) are **intentionally not
added yet**: they require merchant keys we don't have and native Gradle/Xcode changes that would
destabilize the build before there's anything real to test against. Wiring a live gateway is a
single class implementation + one DI registration — see `docs/DEPLOYMENT.md`.

## 9. Push notifications / Firebase

`firebase_core/messaging/analytics/crashlytics` are added as Dart dependencies, but
initialization is wrapped in `AppConfig.firebaseEnabled` + try/catch so the app runs normally
without a configured Firebase project. The native Android `google-services` Gradle plugin is
**not applied** until the user runs `flutterfire configure` (requires their own Firebase/Google
login — cannot be done on their behalf) and supplies `google-services.json` /
`GoogleService-Info.plist`. This keeps `flutter build` green in the meantime.

## 10. Security

- Tokens in `flutter_secure_storage` (Keychain/Keystore-backed), never Hive/SharedPreferences.
- Certificate-pinning hook point in `ApiClient` (`Dio`'s `HttpClientAdapter`), disabled by default,
  documented for enabling once the real API host is known.
- No secrets/API keys committed; all environment-specific values come from `--dart-define` /
  `AppConfig`.

## 11. Known gaps requiring the user's own accounts/hardware

| Gap | Why it can't be done here | Action needed |
|---|---|---|
| Real product/order data | Requires Zid Partner API OAuth credentials | Register a Zid Partner App for the store |
| Push notifications | Requires a Firebase project | Run `flutterfire configure` with your Google account |
| Real payments | Requires merchant accounts | Supply Stripe/Moyasar/HyperPay keys, add native SDKs |
| iOS build | Xcode only runs on macOS; this machine is Windows | Build/sign on a Mac or via CI (Codemagic/Fastlane) once you have one |
| Windows desktop build | Needs Visual Studio "Desktop development with C++" workload (multi-GB) | Confirm before we install it |
| Android release signing | Needs a real upload keystore | Generate and keep it out of source control |

## 12. Testing

- Unit: repositories (mocked data sources via `mocktail`), Notifiers.
- Widget: reusable components + key screens.
- Integration (`integration_test`): browse → cart → checkout happy path against mock data.
