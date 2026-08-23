# Guideline 5.1.1(ix) — Organization enrollment requirement

## Status: CODE FIX — NOT APPLICABLE. External Apple Developer action required.

Apple requires that the account submitting this app be enrolled in the Apple
Developer Program as an **Organization**, not as an **Individual**. This is an
account/enrollment matter and **cannot be fixed in the app's code**. No code
change was made for this guideline, and none can resolve it.

## Why it applies here
The app presents as a **business/brand** ("Naqir Gift Box"), not a personal
project: it uses a company bundle identifier (`com.naqirgiftbox.naqirgiftbox`),
company branding, a business support email (`r.albuthi@almousa.com.sa`), a
business WhatsApp line, and represents a real Saudi retailer. Apple does not
allow commercial/brand apps to be published under an Individual account, which
is why 5.1.1(ix) was raised. So yes — this guideline applies.

## What you must do (choose ONE) — MANUAL, outside this repo

### Option 1 — Convert the existing account to Organization
1. Sign in at <https://developer.apple.com/account>.
2. If eligible, request conversion from Individual to Organization membership
   (Apple support / the Membership section). You will need:
   - A **legal entity name** matching official registration.
   - A **D-U-N-S Number** for the entity (free from Dun & Bradstreet;
     <https://developer.apple.com/enroll/duns-lookup/>). Allow several days.
   - Authority to bind the organization, and a public business presence
     (website/phone) Apple can verify.
3. Complete Apple's business verification.

### Option 2 — Transfer the app to an Organization account
If a separate Organization account already exists (or you create one), you can
**transfer** the app from the Individual account to the Organization account in
App Store Connect (App → General → App Information → Transfer App), subject to
Apple's transfer eligibility rules.

## Important
- Do not attempt to disguise an Individual account as an Organization — Apple
  verifies the legal entity and will reject/deny.
- This is a **hard blocker for approval** independent of all code fixes. The
  build can be prepared and uploaded, but the submission will not pass review
  until the account is an Organization (or the app is under one).
- Timeline: D-U-N-S lookup + business verification can take from a few days to
  a couple of weeks — start this now, in parallel with the code work.

## Additional business verification that may be required
- Legal entity legal name, address, and website consistent with the D-U-N-S
  record.
- A work email at the business domain may be requested.
- For Saudi entities, a Commercial Registration (CR) may be needed to
  substantiate the legal entity for the D-U-N-S/verification steps.
