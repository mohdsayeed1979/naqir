# App Store Connect — App Privacy declaration (Naqir Gift Box)

This recommendation is derived from an audit of the **actual source code** of
the shipped build (`1.0.0`, mock flavor), not from a generic template.

## Runtime reality (what the code actually does)

| Behavior | Finding |
|----------|---------|
| Backend transmission of user data | **None.** App ships in `mock` flavor (`AppConfig.useMockData == true`); profile, orders, addresses, wishlist, cart are stored **only in on-device Hive + Keychain**. |
| Firebase Analytics / Crashlytics / Messaging | **Inactive.** Gated behind `FIREBASE_ENABLED` (defaults false) **and** there is **no `GoogleService-Info.plist`** in the iOS target, so `Firebase.initializeApp()` never runs. SDKs are compiled in but dormant. See caveat below. |
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
| Usage/Analytics data | No* | — | No | Firebase present but **inactive** (see caveat) |
| Diagnostics/Crash data | No* | — | No | Crashlytics present but **inactive** (see caveat) |

## ⚠️ Caveat you must decide on (MANUAL)

The Firebase/Google analytics SDKs (`firebase_analytics`, `firebase_crashlytics`,
`GoogleAppMeasurement`) are **compiled into the binary** even though they never
initialize (no `GoogleService-Info.plist`, gated off). Apple's privacy review
can detect bundled analytics SDKs. Two clean options — pick one before submit:

1. **Declare "Data Not Collected" (recommended for this build)** — truthful to
   runtime behavior. Low risk because the SDKs are provably dormant (no config
   file, no init). Keep this documentation on hand in case a reviewer asks.
2. **Remove the Firebase dependencies from this release** — if you want zero
   ambiguity, drop `firebase_*` from `pubspec.yaml` for this submission and
   re-add them when the backend/analytics actually go live. This is a code
   change outside the current phase; tell me and I'll do it.

Do **not** declare analytics/tracking as *collected* for this build — the code
does not perform it, and over-declaring is itself inaccurate.

## When the backend / Firebase go live (future)

Re-answer the questionnaire to declare, at minimum: Contact Info (name, email,
phone), User Content (addresses, order history), Identifiers (user id), and —
if Firebase is enabled — Usage Data and Diagnostics (linked or not per config).
Tracking stays **No** unless an ad/attribution SDK is added.

## Privacy policy URL

Public policy: `https://<your-github-pages-domain>/privacy-policy.html`
(updated in this branch to match the on-device-only reality and the in-app
deletion path). Verify it returns HTTP 200 publicly before submitting — see
APP_REVIEW_NOTES.md.
