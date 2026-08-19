# App Review Notes — Naqir Gift Box

**App:** Naqir Gift Box · **Bundle ID:** com.naqirgiftbox.naqirgiftbox
**Version:** 1.0.0 · **Platform:** iOS/iPadOS (Universal)

## A. What the app does
Naqir Gift Box is a catalog and inquiry app for a Saudi premium dates and gift
box retailer. Users browse products and categories, view product details, save
items to a wishlist, add items to a cart, and place a Cash-on-Delivery order or
contact the shop for a quote via WhatsApp/email.

## B. Guest browsing (no login required)
Browsing needs **no account**. On first launch you can proceed straight into
the app and use: Home, Categories, Product listings, Product details, Search
(including voice search), Wishlist and Cart — all without signing in.

## C. Login / account creation
The app currently runs in **offline mode** — there is no live backend yet, so
authentication is handled locally on the device. You can:
- **Register** a new account from Profile → Log in → Register (any name, any
  email, any password of 6+ characters is accepted), **or**
- **Log in** with any well-formed email and a password of at least 6
  characters.

**Demo credentials (work as-is):**
- Email: `reviewer@naqirgiftbox.com`
- Password: `Review2026`

> Login is only needed to view account-gated screens (My Orders, Saved
> Addresses, Edit Profile). Everything else works as a guest.

## D. Account deletion (Guideline 5.1.1(v))
Path: **Profile → Settings → Account → Delete Account.**
A warning explains deletion is permanent; after you confirm, the account and
all associated on-device data (profile, orders, addresses, wishlist, cart,
preferences) are erased immediately and the app returns to the signed-out
state. Because data is stored on-device in this release, deletion is instant
and complete.

## E. Payment behavior (Guideline 2.1(a) fix)
This release intentionally offers **Cash on Delivery only**:
- **Card payment is not offered.**
- **Apple Pay is not offered.**
- **Google Pay is not offered.**

The previous submission exposed Apple Pay/Card options that were not yet
connected to a payment provider and therefore failed. Those options have been
removed from checkout so no broken payment flow is reachable. To place an
order, select an address → Cash on Delivery → Place Order. For other
arrangements, customers use Contact Us (WhatsApp/email) to request a quote.

## F. WhatsApp / email inquiry
Profile → Contact Us opens WhatsApp (`+966 50 545 7678`) or the mail composer
(`r.albuthi@almousa.com.sa`). These open the respective apps only when tapped.

## G. External services used
- **None active in this build.** No payment processor, no live backend, no
  active analytics. Firebase SDKs are bundled but dormant (no configuration
  file, disabled by default). Product images load from `naqirgiftbox.com`.
  Voice search uses Apple's on-device speech recognition.

## H. Permissions
- **Microphone + Speech Recognition** — used only for optional voice search on
  the Search screen. Denying them does not block any other feature.

## I. Testing devices / notes
- Universal app; verified in iOS Simulator on iPhone and iPad.
- No region lock, but content/pricing is Saudi Arabia oriented (SAR, Arabic +
  English; the app supports RTL Arabic).

## J. Privacy policy
Public, no login required:
`https://mohdsayeed1979.github.io/naqir/privacy-policy.html`
Account-deletion instructions: `.../data-deletion.html`

## K. Anything else
The app fully functions offline/without a backend for review purposes — no
server setup or credentials are required beyond the demo login above.
