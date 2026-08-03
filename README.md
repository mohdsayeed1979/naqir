# Naqir Gift Box

A premium Flutter e-commerce app for **نقير التمر (Naqir Al-Tamr)** — a Riyadh-based gift box and
dates retailer. Clean Architecture + MVVM, Material 3, English/Arabic with full RTL support, and
runs on Android, iOS, Web, and Windows from a single codebase.

The app is fully functional today against a realistic mock catalog — every screen in the product
spec works end-to-end. Swapping to a real backend/payment/notifications is a scoped, documented
step once those credentials exist (see [Known Gaps](#known-gaps)).

## Documentation

| Doc | What's in it |
|---|---|
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | Layering, tech stack, state management, error handling, theming, security — and the *why* behind every non-obvious decision |
| [docs/INSTALLATION.md](docs/INSTALLATION.md) | Environment setup, running on each platform, environment/flavor configuration |
| [docs/API.md](docs/API.md) | The REST contract every `RemoteDataSource` implements — what a real backend needs to expose |
| [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md) | Going from mock data to production: Zid Partner API, Firebase, payment gateways, release signing, store submission |
| [docs/FOLDER_STRUCTURE.md](docs/FOLDER_STRUCTURE.md) | Annotated `lib/` tree |
| [PROJECT_PROGRESS.md](PROJECT_PROGRESS.md) | Live milestone tracker |
| [CHANGELOG.md](CHANGELOG.md) | Chronological record of what changed and why |

## Quick start

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
flutter run
```

See [docs/INSTALLATION.md](docs/INSTALLATION.md) for prerequisites, platform-specific setup, and
environment/flavor flags. The app defaults to a mock data flavor, so `flutter run` works
immediately with no backend, Firebase project, or payment keys required.

## Tech stack

Riverpod (state) · go_router (navigation) · Dio (networking) · Freezed/json_serializable (models) ·
GetIt (DI) · Hive (local storage) · flutter_secure_storage (tokens) · Material 3 · Google Fonts

Full rationale for every package choice — including two version pins that were forced by real
dependency conflicts hit while building this — is in
[docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

## Source site analysis

`naqirgiftbox.com` runs on **Zid**, a licensed Saudi e-commerce SaaS platform, with its own
private, session-authenticated storefront API. This app deliberately does not call that API —
see [docs/ARCHITECTURE.md §1](docs/ARCHITECTURE.md#1-source-analysis) for why, and for the
repository-pattern design that makes swapping in Zid's official Partner API a scoped, contained
change once OAuth credentials exist.

## Known gaps

These need the business's own accounts/hardware — they're architected and ready to wire in, not
placeholders:

- **Real catalog/orders** — needs a Zid Partner API registration (or another backend); the app
  runs on realistic mock data until then.
- **Push notifications** — code-complete (`NotificationService`, FCM + local notifications) but
  inactive until a Firebase project exists (`flutterfire configure`).
- **Real payments** — architecture and UI are complete (Cash on Delivery works today);
  Stripe/Moyasar/HyperPay/Apple Pay/Google Pay need merchant credentials and their native SDKs.
- **iOS build** — the code is iOS-ready, but compiling/signing needs Xcode on macOS (this project
  was built on Windows).
- **App icon resolution** — the real brand logo supplied is 252×240px; icons that scale above that
  (1024×1024 App Store, 512×512 Play Store) look soft. Get a higher-resolution source before store
  submission.

Full detail, including every command run to verify each platform builds, is in
[PROJECT_PROGRESS.md](PROJECT_PROGRESS.md) and [CHANGELOG.md](CHANGELOG.md).

## Testing

```bash
flutter test                                    # unit + widget tests
flutter test integration_test/app_test.dart -d <device>   # end-to-end happy path
```

## License

Proprietary — © Naqir Gift Box. Not for redistribution.
