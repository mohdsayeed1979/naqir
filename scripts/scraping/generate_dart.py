# -*- coding: utf-8 -*-
"""
Generates the Dart source for the real product catalog from catalog.json +
download_results.json:

  lib/features/products/data/datasources/product_image_mapping.dart
  lib/features/products/data/datasources/product_mock_data_source.dart
  lib/features/categories/data/datasources/category_mock_data_source.dart

This fully replaces the previous 15-product invented placeholder catalog
with the real 191-product catalog scraped from naqirgiftbox.com.
"""
import json
import re
from datetime import datetime, timezone

ASSET_DIR = "assets/images/products"

LINE_TO_CATEGORY = {
    "Termeh Box": ("cat-termeh-box", "Termeh Box"),
    "Termeh Chest": ("cat-termeh-chest", "Termeh Chest"),
    "Gift Box": ("cat-gift-box", "Gift Box"),
}


def dart_str(s):
    if s is None:
        return "null"
    s = s.replace("\\", "\\\\").replace("'", "\\'").replace("\n", "\\n").replace("\$", "\\$")
    return f"'{s}'"


def safe_filename(sku):
    return re.sub(r"[^A-Za-z0-9_-]", "_", sku)


def dart_id_from_sku(sku):
    """A short, readable Dart identifier fragment for comments only."""
    return re.sub(r"[^A-Za-z0-9]", "", sku)[:24]


def parse_dt(s):
    if not s:
        return None
    return datetime.fromisoformat(s.replace("Z", "+00:00"))


def main():
    with open("scripts/scraping/catalog.json", encoding="utf-8") as f:
        catalog = json.load(f)
    with open("scripts/scraping/download_results.json", encoding="utf-8") as f:
        downloads = {r["sku"]: r for r in json.load(f)}

    # ---- decide isNew / isFeatured ----
    with_dt = [(r, parse_dt(r.get("created_at"))) for r in catalog]
    with_dt = [(r, dt) for r, dt in with_dt if dt is not None]
    with_dt.sort(key=lambda x: x[1], reverse=True)
    new_skus = {r["sku"] for r, _ in with_dt[:10]}

    parents_sorted = sorted(
        [r for r in catalog if r["structure"] == "parent"],
        key=lambda r: r["price"],
        reverse=True,
    )
    featured_skus = {r["sku"] for r in parents_sorted[:10]}

    # ============================================================
    # 1. ProductImageMapping
    # ============================================================
    lines = []
    lines.append("// GENERATED from the real naqirgiftbox.com catalog.")
    lines.append("// Regenerate with scripts/scraping/generate_dart.py - do not hand-edit.")
    lines.append("//")
    lines.append("/// Maps each real product SKU (as published on naqirgiftbox.com) to the")
    lines.append("/// bundled local asset holding that product's primary photo, downloaded")
    lines.append("/// directly from the store's own product images.")
    lines.append("class ProductImageMapping {")
    lines.append("  static const Map<String, String> images = {")
    for r in catalog:
        sku = r["sku"]
        dl = downloads.get(sku)
        if dl and dl.get("ok"):
            path = f"{ASSET_DIR}/{dl['file']}"
            lines.append(f"    {dart_str(sku)}: {dart_str(path)},")
    lines.append("  };")
    lines.append("")
    lines.append("  /// Extended remote gallery images per SKU (product detail screen),")
    lines.append("  /// served straight from the store's own CDN via the existing")
    lines.append("  /// CachedNetworkImage path - kept remote so the app bundle doesn't")
    lines.append("  /// carry every gallery photo for all 191 products.")
    lines.append("  static const Map<String, List<String>> gallery = {")
    for r in catalog:
        sku = r["sku"]
        dl = downloads.get(sku)
        local_source_url = r["images"][0] if r["images"] else None
        rest = [u for u in r["images"][1:] if u != local_source_url]
        if dl and dl.get("ok") and rest:
            urls = ", ".join(dart_str(u) for u in rest[:6])
            lines.append(f"    {dart_str(sku)}: [{urls}],")
    lines.append("  };")
    lines.append("")
    lines.append("  /// Per-variant image URLs for products \"available in several options\",")
    lines.append("  /// keyed by SKU then by the real variant id.")
    lines.append("  static const Map<String, Map<String, String>> variantImages = {")
    for r in catalog:
        if r["structure"] != "parent":
            continue
        entries = [(v["id"], v["image"]) for v in r["variants"] if v["image"]]
        if not entries:
            continue
        inner = ", ".join(f"{dart_str(vid)}: {dart_str(url)}" for vid, url in entries)
        lines.append(f"    {dart_str(r['sku'])}: {{{inner}}},")
    lines.append("  };")
    lines.append("}")
    with open(
        "lib/features/products/data/datasources/product_image_mapping.dart", "w", encoding="utf-8"
    ) as f:
        f.write("\n".join(lines) + "\n")

    # ============================================================
    # 2. product_mock_data_source.dart
    # ============================================================
    out = []
    out.append("import 'package:naqirgiftbox/features/products/data/datasources/product_data_source.dart';")
    out.append("import 'package:naqirgiftbox/features/products/data/models/product_dto.dart';")
    out.append("import 'package:naqirgiftbox/core/error/exceptions.dart';")
    out.append("import 'package:naqirgiftbox/features/products/domain/entities/product_query.dart';")
    out.append("")
    out.append("/// Real product catalog scraped from naqirgiftbox.com's own public storefront")
    out.append("/// API (191 products, SKUs/names/prices/images all real - see")
    out.append("/// scripts/scraping/ for provenance). Used until Zid Partner API credentials")
    out.append("/// exist. See docs/ARCHITECTURE.md \u00a71.")
    out.append("// GENERATED with scripts/scraping/generate_dart.py - do not hand-edit.")
    out.append("class ProductMockDataSource implements ProductDataSource {")
    out.append("  static final List<ProductDto> _catalog = [")

    for r in catalog:
        sku = r["sku"]
        cat_id, _cat_name = LINE_TO_CATEGORY[r["line"]]
        dl = downloads.get(sku)

        images = []
        if dl and dl.get("ok"):
            images.append(f"{ASSET_DIR}/{dl['file']}")
        elif r["images"]:
            images.append(r["images"][0])
        local_source_url = r["images"][0] if r["images"] else None
        for u in r["images"][1:]:
            if u != local_source_url:
                images.append(u)
        if not images:
            images = [""]

        dt = parse_dt(r.get("created_at")) or datetime.now(timezone.utc)
        created_expr = (
            f"DateTime.utc({dt.year}, {dt.month}, {dt.day}, {dt.hour}, {dt.minute}, {dt.second})"
        )

        desc = r["description"] or r["name"]

        out.append("    ProductDto(")
        out.append(f"      id: {dart_str(r['slug'])},")
        out.append(f"      slug: {dart_str(r['slug'])},")
        out.append(f"      name: {dart_str(r['name'])},")
        out.append(f"      shortDescription: {dart_str(desc)},")
        out.append(f"      description: {dart_str(desc)},")
        out.append("      specifications: const {},")
        images_expr = ", ".join(dart_str(u) for u in images)
        out.append(f"      images: const [{images_expr}],")
        out.append(f"      price: {float(r['price'])},")
        out.append(f"      sku: {dart_str(sku)},")
        out.append(f"      categoryId: {dart_str(cat_id)},")
        out.append(f"      stockQuantity: {int(r['quantity'])},")
        out.append("      rating: 0.0,")
        out.append("      reviewCount: 0,")
        out.append(f"      createdAt: {created_expr},")
        if sku in featured_skus:
            out.append("      isFeatured: true,")
        if sku in new_skus:
            out.append("      isNew: true,")

        if r["variants"]:
            out.append("      variants: const [")
            for v in r["variants"]:
                label = v["label"] or v["sku"] or "Option"
                img_expr = dart_str(v["image"]) if v["image"] else "null"
                out.append("        ProductVariantDto(")
                out.append(f"          id: {dart_str(v['id'])},")
                out.append(f"          label: {dart_str(label)},")
                out.append(f"          imageUrl: {img_expr},")
                out.append("        ),")
            out.append("      ],")

        out.append("    ),")

    out.append("  ];")
    out.append("")
    out.append("  @override")
    out.append("  Future<({List<ProductDto> items, int totalCount})> getProducts(")
    out.append("    ProductQuery query,")
    out.append("  ) async {")
    out.append("    await _simulateLatency();")
    out.append("")
    out.append("    var results = _catalog.where((p) {")
    out.append("      if (query.categoryId != null && p.categoryId != query.categoryId) {")
    out.append("        return false;")
    out.append("      }")
    out.append("      if (query.minPrice != null && p.price < query.minPrice!) return false;")
    out.append("      if (query.maxPrice != null && p.price > query.maxPrice!) return false;")
    out.append("      if (query.discountedOnly && p.compareAtPrice == null) return false;")
    out.append("      if (query.featuredOnly && !p.isFeatured) return false;")
    out.append("      if (query.newOnly && !p.isNew) return false;")
    out.append("      if (query.searchTerm != null && query.searchTerm!.trim().isNotEmpty) {")
    out.append("        final term = query.searchTerm!.toLowerCase();")
    out.append("        if (!p.name.toLowerCase().contains(term) &&")
    out.append("            !p.shortDescription.toLowerCase().contains(term)) {")
    out.append("          return false;")
    out.append("        }")
    out.append("      }")
    out.append("      return true;")
    out.append("    }).toList();")
    out.append("")
    out.append("    results.sort(")
    out.append("      (a, b) => switch (query.sort) {")
    out.append("        ProductSortOption.newest => b.createdAt.compareTo(a.createdAt),")
    out.append("        ProductSortOption.popular => b.reviewCount.compareTo(a.reviewCount),")
    out.append("        ProductSortOption.priceLowToHigh => a.price.compareTo(b.price),")
    out.append("        ProductSortOption.priceHighToLow => b.price.compareTo(a.price),")
    out.append("      },")
    out.append("    );")
    out.append("")
    out.append("    final totalCount = results.length;")
    out.append("    final start = (query.page - 1) * query.pageSize;")
    out.append("    if (start >= results.length) {")
    out.append("      return (items: <ProductDto>[], totalCount: totalCount);")
    out.append("    }")
    out.append("    final end = (start + query.pageSize).clamp(0, results.length);")
    out.append("    return (items: results.sublist(start, end), totalCount: totalCount);")
    out.append("  }")
    out.append("")
    out.append("  @override")
    out.append("  Future<ProductDto> getProduct(String id) async {")
    out.append("    await _simulateLatency();")
    out.append("    return _catalog.firstWhere(")
    out.append("      (p) => p.id == id || p.slug == id,")
    out.append("      orElse: () => throw const NotFoundException('Product not found.'),")
    out.append("    );")
    out.append("  }")
    out.append("")
    out.append("  @override")
    out.append("  Future<List<ProductDto>> getRelatedProducts(")
    out.append("    String productId, {")
    out.append("    int limit = 10,")
    out.append("  }) async {")
    out.append("    await _simulateLatency();")
    out.append("    final product = await getProduct(productId);")
    out.append("    return _catalog")
    out.append("        .where((p) => p.id != product.id && p.categoryId == product.categoryId)")
    out.append("        .take(limit)")
    out.append("        .toList();")
    out.append("  }")
    out.append("")
    out.append("  Future<void> _simulateLatency() =>")
    out.append("      Future<void>.delayed(const Duration(milliseconds: 350));")
    out.append("}")

    with open(
        "lib/features/products/data/datasources/product_mock_data_source.dart", "w", encoding="utf-8"
    ) as f:
        f.write("\n".join(out) + "\n")

    # ============================================================
    # 3. category_mock_data_source.dart
    # ============================================================
    # Pick a representative real product image per line for the category tile.
    rep_image = {}
    for r in catalog:
        line = r["line"]
        if line in rep_image:
            continue
        dl = downloads.get(r["sku"])
        if dl and dl.get("ok"):
            rep_image[line] = f"{ASSET_DIR}/{dl['file']}"

    cat_out = []
    cat_out.append("import 'package:naqirgiftbox/core/error/exceptions.dart';")
    cat_out.append("import 'package:naqirgiftbox/features/categories/data/datasources/category_data_source.dart';")
    cat_out.append("import 'package:naqirgiftbox/features/categories/data/models/category_dto.dart';")
    cat_out.append("")
    cat_out.append("/// Real product-line categories derived from naqirgiftbox.com's actual")
    cat_out.append("/// catalog structure (the storefront itself only publishes one \"Gift box\"")
    cat_out.append("/// category; these three groupings mirror the real product-line naming")
    cat_out.append("/// already present in every SKU/slug: Termeh Box, Termeh Chest, Gift Box).")
    cat_out.append("// GENERATED with scripts/scraping/generate_dart.py - do not hand-edit.")
    cat_out.append("class CategoryMockDataSource implements CategoryDataSource {")
    cat_out.append("  static const _categories = [")
    for line, (cat_id, cat_name) in LINE_TO_CATEGORY.items():
        img = rep_image.get(line, "")
        cat_out.append("    CategoryDto(")
        cat_out.append(f"      id: {dart_str(cat_id)},")
        cat_out.append(f"      name: {dart_str(cat_name)},")
        cat_out.append(f"      slug: {dart_str(cat_id.replace('cat-', ''))},")
        cat_out.append(f"      imageUrl: {dart_str(img)},")
        cat_out.append("    ),")
    cat_out.append("  ];")
    cat_out.append("")
    cat_out.append("  @override")
    cat_out.append("  Future<List<CategoryDto>> getCategories() async {")
    cat_out.append("    await Future<void>.delayed(const Duration(milliseconds: 250));")
    cat_out.append("    return _categories;")
    cat_out.append("  }")
    cat_out.append("")
    cat_out.append("  @override")
    cat_out.append("  Future<CategoryDto> getCategory(String id) async {")
    cat_out.append("    await Future<void>.delayed(const Duration(milliseconds: 200));")
    cat_out.append("    return _categories.firstWhere(")
    cat_out.append("      (c) => c.id == id || c.slug == id,")
    cat_out.append("      orElse: () => throw const NotFoundException('Category not found.'),")
    cat_out.append("    );")
    cat_out.append("  }")
    cat_out.append("}")

    with open(
        "lib/features/categories/data/datasources/category_mock_data_source.dart", "w", encoding="utf-8"
    ) as f:
        f.write("\n".join(cat_out) + "\n")

    print("Generated:")
    print("  lib/features/products/data/datasources/product_image_mapping.dart")
    print("  lib/features/products/data/datasources/product_mock_data_source.dart")
    print("  lib/features/categories/data/datasources/category_mock_data_source.dart")
    print(f"Products: {len(catalog)}  Featured: {len(featured_skus)}  New: {len(new_skus)}")


if __name__ == "__main__":
    main()
