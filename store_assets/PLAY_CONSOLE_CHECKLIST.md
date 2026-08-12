# Play Console Setup Checklist — Naqir Gift Box

Everything below is prepared and ready to paste in. Items marked **[YOU]** need your Google
account/payment/hosting — I can't do those for you (see the safety notes at the bottom for why).

## 1. Create the app

- **App name**: `Naqir Gift Box`
- **Default language**: English (United States) — or English (India) if that's what's available;
  Arabic can be added as an additional store listing language later, it doesn't need to be the
  default.
- **App or game**: App
- **Free or paid**: Free
- Declarations: accept Play Console's Developer Program Policies and US export laws checkboxes.

**[YOU]**: Requires a Google Play Console developer account, which needs a one-time $25 USD
registration fee. I never handle payments or create accounts on your behalf — you'll need to do
this step yourself at [play.google.com/console](https://play.google.com/console).

## 2. App bundle (the actual app file)

Built and signed: **`build/app/outputs/bundle/release/app-release.aab`**

Signed with a new upload keystore generated for this project:
- Keystore file: `C:\Users\Abdul\naqirgiftbox-upload-keystore.jks`
- Alias: `upload`
- Password: stored in `android/key.properties` (gitignored — not in version control)

**Back this keystore file up somewhere safe** (a password manager or encrypted backup — not just
this one machine). Play Console defaults new apps into **Play App Signing**, where Google holds
the final signing key and this "upload key" can be reset via Play Console support if it's ever
lost — but that's a support process, not instant, so don't rely on losing it being a non-event.

Upload this `.aab` file to your chosen release track (Internal testing is the fastest way to
start — no review wait).

### Release notes (per-language, 500 char limit each)

**English** (350 chars):
```
Naqir Gift Box — Internal Testing v1.0.0

First testing build! Browse gift boxes & dates, search, filter, save to wishlist, add to cart, and check out with saved addresses. Track orders, switch English/Arabic (full RTL), and toggle dark mode.

Running on sample catalog data for this test phase — Cash on Delivery only for now. Feedback welcome!
```

**Arabic** (477 chars):
```
نقير قيفت بوكس — نسخة تجريبية v1.0.0

تصفح علب الهدايا والتمور، ابحث وصفِّ، احفظ في المفضلة، أضف للسلة، وأكمل الشراء بعناوين محفوظة. تتبّع طلباتك، وبدّل بين العربية والإنجليزية، وجرّب الوضع الداكن.

بيانات تجريبية حاليًا، والدفع عند الاستلام فقط. نرحب بملاحظاتكم!
```

## 3. Store listing

**Short description** (80 char max):
```
Handcrafted gift boxes & dates from Riyadh. Browse, wishlist, track orders.
```

**Full description** (4000 char max):
```
Naqir Gift Box (نقير التمر) brings Riyadh's finest handcrafted gift boxes and premium dates
straight to your phone.

Every box is assembled by hand in our Riyadh workshop, pairing hand-selected dates with fine
woven fabrics and a signature ribbon finish — designed for the moments that deserve more than an
ordinary gift.

WHAT YOU CAN DO
• Browse our full collection: gift boxes, dates trays, chocolate collections, oud & incense sets,
  wedding favors, and corporate gifting
• Search by name or use voice search to find exactly what you're looking for
• Filter and sort by price, popularity, and new arrivals
• Save favorites to your wishlist and pick up where you left off with Recently Viewed
• Add to cart, apply coupon codes, and check out with saved addresses
• Track every order from confirmation through delivery
• Manage your profile, addresses, and notification preferences
• Switch seamlessly between English and Arabic, with full right-to-left support
• Choose light or dark mode to match your preference

CRAFTED FOR EVERY OCCASION
Whether it's Eid, a wedding, a corporate gift, or a personal treat, our curated collections are
designed to make every gifting moment feel considered and refined.

Naqir Gift Box is based in Al-Diyafa, Riyadh, Saudi Arabia.
```

**App icon**: `store_assets/play_store_icon_512.png` (512×512)
**Feature graphic**: `store_assets/play_store_feature_graphic_1024x500.png` (1024×500)

**Phone screenshots (min 2, max 8)** — **[YOU]**: easiest to grab these straight from your own
device the way you already did in this conversation (`flutter run --release` on your phone, then
screenshot Home, Product Details, Cart, and Checkout). Any screenshot 320px–3840px on the long
edge works; your phone's native resolution is fine.

**Category**: Shopping
**Contact details**: phone `+966505457678`, email `r.albuthi@almousa.com.sa` (from the site's own
published contact info — swap if you'd rather use a different support address)

### Arabic translation (recommended for your actual market)

Play Console offers an "Import translations with AI" auto-translate option — skip it. It's a
literal machine translation that won't know your real brand name and reads stiffer than
hand-written copy. Add Arabic manually under *Store presence → Main store listing → Translations*
with this instead:

**App name (AR)**: `نقير التمر` — the business's real name, not a transliteration of the English
one. (Caught and fixed the same mistake in the app's own Arabic localization while preparing
this — see CHANGELOG.)

**Short description (AR)** (73/80 chars):
```
علب هدايا وتمور فاخرة، مصنوعة يدويًا في الرياض. تصفح واحفظ وتتبّع طلباتك.
```

**Full description (AR)** (1057/4000 chars):
```
نقير التمر يقدّم لكم أرقى علب الهدايا والتمور المصنوعة يدويًا في الرياض، مباشرة إلى هاتفك.

كل علبة تُجمَّع يدويًا في ورشتنا بالرياض، بمزيج من تمور مختارة بعناية وأقمشة منسوجة فاخرة ولمسة شريط مميزة — لتناسب اللحظات التي تستحق أكثر من هدية عادية.

ماذا يمكنك أن تفعل
• تصفّح مجموعتنا الكاملة: علب الهدايا، أطباق التمور، تشكيلات الشوكولاتة، أطقم العود والبخور، هدايا الأعراس، والهدايا المؤسسية
• ابحث بالاسم أو استخدم البحث الصوتي للعثور على ما تريد بسرعة
• صفِّ ورتّب النتائج حسب السعر أو الأكثر شيوعًا أو الأحدث
• احفظ المفضلة في قائمة الأمنيات، وتابع من حيث توقفت مع "شوهد مؤخرًا"
• أضف إلى السلة، فعِّل كوبونات الخصم، وأكمل الشراء بعناوين محفوظة
• تتبّع كل طلب من لحظة التأكيد وحتى التوصيل
• أدِر ملفك الشخصي وعناوينك وتفضيلات الإشعارات
• بدِّل بسهولة بين العربية والإنجليزية، بدعم كامل للكتابة من اليمين لليسار
• اختر الوضع الفاتح أو الداكن بما يناسبك

لكل مناسبة
سواء كانت عيدًا أو زفافًا أو هدية للشركات أو مكافأة شخصية، صُمِّمت مجموعاتنا المنتقاة لتجعل كل لحظة إهداء لحظة راقية ومدروسة.

نقير التمر مقرّها في الضياء، الرياض، المملكة العربية السعودية.
```

## 4. Privacy policy & legal pages — **LIVE**

Google requires a **live, public URL** — in-app text isn't enough. The legal/support site is now
hosted on GitHub Pages (source: `main` branch, `/docs` folder) and served over HTTPS:

- **Privacy policy** (paste into Play Console's "Privacy policy" field):
  `https://mohdsayeed1979.github.io/naqir/privacy-policy.html`
- Support / help center: `https://mohdsayeed1979.github.io/naqir/support.html`
- Data & account deletion: `https://mohdsayeed1979.github.io/naqir/data-deletion.html`
- Terms & conditions: `https://mohdsayeed1979.github.io/naqir/terms.html`
- Contact: `https://mohdsayeed1979.github.io/naqir/contact.html`
- Landing page: `https://mohdsayeed1979.github.io/naqir/`

These pages live in `docs/` and are the canonical, hosted versions. (An earlier standalone
`store_assets/privacy_policy.html` draft predates this site; the hosted `docs/privacy-policy.html`
above is the one to use.)

## 5. Data Safety form — draft answers

Fill this in at *App content → Data safety*. This reflects what the app **actually does today**
(mock data, no live backend/payment/analytics) — revisit it once you connect a real backend,
Firebase, or a payment SDK, since each of those changes what's actually collected.

| Question | Answer |
|---|---|
| Does your app collect or share user data? | Yes |
| Personal info → Name | Collected (account registration), not shared, encrypted in transit, user can request deletion |
| Personal info → Email address | Collected (account/login), not shared, encrypted in transit, user can request deletion |
| Personal info → Phone number | Collected (account/OTP login, order contact), not shared, encrypted in transit, user can request deletion |
| Personal info → Address | Collected (shipping), not shared, encrypted in transit, user can request deletion |
| Financial info | Not collected *(no live payment SDK yet — update once one is added)* |
| Location | Not collected (no GPS/location permission requested) |
| App activity | Not collected *(Firebase Analytics is in the code but disabled by default — update if you enable it)* |
| Device or other IDs | Not collected |
| Is data encrypted in transit? | Yes (HTTPS) |
| Can users request data deletion? | Yes, via contacting support — **note**: Play policy increasingly expects an *in-app* account deletion option for apps with account creation; this app doesn't have one built yet. Worth adding before a production (non-testing) release. |

## 6. Content rating (IARC questionnaire) — likely answers

Fill this in at *App content → Content rating*. Answer the actual questionnaire in-console; these
are what the honest answers should be based on the app's real content:

- Violence, sexual content, profanity, controlled substances, gambling: **None** — this is a
  shopping app with no such content.
- User-generated content shared with other users (chat, forums, public reviews from other real
  users): **No** — the review content shown is not user-submitted/shared publicly.
- Users can make purchases / spend real money: **Yes** — it's a shopping app.
- Shares location with other users: **No**.

## 7. Target audience & content

- Target age group: 18+ recommended (it's a shopping app with account creation and purchases;
  Google applies extra restrictions — like disallowed ads personalization — to anything appealing
  to under-13s, which this doesn't).
- "App primarily child-directed": No.

## 8. Ads declaration

- Contains ads: **No** (no ad SDK is integrated).

## 9. App access

If reviewers need to log in to test full functionality, provide test credentials or note that the
app is fully browsable as a guest (browsing, search, wishlist, and cart all work without an
account — only checkout and order history require signing in, and registration/OTP login accept
any well-formed input against the mock backend today).

## 10. Testers

**[YOU]**: Add tester email addresses (or a Google Group) under your chosen testing track — this
happens directly in the Play Console UI after the app bundle is uploaded.

---

## Why some of this says "[YOU]"

I don't create accounts, enter payment details, or take other irreversible/account-bound actions
on your behalf — see this session's standing safety rules. Everything that's just file generation,
writing, or local building, I've done. Everything that needs your Google account, your $25
payment, or a URL only you can host, is flagged above.
