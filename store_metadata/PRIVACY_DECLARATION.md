# App Store Connect — App Privacy declaration (Naqir Gift Box)

This recommendation is derived from an audit of the **actual source code** and
the **verified release IPA** (`1.0.0` build `4`, `build/ios/ipa/naqirgiftbox.ipa`),
not from a generic template.

## Runtime reality (what the code actually does)

| Behavior | Finding |
|----------|---------|
| Backend transmission of user data | **None.** App ships in `mock` flavor (`AppConfig.useMockData == true`); profile, orders, addresses, wishlist, cart are stored **only in on-device Hive + Keychain**. |
| Firebase Analytics / Crashlytics / Messaging | **Removed entirely.** The `firebase_*` packages were removed from the app; the release IPA contains **no** Firebase frameworks, symbols, endpoints, privacy manifests, or `GoogleService-Info.plist` (verified — see "Firebase status" below). |
| Microphone / Speech | Voice search only, on user tap; uses Apple's `SFSpeechRecognizer` (system framework). Audio not stored by the app. |
| WhatsApp / email | Opened via `url_launcher` only when the user taps Contact Us. No automatic transmission. |
| Product images | Loaded from `naqirgiftbox.com` CDN (GET). No personal data sent. |
| Tracking / IDFA / ad networks | **None.** No `AppTrackingTransparency`, no ad SDKs, no cross-app tracking. |
| Location, Contacts, Photos, Camera | **Not accessed.** No such permissions in Info.plist. |

## Recommended App Privacy answers for THIS build

Because no data is transmitted off-device to the developer or any third party,
the accurate answer to "Does this app collect data?" for the current build is:

> **Data Not Collected.**

Apple defines "collect" as transmitting data off the device. Local-only,
on-device storage that never leaves the device is **not** collection. Voice
handled by Apple's on-device/OS speech framework is also not developer
collection.

### Per-data-type table (for the questionnaire)

| Data type | Collected (transmitted off device)? | Linked to user? | Used for tracking? | Notes / purpose |
|-----------|-------------------------------------|-----------------|--------------------|-----------------|
| Name | No | — | No | Stored on-device only |
| Email address | No | — | No | Stored on-device only |
| Phone number | No | — | No | Stored on-device only |
| Physical/shipping address | No | — | No | Stored on-device only |
| Order/purchase history | No | — | No | Stored on-device only |
| Wishlist / cart | No | — | No | Stored on-device only |
| User ID | No | — | No | Local fabricated id only |
| Payment info | No | — | No | No payment processing in app (COD only) |
| Precise/coarse location | No | — | No | Not accessed |
| Contacts / Photos / Camera | No | — | No | Not accessed |
| Audio data | No | — | No | Voice search via Apple `SFSpeechRecognizer`; not stored/sent by app |
| Device ID / IDFA | No | — | No | No tracking, no ad SDKs |
| Usage/Analytics data | No | — | No | No analytics SDK — Firebase removed |
| Diagnostics/Crash data | No | — | No | No crash-reporting SDK — Crashlytics removed |

## Firebase status — REMOVED (verified against release IPA build 4)

Firebase was **removed entirely** before submission (commit `648f88e`). The
earlier "dormant Firebase" caveat no longer applies. Verified against
`build/ios/ipa/naqirgiftbox.ipa` (1.0.0 build 4):

- **Firebase packages removed** — `firebase_core`, `firebase_messaging`,
  `firebase_analytics`, `firebase_crashlytics` dropped from `pubspec.yaml`
  (and `pubspec.lock`, iOS `Podfile.lock`).
- **Not present in the release IPA** — zero Firebase/Google frameworks in the
  app bundle; zero Firebase symbols in the `Runner`/`App` binaries.
- **No Firebase Analytics / GoogleAppMeasurement** — engine not linked.
- **No Firebase Crashlytics.**
- **No Firebase Messaging (FCM).**
- **No Firebase identifiers** — no Installations/FID, no Firebase device id.
- **No Firebase tracking** — no ad/attribution SDK; `NSPrivacyTracking = false`.
- **No Firebase network communication** — no `app-measurement.com`,
  `firebaseinstallations`, or `crashlytics` endpoints anywhere in the bundle;
  device log shows zero Firebase runtime activity.
- **No Firebase privacy manifests** — every Firebase-origin `.xcprivacy` /
  `*_Privacy.bundle` is gone; only legitimate non-Firebase plugin manifests
  remain.
- **No `GoogleService-Info.plist`** — absent from the repo and the IPA.
- **No `firebase_options.dart`** — never existed.

Only `flutter_local_notifications` (local, on-device notifications) remains —
it is not Firebase and performs no off-device collection.

## Final App Store Connect recommendation

> **Data Not Collected.**

This is now unambiguous: nothing is transmitted off-device to the developer or
any third party, and no analytics/crash/tracking SDK is present in the binary.

## If a real backend is added later (future)

Re-answer the questionnaire to declare, at minimum: Contact Info (name, email,
phone), User Content (addresses, order history), and Identifiers (user id).
Tracking stays **No** unless an ad/attribution SDK is added. If Firebase (or any
analytics/crash SDK) is re-introduced, update this document and the label.

## Privacy policy URL

Public policy (live, verified HTTP 200, no login):
`https://mohdsayeed1979.github.io/naqir/privacy-policy.html`
Reflects the on-device-only reality and the in-app deletion path
(`Profile → Settings → Delete Account`). See APP_REVIEW_NOTES.md.
