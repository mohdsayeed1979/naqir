# Account Deletion (Guideline 5.1.1(v))

Naqir Gift Box supports in-app, self-service account deletion. This document
describes exactly what happens, why there is **no SQL migration**, and how a
server-side deletion slots in when a real backend is added.

## User-facing flow

`Profile → Settings → Account → Delete Account`

1. A destructive **warning dialog** explains that deletion is permanent and
   lists what is removed (profile, orders, addresses, wishlist, cart,
   preferences).
2. The user must **explicitly confirm** ("Delete Account"); the default/cancel
   action is "Keep My Account".
3. A blocking spinner prevents double submission while deletion runs.
4. On **success**: all in-memory state is invalidated, a confirmation snackbar
   is shown, and the app returns to the **signed-out guest** state (Home).
5. On **failure**: nothing is deleted, the user **stays signed in**, and an
   error is shown. A false success is never reported.

Only a signed-in user sees the option, and a user can only ever delete their
**own** account (see Security below).

## Why there is no `ACCOUNT_DELETION.sql`

This app has **no Supabase and no live backend yet**. It ships in the `mock`
flavor (`AppConfig.useMockData == true`): authentication fabricates a local
session and **no server-side user record is ever created**. There is nothing
on a server to delete, so a `SECURITY DEFINER` RPC / SQL migration would be
dead code against a database that does not exist.

Consequently, an "account" today is **entirely local device data**. Deleting
it completely and honestly satisfies Guideline 5.1.1(v).

## What is deleted (current, local-only)

Erased by `LocalUserDataStore.clearAll()`
(`lib/core/storage/local_user_data.dart`):

| Store | Location | Contents |
|-------|----------|----------|
| Auth tokens | `flutter_secure_storage` (Keychain) | access + refresh tokens |
| Cached profile | Hive `settings_box` key `cached_user` | name, email, phone, id |
| Notification prefs | Hive `settings_box` (`notif_*` keys) | per-user toggles |
| Cart | Hive `cart_box` | cart line items |
| Wishlist | Hive `wishlist_box` | saved product ids |
| Addresses | Hive `addresses_box` | names, phone, street addresses |
| Orders | Hive `orders_box` | order history + shipping addresses |
| Recently viewed | Hive `recently_viewed_box` | browsed product ids |
| Search history | Hive `search_history_box` | past search terms |

**Kept** (device preferences, not personal data, so the app doesn't reset to
onboarding): `onboarding_seen`, `locale`, `theme_mode`.

## Security

- The UI only calls deletion for the currently authenticated session.
- No user id is ever sent from the client. In the future remote flavor, the
  server identifies the account **from the bearer token** on the
  `DELETE /account` request (attached by `AuthInterceptor`), so a user can
  only delete their own account.
- No service-role or privileged credential exists anywhere in the app.
- Server-side deletion is attempted **first**; only if it succeeds is local
  data wiped. Any error aborts the wipe and keeps the user signed in
  (`AuthRepositoryImpl.deleteAccount`).

## When a real backend is added

1. Implement the `DELETE /account` endpoint. It must:
   - authorize the caller from the session token (never a client-supplied id),
   - delete the user's row and all dependent records (orders, addresses,
     wishlist, etc.) via `ON DELETE CASCADE` or an equivalent transaction,
   - delete the auth account itself,
   - return 2xx only when deletion fully succeeded.
2. `AuthRemoteDataSource.deleteAccount()` already calls this endpoint — no
   client change is needed.
3. If/when the backend is Supabase specifically, expose deletion as a
   `security definer` function keyed on `auth.uid()` (deleting only the
   caller's data), grant `execute` to `authenticated` only, and call it via
   RPC instead of a REST `DELETE`. That SQL belongs with the backend repo, not
   the app, and must not embed any service-role key in the client.

## Automated test

`test/features/authentication/account_deletion_test.dart` verifies the
honest-failure contract: deletion is refused when signed out, wipes local data
only on backend success, and preserves all data when the backend call fails.
