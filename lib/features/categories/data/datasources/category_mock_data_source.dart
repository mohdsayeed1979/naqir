import 'package:naqirgiftbox/core/error/exceptions.dart';
import 'package:naqirgiftbox/features/categories/data/datasources/category_data_source.dart';
import 'package:naqirgiftbox/features/categories/data/models/category_dto.dart';

/// Real product-line categories derived from naqirgiftbox.com's actual
/// catalog structure (the storefront itself only publishes one "Gift box"
/// category; these three groupings mirror the real product-line naming
/// already present in every SKU/slug: Termeh Box, Termeh Chest, Gift Box).
// GENERATED with scripts/scraping/generate_dart.py - do not hand-edit.
class CategoryMockDataSource implements CategoryDataSource {
  static const _categories = [
    CategoryDto(
      id: 'cat-termeh-box',
      name: 'Termeh Box',
      slug: 'termeh-box',
      imageUrl: 'assets/images/products/DRT-TERMEH-BOX-T01-RED.jpg',
    ),
    CategoryDto(
      id: 'cat-termeh-chest',
      name: 'Termeh Chest',
      slug: 'termeh-chest',
      imageUrl: 'assets/images/products/DRT-TERMEH-CHEST-K02-RED.jpg',
    ),
    CategoryDto(
      id: 'cat-gift-box',
      name: 'Gift Box',
      slug: 'gift-box',
      imageUrl: 'assets/images/products/JOZA-L245TB.jpg',
    ),
  ];

  @override
  Future<List<CategoryDto>> getCategories() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return _categories;
  }

  @override
  Future<CategoryDto> getCategory(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _categories.firstWhere(
      (c) => c.id == id || c.slug == id,
      orElse: () => throw const NotFoundException('Category not found.'),
    );
  }
}
