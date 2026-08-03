# API Documentation

This documents the **generic REST contract** every `RemoteDataSource` in this codebase implements
(`lib/features/*/data/datasources/*_remote_data_source.dart`). It is not naqirgiftbox.com's actual
API — see [ARCHITECTURE.md §1](ARCHITECTURE.md#1-source-analysis) for why this app doesn't call
that private, session-authenticated storefront API. This is the contract a **real backend needs to
expose** (whether that's a Zid Partner API adapter, a custom backend, or anything else) to plug in
without touching a single screen or view-model.

All endpoints are relative to `AppConfig.apiBaseUrl` (see [INSTALLATION.md](INSTALLATION.md#environment--flavor-flags)).
Request/response bodies are JSON, `snake_case` keys (mapped to camelCase Dart via `@JsonKey` on
each DTO). Authenticated endpoints expect `Authorization: Bearer <access_token>`.

## Auth

| Method | Path | Body | Returns |
|---|---|---|---|
| POST | `/auth/login` | `{identifier, password}` | `AuthResult` |
| POST | `/auth/register` | `{full_name, email, password}` | `AuthResult` |
| POST | `/auth/otp/request` | `{phone}` | `204` |
| POST | `/auth/otp/verify` | `{phone, code}` | `AuthResult` |
| POST | `/auth/forgot-password` | `{email}` | `204` |
| POST | `/auth/refresh` | `{refresh_token}` | `{access_token, refresh_token}` |
| POST | `/auth/logout` | — | `204` |
| PATCH | `/account` | `{full_name, phone}` | `User` |

**`AuthResult`**: `{access_token, refresh_token, user: User}`
**`User`**: `{id, full_name, email, phone?, avatar_url?}`

A `401` on any authenticated request triggers exactly one silent `POST /auth/refresh` + retry (see
`AuthInterceptor`, `lib/core/network/interceptors/auth_interceptor.dart`) before surfacing an
`UnauthorizedFailure` to the UI.

## Catalog

| Method | Path | Query params | Returns |
|---|---|---|---|
| GET | `/products` | `category_id, q, min_price, max_price, discounted_only, featured_only, new_only, sort, page, page_size` | `{items: Product[], total_count}` |
| GET | `/products/{id}` | — | `Product` |
| GET | `/products/{id}/related` | `limit` | `{items: Product[]}` |
| GET | `/categories` | — | `{items: Category[]}` |
| GET | `/categories/{id}` | — | `Category` |

`sort` is one of `newest`, `popular`, `priceLowToHigh`, `priceHighToLow` (matches
`ProductSortOption` enum names exactly).

**`Product`**: `{id, slug, name, short_description, description, specifications: {[k]: v},
images: string[], price, compare_at_price?, sku, category_id, stock_quantity, rating,
review_count, created_at, video_url?, variants: Variant[], is_featured, is_new}`
**`Variant`**: `{id, label, image_url?, price_override?, in_stock}`
**`Category`**: `{id, name, slug, image_url?, parent_id?}`

There is currently no reviews endpoint — the in-app review list is a deterministic mock generator
(`lib/features/products/presentation/providers/review_providers.dart`). Add a `GET
/products/{id}/reviews` endpoint and swap that provider's data source when one exists.

## Search

| Method | Path | Query | Returns |
|---|---|---|---|
| GET | `/search` | `q, ...same filters as /products` | `{items: Product[], total_count}` — reuses the `/products` listing path with `q` set |
| GET | `/search/suggestions` | `q` | *(not yet consumed — search history/trending are local-only today, see below)* |
| GET | `/search/trending` | — | *(not yet consumed)* |

Search history and "trending searches" are currently local-only (`SearchHistoryRepository`, Hive)
and a static list respectively — no backend calls are made for them today. The endpoints above are
reserved for when that becomes server-driven.

## Cart / Wishlist / Addresses / Orders

**Not called today.** Cart, wishlist, address book, and orders are local-only, offline-first
device state (Hive-backed — see `ARCHITECTURE.md`'s note on why `Cart`/`Address`/`Order` skip the
DTO-separation pattern `Product`/`Category` use). `ApiEndpoints` reserves paths
(`/cart`, `/wishlist`, `/addresses`, `/orders`) for whenever server-side sync is added — that's a
genuinely new capability (merging local + remote state), not a data-source swap, so it isn't
built yet.

## Error format

Any non-2xx response should return:

```json
{ "message": "Human-readable summary", "errors": { "field_name": "Field-specific message" } }
```

`ApiClient` (`lib/core/network/api_client.dart`) maps status codes to typed failures:

| Status | Failure |
|---|---|
| 400 | `ValidationFailure` (reads `errors` for field-level messages) |
| 401 | `UnauthorizedFailure` |
| 404 | `NotFoundFailure` |
| other | `ServerFailure` |
| network/timeout | `NetworkFailure` |

## Payments

Not part of this REST contract — see [DEPLOYMENT.md](DEPLOYMENT.md#payments) for wiring a real
payment gateway through `PaymentGateway`/`PaymentGatewayFactory`
(`lib/features/payment/domain/repositories/payment_gateway.dart`).
