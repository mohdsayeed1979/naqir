# -*- coding: utf-8 -*-
"""
One-off reconnaissance script: pull the full public product catalog from
naqirgiftbox.com's own storefront JSON API (the same public, unauthenticated
endpoint any visitor's browser calls to render /en/products/) so the Flutter
app can be wired up with the store's real product photos.

Not committed as an app dependency - this is a throwaway data-collection
script, kept under scripts/scraping/ purely as an audit trail of how the
catalog_full.json snapshot was produced.
"""
import json
import time
import urllib.request
import urllib.error

BASE = "https://naqirgiftbox.com"
HEADERS = {
    "Accept": "application/json",
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0 Safari/537.36",
    "Cookie": "locale=en-sa",
}


def get_json(path, retries=3):
    url = BASE + path
    for attempt in range(retries):
        try:
            req = urllib.request.Request(url, headers=HEADERS)
            with urllib.request.urlopen(req, timeout=30) as resp:
                return json.loads(resp.read().decode("utf-8"))
        except (urllib.error.URLError, urllib.error.HTTPError) as e:
            if attempt == retries - 1:
                print(f"FAILED {path}: {e}")
                return None
            time.sleep(1.5 * (attempt + 1))
    return None


def main():
    # 1. Fetch every page of the product list.
    all_products = []
    page = 1
    while True:
        data = get_json(f"/api/v1/products?page={page}")
        if not data or not data.get("results"):
            break
        all_products.extend(data["results"])
        print(f"page {page}: {len(data['results'])} products (running total {len(all_products)})")
        if not data.get("next"):
            break
        page += 1
        time.sleep(0.2)

    print(f"\nTotal products fetched: {len(all_products)}")

    # 2. For parent (variant) products, fetch full detail to get the variants list.
    parents = [p for p in all_products if p.get("structure") == "parent"]
    print(f"Parent (variant) products: {len(parents)}")

    parent_details = {}
    for i, p in enumerate(parents):
        detail = get_json(f"/api/v1/products/{p['slug']}")
        if detail:
            prod = detail.get("product", detail)
            parent_details[p["slug"]] = prod
        if (i + 1) % 10 == 0:
            print(f"  parent detail {i+1}/{len(parents)}")
        time.sleep(0.15)

    # 3. Collect all variant (child) ids across all parents, fetch each child's own detail
    #    (gives an authoritative, unambiguous main_image per variant).
    variant_ids = []
    for slug, prod in parent_details.items():
        for v in prod.get("variants", []) or []:
            variant_ids.append((slug, v["id"]))

    print(f"\nVariant children to fetch: {len(variant_ids)}")
    variant_details = {}
    for i, (slug, vid) in enumerate(variant_ids):
        detail = get_json(f"/api/v1/products/{vid}")
        if detail:
            prod = detail.get("product", detail)
            variant_details[vid] = prod
        if (i + 1) % 20 == 0:
            print(f"  variant detail {i+1}/{len(variant_ids)}")
        time.sleep(0.15)

    # 4. Save everything as raw snapshots for offline processing.
    with open("scripts/scraping/catalog_full.json", "w", encoding="utf-8") as f:
        json.dump(all_products, f, ensure_ascii=False)
    with open("scripts/scraping/parent_details.json", "w", encoding="utf-8") as f:
        json.dump(parent_details, f, ensure_ascii=False)
    with open("scripts/scraping/variant_details.json", "w", encoding="utf-8") as f:
        json.dump(variant_details, f, ensure_ascii=False)

    print("\nSaved:")
    print("  scripts/scraping/catalog_full.json      (all 191 list-level products)")
    print("  scripts/scraping/parent_details.json    (full detail for parent/variant products)")
    print("  scripts/scraping/variant_details.json   (full detail for each variant child)")


if __name__ == "__main__":
    main()
