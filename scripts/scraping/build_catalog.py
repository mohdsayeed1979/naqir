# -*- coding: utf-8 -*-
"""
Consolidates the raw API snapshots (catalog_full.json, parent_details.json,
variant_details.json) into one clean catalog.json: one record per real
product, with original-resolution image URLs and, for products sold in
several options, a resolved per-variant image list.
"""
import json
import re
import html


def strip_html(s):
    if not s:
        return ""
    s = re.sub(r"<[^>]+>", " ", s)
    s = html.unescape(s)
    return re.sub(r"\s+", " ", s).strip()


def product_line(slug):
    if slug.startswith("termeh-chest"):
        return "Termeh Chest"
    if slug.startswith("termeh-box"):
        return "Termeh Box"
    return "Gift Box"


def main():
    with open("scripts/scraping/catalog_full.json", encoding="utf-8") as f:
        products = json.load(f)
    with open("scripts/scraping/parent_details.json", encoding="utf-8") as f:
        parent_details = json.load(f)
    with open("scripts/scraping/variant_details.json", encoding="utf-8") as f:
        variant_details = json.load(f)

    catalog = []
    seen_skus = set()

    for p in products:
        sku = p["sku"]
        if sku in seen_skus:
            print(f"WARN duplicate sku skipped: {sku}")
            continue
        seen_skus.add(sku)

        images = [i["image"]["full_size"] for i in (p.get("images") or []) if i.get("image")]

        record = {
            "sku": sku,
            "name": p["name"].strip(),
            "slug": p["slug"],
            "price": p["price"],
            "sale_price": p.get("sale_price"),
            "structure": p["structure"],
            "line": product_line(p["slug"]),
            "description": strip_html(p.get("short_description")),
            "quantity": p.get("quantity", 0),
            "created_at": p.get("created_at"),
            "images": images,
            "variants": [],
        }

        if p["structure"] == "parent":
            detail = parent_details.get(p["slug"])
            if detail:
                # prefer full detail's own images (usually same set, occasionally richer)
                detail_images = [
                    i["image"]["full_size"] for i in (detail.get("images") or []) if i.get("image")
                ]
                if detail_images:
                    record["images"] = detail_images
                record["description"] = strip_html(detail.get("short_description")) or record["description"]

                for v in detail.get("variants", []) or []:
                    vid = v["id"]
                    vdetail = variant_details.get(vid)
                    attrs = v.get("attributes") or []
                    label = attrs[0]["value"] if attrs else v.get("name")
                    vimg = None
                    if vdetail:
                        mi = vdetail.get("main_image")
                        if mi and mi.get("image"):
                            vimg = mi["image"]["full_size"]
                        elif vdetail.get("images"):
                            imgs = vdetail["images"]
                            if imgs:
                                vimg = imgs[0]["image"]["full_size"]
                    record["variants"].append(
                        {
                            "id": vid,
                            "sku": v.get("sku"),
                            "label": label,
                            "price": vdetail.get("price") if vdetail else None,
                            "image": vimg,
                        }
                    )

        catalog.append(record)

    with open("scripts/scraping/catalog.json", "w", encoding="utf-8") as f:
        json.dump(catalog, f, ensure_ascii=False, indent=1)

    total_images = sum(len(r["images"]) for r in catalog)
    total_variant_images = sum(1 for r in catalog for v in r["variants"] if v["image"])
    total_variants = sum(len(r["variants"]) for r in catalog)
    lines = {}
    for r in catalog:
        lines[r["line"]] = lines.get(r["line"], 0) + 1

    print(f"Products: {len(catalog)}")
    print(f"Product lines: {lines}")
    print(f"Total gallery images referenced: {total_images}")
    print(f"Parent products: {sum(1 for r in catalog if r['structure']=='parent')}")
    print(f"Total variants: {total_variants}, with resolved image: {total_variant_images}")


if __name__ == "__main__":
    main()
