# Installation Guide

## Prerequisites

| Tool | Version used to build this project | Notes |
|---|---|---|
| Flutter SDK | 3.35.3 (stable channel) | `flutter --version` |
| Dart SDK | 3.9.2 | bundled with Flutter |
| Android SDK | 36.1.0-rc1 | via Android Studio, for Android builds |
| Visual Studio Build Tools 2022 | "Desktop development with C++" workload **+ the ATL component** | for Windows builds only — see the note below |
| Xcode | — | for iOS builds only, macOS required (not available on the machine this was built on) |

Run `flutter doctor -v` and resolve anything marked `[✗]` for the platforms you intend to build.

### Windows desktop build gotcha

The default "Desktop development with C++" workload does **not** include the ATL component, which
`flutter_local_notifications_windows` and `flutter_secure_storage_windows` both require
(`atlbase.h`/`atlstr.h` not found otherwise). Add it explicitly:

```powershell
winget install --id Microsoft.VisualStudio.2022.BuildTools --silent `
  --override "--wait --quiet --add Microsoft.VisualStudio.Workload.VCTools --add Microsoft.VisualStudio.Component.VC.ATL --includeRecommended"
```

### Android SDK licenses

```powershell
flutter doctor --android-licenses
```

## First-time setup

```bash
git clone <repo-url>
cd naqirgiftbox
flutter pub get
```

`flutter pub get` also regenerates localization (`AppLocalizations`, via `generate: true` in
`pubspec.yaml` + `l10n.yaml`) automatically. Generated Freezed/json_serializable code
(`*.freezed.dart`, `*.g.dart`) is **not** committed (see `.gitignore`) — generate it explicitly:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Re-run that command any time you change a `@freezed` class or add/edit a `fromJson`/`toJson`.

## Running the app

```bash
flutter devices          # see what's available
flutter run               # picks a connected device, or prompts
flutter run -d chrome     # web
flutter run -d windows    # Windows desktop
```

The app defaults to the **mock** flavor (`AppConfig.useMockData == true`) — no backend, Firebase
project, or payment keys are required to run it. See [ARCHITECTURE.md §1](ARCHITECTURE.md#1-source-analysis)
for what that means and [DEPLOYMENT.md](DEPLOYMENT.md) for switching to a real backend.

### Environment / flavor flags

Passed via `--dart-define` at run/build time, read by `AppConfig.fromEnvironment()`
(`lib/core/config/app_config.dart`):

| Flag | Default | Effect |
|---|---|---|
| `FLAVOR` | `mock` | `mock` \| `development` \| `production` — anything but `mock` switches every repository to its `RemoteDataSource` |
| `API_BASE_URL` | placeholder URL | Base URL for all `RemoteDataSource`s (see `docs/API.md`) |
| `FIREBASE_ENABLED` | `false` | Gates Firebase initialization and `NotificationService` — leave off until a real Firebase project is configured |

Example:

```bash
flutter run --dart-define=FLAVOR=production --dart-define=API_BASE_URL=https://api.example.com/v1 --dart-define=FIREBASE_ENABLED=true
```

## Testing

```bash
flutter test                                             # unit + widget tests (no device needed)
flutter test integration_test/app_test.dart -d <device>   # end-to-end happy path, needs a device/emulator
```

## Building for release

```bash
flutter build apk --release              # Android
flutter build appbundle --release        # Android (Play Store)
flutter build web --release              # Web
flutter build windows --release          # Windows desktop
flutter build ipa --release              # iOS (macOS + Xcode only)
```

See [DEPLOYMENT.md](DEPLOYMENT.md) for release signing, store submission, and web hosting.

## Troubleshooting

- **`permission_handler_android` Gradle Kotlin DSL errors** (`Unresolved reference: compilerOptions`) —
  a newer `permission_handler` pulls `permission_handler_android` versions built against AGP 9.x,
  ahead of this project's AGP 8.9.1. Already pinned to `permission_handler: 12.0.3` in
  `pubspec.yaml`; if you bump it, expect to re-hit this.
- **`flutter_local_notifications` "requires core library desugaring"** — already enabled in
  `android/app/build.gradle.kts`. If you see this on a fresh clone, `flutter clean` and rebuild.
- **`atlbase.h`/`atlstr.h` not found** building for Windows — see the ATL component note above.
