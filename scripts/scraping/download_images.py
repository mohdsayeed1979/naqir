# -*- coding: utf-8 -*-
"""
Downloads the primary (first gallery) image for every real product in
catalog.json, re-encodes it as a reasonably-sized JPEG (longest edge capped,
so the app bundle doesn't balloon with full-resolution source photos), and
saves it to assets/images/products/<SKU>.jpg.

Extended galleries and per-variant photos are intentionally NOT bundled
locally - they're served through the app's existing CachedNetworkImage path
straight from the original media.zid.store URLs (tier 2 of the fallback
chain), which keeps the app small while every surface still shows a real,
correct photo.
"""
import io
import json
import os
import re
import time
import urllib.request
import urllib.error

from PIL import Image

HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0 Safari/537.36",
}
OUT_DIR = "assets/images/products"
MAX_EDGE = 1000
JPEG_QUALITY = 82


def safe_filename(sku):
    return re.sub(r"[^A-Za-z0-9_-]", "_", sku)


def download_and_process(url, out_path, retries=3):
    for attempt in range(retries):
        try:
            req = urllib.request.Request(url, headers=HEADERS)
            with urllib.request.urlopen(req, timeout=30) as resp:
                raw = resp.read()
            img = Image.open(io.BytesIO(raw))
            img = img.convert("RGB")
            w, h = img.size
            if max(w, h) > MAX_EDGE:
                if w >= h:
                    new_w, new_h = MAX_EDGE, round(h * MAX_EDGE / w)
                else:
                    new_h, new_w = MAX_EDGE, round(w * MAX_EDGE / h)
                img = img.resize((new_w, new_h), Image.LANCZOS)
            img.save(out_path, "JPEG", quality=JPEG_QUALITY, optimize=True)
            return True, os.path.getsize(out_path), img.size
        except Exception as e:
            if attempt == retries - 1:
                return False, str(e), None
            time.sleep(1.0 * (attempt + 1))
    return False, "unreachable", None


def main():
    os.makedirs(OUT_DIR, exist_ok=True)
    with open("scripts/scraping/catalog.json", encoding="utf-8") as f:
        catalog = json.load(f)

    results = []
    for i, r in enumerate(catalog):
        sku = r["sku"]
        fname = safe_filename(sku) + ".jpg"
        out_path = os.path.join(OUT_DIR, fname)
        primary_url = r["images"][0] if r["images"] else None
        if not primary_url:
            results.append({"sku": sku, "ok": False, "reason": "no source image"})
            continue
        if os.path.exists(out_path):
            results.append({"sku": sku, "ok": True, "file": fname, "cached": True})
            continue
        ok, info, size = download_and_process(primary_url, out_path)
        if ok:
            results.append({"sku": sku, "ok": True, "file": fname, "bytes": info, "size": size})
        else:
            results.append({"sku": sku, "ok": False, "reason": info, "url": primary_url})
        if (i + 1) % 25 == 0:
            print(f"{i+1}/{len(catalog)} processed")
        time.sleep(0.05)

    ok_count = sum(1 for r in results if r["ok"])
    fail = [r for r in results if not r["ok"]]
    total_bytes = sum(r.get("bytes", 0) for r in results if r["ok"] and not r.get("cached"))

    print(f"\nDownloaded/processed OK: {ok_count}/{len(catalog)}")
    print(f"Failed: {len(fail)}")
    for r in fail:
        print("  FAIL", r["sku"], r.get("reason"))
    print(f"Total new bytes written: {total_bytes} ({total_bytes/1024/1024:.1f} MB)")

    with open("scripts/scraping/download_results.json", "w", encoding="utf-8") as f:
        json.dump(results, f, ensure_ascii=False, indent=1)


if __name__ == "__main__":
    main()
