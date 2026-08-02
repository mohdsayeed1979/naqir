import 'package:naqirgiftbox/features/products/data/datasources/product_data_source.dart';
import 'package:naqirgiftbox/features/products/data/models/product_dto.dart';
import 'package:naqirgiftbox/core/error/exceptions.dart';
import 'package:naqirgiftbox/features/products/domain/entities/product_query.dart';

/// Realistic in-memory catalog so the app is fully functional before Zid
/// Partner API credentials exist. See docs/ARCHITECTURE.md §1.
class ProductMockDataSource implements ProductDataSource {
  static final DateTime _now = DateTime(2026, 8, 1);

  static const _productImages = 'assets/images/products';

  static final List<ProductDto> _catalog = [
    // Gift Boxes
    ProductDto(
      id: 'p-001',
      slug: 'regal-dates-gift-box-brown',
      name: 'Regal Dates Gift Box — Brown',
      shortDescription: 'Handwoven fabric box with premium Ajwa dates',
      description:
          'A wooden gift box wrapped in woven fabric, filled with hand-selected Ajwa dates. '
          'Finished with a satin ribbon — a refined choice for Eid, weddings, or corporate '
          'gifting.',
      specifications: const {
        'Dimensions': '215 × 215 × 73 mm',
        'Material': 'Wood, woven fabric',
        'Net weight': '600 g',
        'Shelf life': '6 months',
      },
      images: const ['$_productImages/box_brown.png'],
      price: 75,
      sku: 'NGB-BOX-T01-BRN',
      categoryId: 'cat-gift-boxes',
      stockQuantity: 88,
      rating: 4.8,
      reviewCount: 34,
      createdAt: _now.subtract(const Duration(days: 4)),
      isFeatured: true,
      variants: const [
        ProductVariantDto(
          id: 'v-001-brn',
          label: 'Brown',
          imageUrl: '$_productImages/box_brown.png',
        ),
        ProductVariantDto(
          id: 'v-001-gld',
          label: 'Gold',
          imageUrl: '$_productImages/box_gold.png',
        ),
        ProductVariantDto(
          id: 'v-001-grn',
          label: 'Green',
          imageUrl: '$_productImages/box_green.png',
        ),
      ],
    ),
    ProductDto(
      id: 'p-002',
      slug: 'royal-ribbon-gift-box-gold',
      name: 'Royal Ribbon Gift Box — Gold',
      shortDescription: 'Statement gold box for premium occasions',
      description:
          'Our most luxurious box: a deep-gold woven finish with a structured lid and dual '
          'ribbon detailing, filled with an assortment of stuffed dates.',
      specifications: const {
        'Dimensions': '240 × 240 × 85 mm',
        'Material': 'Wood, woven fabric',
        'Net weight': '750 g',
        'Shelf life': '6 months',
      },
      images: const ['$_productImages/box_gold.png'],
      price: 125,
      compareAtPrice: 150,
      sku: 'NGB-BOX-T02-GLD',
      categoryId: 'cat-gift-boxes',
      stockQuantity: 42,
      rating: 4.9,
      reviewCount: 58,
      createdAt: _now.subtract(const Duration(days: 2)),
      isFeatured: true,
      isNew: true,
    ),
    ProductDto(
      id: 'p-003',
      slug: 'classic-gift-box-red',
      name: 'Classic Gift Box — Red',
      shortDescription: 'A timeless red gift box, perfectly sized',
      description:
          'The everyday-luxury choice — a compact woven box in deep red, filled with a curated '
          'dates selection. Ships flat-packed with assembly-free presentation.',
      specifications: const {
        'Dimensions': '200 × 200 × 70 mm',
        'Material': 'Wood, woven fabric',
        'Net weight': '450 g',
        'Shelf life': '6 months',
      },
      images: const ['$_productImages/box_red.png'],
      price: 70,
      sku: 'NGB-BOX-T11-RED',
      categoryId: 'cat-gift-boxes',
      stockQuantity: 120,
      rating: 4.6,
      reviewCount: 21,
      createdAt: _now.subtract(const Duration(days: 20)),
    ),
    ProductDto(
      id: 'p-004',
      slug: 'twin-tier-gift-box-navy',
      name: 'Twin Tier Gift Box — Navy',
      shortDescription: 'Two-tier box with dates and chocolate dates',
      description:
          'A generous two-compartment box pairing classic Ajwa dates with chocolate-dipped '
          'dates, wrapped in a deep navy fabric finish.',
      specifications: const {
        'Dimensions': '260 × 260 × 90 mm',
        'Material': 'Wood, woven fabric',
        'Net weight': '900 g',
        'Shelf life': '4 months',
      },
      images: const ['$_productImages/box_navy.png'],
      price: 145,
      sku: 'NGB-BOX-K07-NVY',
      categoryId: 'cat-gift-boxes',
      stockQuantity: 30,
      rating: 4.7,
      reviewCount: 15,
      createdAt: _now.subtract(const Duration(days: 55)),
    ),

    // Dates Trays
    ProductDto(
      id: 'p-005',
      slug: 'ajwa-dates-tray-blush',
      name: 'Ajwa Dates Tray — Blush',
      shortDescription: 'Open tray of premium Madinah Ajwa dates',
      description:
          'A generously filled open tray of Grade-A Ajwa dates from Madinah, finished with a '
          'blush organza wrap — ideal for Majlis serving.',
      specifications: const {
        'Dimensions': '300 × 200 × 50 mm',
        'Material': 'Rattan, organza wrap',
        'Net weight': '500 g',
        'Shelf life': '8 months',
      },
      images: const ['$_productImages/box_blush.png'],
      price: 95,
      sku: 'NGB-TRY-A01-BLS',
      categoryId: 'cat-dates-trays',
      stockQuantity: 64,
      rating: 4.8,
      reviewCount: 40,
      createdAt: _now.subtract(const Duration(days: 8)),
      isFeatured: true,
    ),
    ProductDto(
      id: 'p-006',
      slug: 'sukkari-dates-tray-green',
      name: 'Sukkari Dates Tray — Green',
      shortDescription: 'Soft caramel-toned Sukkari dates',
      description:
          'Sukkari dates known for their soft, caramel-like sweetness, arranged in a hand-woven '
          'tray with a forest-green ribbon trim.',
      specifications: const {
        'Dimensions': '300 × 200 × 50 mm',
        'Material': 'Rattan, satin ribbon',
        'Net weight': '500 g',
        'Shelf life': '8 months',
      },
      images: const ['$_productImages/box_green.png'],
      price: 90,
      sku: 'NGB-TRY-A02-GRN',
      categoryId: 'cat-dates-trays',
      stockQuantity: 51,
      rating: 4.7,
      reviewCount: 19,
      createdAt: _now.subtract(const Duration(days: 30)),
    ),
    ProductDto(
      id: 'p-007',
      slug: 'mixed-dates-tray-blue',
      name: 'Mixed Dates Tray — Blue',
      shortDescription: 'Three varieties of dates in one tray',
      description:
          'A curated mix of Ajwa, Sukkari, and Khudri dates arranged by color, finished with a '
          'deep-blue wrap for a striking table presentation.',
      specifications: const {
        'Dimensions': '320 × 220 × 55 mm',
        'Material': 'Rattan, satin ribbon',
        'Net weight': '600 g',
        'Shelf life': '8 months',
      },
      images: const ['$_productImages/box_blue.png'],
      price: 110,
      compareAtPrice: 130,
      sku: 'NGB-TRY-A03-BLU',
      categoryId: 'cat-dates-trays',
      stockQuantity: 38,
      rating: 4.9,
      reviewCount: 27,
      createdAt: _now.subtract(const Duration(days: 12)),
      isNew: true,
    ),

    // Chocolate Collections
    ProductDto(
      id: 'p-008',
      slug: 'chocolate-dates-collection-brown',
      name: 'Chocolate Dates Collection',
      shortDescription: 'Dates dipped in Belgian dark chocolate',
      description:
          'Premium dates hand-dipped in Belgian dark chocolate and topped with pistachio, '
          'almond, or sesame — presented in a compartmentalized gift box.',
      specifications: const {
        'Dimensions': '220 × 220 × 60 mm',
        'Material': 'Rigid card, acetate window',
        'Net weight': '400 g',
        'Shelf life': '2 months (cool storage)',
      },
      images: const ['$_productImages/box_brown.png'],
      price: 85,
      sku: 'NGB-CHC-B01-BRN',
      categoryId: 'cat-chocolate',
      stockQuantity: 70,
      rating: 4.8,
      reviewCount: 46,
      createdAt: _now.subtract(const Duration(days: 6)),
      isFeatured: true,
    ),
    ProductDto(
      id: 'p-009',
      slug: 'truffle-date-box-gold',
      name: 'Truffle Date Box — Gold',
      shortDescription: 'Date truffles rolled in cocoa and gold dust',
      description:
          'Bite-sized date truffles blended with nuts and rolled in cocoa powder, finished with '
          'an edible gold dust dusting — a showstopper for any occasion.',
      specifications: const {
        'Dimensions': '180 × 180 × 50 mm',
        'Material': 'Rigid card',
        'Net weight': '300 g',
        'Shelf life': '2 months (cool storage)',
      },
      images: const ['$_productImages/box_gold.png'],
      price: 99,
      sku: 'NGB-CHC-B02-GLD',
      categoryId: 'cat-chocolate',
      stockQuantity: 25,
      rating: 4.9,
      reviewCount: 12,
      createdAt: _now.subtract(const Duration(days: 3)),
      isNew: true,
    ),

    // Incense & Oud
    ProductDto(
      id: 'p-010',
      slug: 'oud-gift-set-navy',
      name: 'Oud & Bakhoor Gift Set',
      shortDescription: 'Cambodian oud chips with a mini burner',
      description:
          'A refined oud gifting set pairing Cambodian oud chips with bakhoor and a compact '
          'ceramic burner — packaged in our signature woven box.',
      specifications: const {
        'Dimensions': '220 × 160 × 90 mm',
        'Material': 'Wood, ceramic burner',
        'Net weight': '350 g',
        'Shelf life': '24 months',
      },
      images: const ['$_productImages/box_navy.png'],
      price: 180,
      sku: 'NGB-OUD-C01-NVY',
      categoryId: 'cat-oud',
      stockQuantity: 18,
      rating: 4.7,
      reviewCount: 9,
      createdAt: _now.subtract(const Duration(days: 65)),
    ),
    ProductDto(
      id: 'p-011',
      slug: 'majlis-incense-tray-red',
      name: 'Majlis Incense Tray',
      shortDescription: 'Assorted bakhoor for daily use',
      description:
          'An assortment of our finest bakhoor blends, arranged in a compact travel-friendly '
          'tray — perfect for gifting or personal use.',
      specifications: const {
        'Dimensions': '200 × 150 × 40 mm',
        'Material': 'Rattan',
        'Net weight': '250 g',
        'Shelf life': '24 months',
      },
      images: const ['$_productImages/box_red.png'],
      price: 65,
      sku: 'NGB-OUD-C02-RED',
      categoryId: 'cat-oud',
      stockQuantity: 55,
      rating: 4.5,
      reviewCount: 17,
      createdAt: _now.subtract(const Duration(days: 40)),
    ),

    // Wedding Favors
    ProductDto(
      id: 'p-012',
      slug: 'wedding-favor-set-blush',
      name: 'Wedding Favor Set (x10)',
      shortDescription: 'Ten individually wrapped mini favors',
      description:
          'Ten individually wrapped mini gift boxes, each with two premium dates — a graceful '
          'favor for wedding and engagement guests, sold in sets of ten.',
      specifications: const {
        'Dimensions': '70 × 70 × 40 mm (each)',
        'Material': 'Wood, satin ribbon',
        'Net weight': '50 g (each)',
        'Shelf life': '6 months',
      },
      images: const ['$_productImages/box_blush.png'],
      price: 220,
      sku: 'NGB-WED-F01-BLS',
      categoryId: 'cat-wedding',
      stockQuantity: 20,
      rating: 4.9,
      reviewCount: 31,
      createdAt: _now.subtract(const Duration(days: 15)),
      isFeatured: true,
    ),
    ProductDto(
      id: 'p-013',
      slug: 'engagement-tray-gold',
      name: 'Engagement Tray — Gold',
      shortDescription: 'Large centerpiece tray for engagements',
      description:
          'A statement centerpiece tray finished in gold, filled with an assortment of premium '
          'dates and dragées — designed to anchor the sweets table.',
      specifications: const {
        'Dimensions': '400 × 300 × 70 mm',
        'Material': 'Wood, acrylic accents',
        'Net weight': '1.2 kg',
        'Shelf life': '6 months',
      },
      images: const ['$_productImages/box_gold.png'],
      price: 270,
      sku: 'NGB-WED-F02-GLD',
      categoryId: 'cat-wedding',
      stockQuantity: 8,
      rating: 5.0,
      reviewCount: 6,
      createdAt: _now.subtract(const Duration(days: 70)),
    ),

    // Corporate Gifts
    ProductDto(
      id: 'p-014',
      slug: 'corporate-gift-set-brown',
      name: 'Corporate Gift Set',
      shortDescription: 'Bulk-friendly branded gifting box',
      description:
          'A refined, understated box designed for corporate gifting at scale — available with '
          'custom branding on request. Filled with an assortment of dates and nuts.',
      specifications: const {
        'Dimensions': '230 × 230 × 75 mm',
        'Material': 'Wood, woven fabric',
        'Net weight': '650 g',
        'Shelf life': '6 months',
      },
      images: const ['$_productImages/box_brown.png'],
      price: 115,
      sku: 'NGB-COR-G01-BRN',
      categoryId: 'cat-corporate',
      stockQuantity: 200,
      rating: 4.6,
      reviewCount: 22,
      createdAt: _now.subtract(const Duration(days: 90)),
    ),
    ProductDto(
      id: 'p-015',
      slug: 'executive-gift-box-navy',
      name: 'Executive Gift Box — Navy',
      shortDescription: 'A refined choice for executive gifting',
      description:
          'Our most understated box, finished in navy with minimal branding — built for '
          'executive gifting occasions where subtlety matters.',
      specifications: const {
        'Dimensions': '240 × 240 × 80 mm',
        'Material': 'Wood, woven fabric',
        'Net weight': '700 g',
        'Shelf life': '6 months',
      },
      images: const ['$_productImages/box_navy.png'],
      price: 135,
      compareAtPrice: 160,
      sku: 'NGB-COR-G02-NVY',
      categoryId: 'cat-corporate',
      stockQuantity: 45,
      rating: 4.8,
      reviewCount: 14,
      createdAt: _now.subtract(const Duration(days: 5)),
      isNew: true,
    ),
  ];

  @override
  Future<({List<ProductDto> items, int totalCount})> getProducts(
    ProductQuery query,
  ) async {
    await _simulateLatency();

    var results = _catalog.where((p) {
      if (query.categoryId != null && p.categoryId != query.categoryId) {
        return false;
      }
      if (query.minPrice != null && p.price < query.minPrice!) return false;
      if (query.maxPrice != null && p.price > query.maxPrice!) return false;
      if (query.discountedOnly && p.compareAtPrice == null) return false;
      if (query.featuredOnly && !p.isFeatured) return false;
      if (query.newOnly && !p.isNew) return false;
      if (query.searchTerm != null && query.searchTerm!.trim().isNotEmpty) {
        final term = query.searchTerm!.toLowerCase();
        if (!p.name.toLowerCase().contains(term) &&
            !p.shortDescription.toLowerCase().contains(term)) {
          return false;
        }
      }
      return true;
    }).toList();

    results.sort(
      (a, b) => switch (query.sort) {
        ProductSortOption.newest => b.createdAt.compareTo(a.createdAt),
        ProductSortOption.popular => b.reviewCount.compareTo(a.reviewCount),
        ProductSortOption.priceLowToHigh => a.price.compareTo(b.price),
        ProductSortOption.priceHighToLow => b.price.compareTo(a.price),
      },
    );

    final totalCount = results.length;
    final start = (query.page - 1) * query.pageSize;
    if (start >= results.length) {
      return (items: <ProductDto>[], totalCount: totalCount);
    }
    final end = (start + query.pageSize).clamp(0, results.length);
    return (items: results.sublist(start, end), totalCount: totalCount);
  }

  @override
  Future<ProductDto> getProduct(String id) async {
    await _simulateLatency();
    return _catalog.firstWhere(
      (p) => p.id == id || p.slug == id,
      orElse: () => throw const NotFoundException('Product not found.'),
    );
  }

  @override
  Future<List<ProductDto>> getRelatedProducts(
    String productId, {
    int limit = 10,
  }) async {
    await _simulateLatency();
    final product = await getProduct(productId);
    return _catalog
        .where((p) => p.id != product.id && p.categoryId == product.categoryId)
        .take(limit)
        .toList();
  }

  Future<void> _simulateLatency() =>
      Future<void>.delayed(const Duration(milliseconds: 350));
}
