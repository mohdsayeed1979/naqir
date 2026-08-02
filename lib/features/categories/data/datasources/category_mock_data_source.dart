import 'package:naqirgiftbox/core/error/exceptions.dart';
import 'package:naqirgiftbox/features/categories/data/datasources/category_data_source.dart';
import 'package:naqirgiftbox/features/categories/data/models/category_dto.dart';

class CategoryMockDataSource implements CategoryDataSource {
  static const _productImages = 'assets/images/products';

  static const _categories = [
    CategoryDto(
      id: 'cat-gift-boxes',
      name: 'Gift Boxes',
      slug: 'gift-boxes',
      imageUrl: '$_productImages/box_brown.png',
    ),
    CategoryDto(
      id: 'cat-dates-trays',
      name: 'Dates Trays',
      slug: 'dates-trays',
      imageUrl: '$_productImages/box_blush.png',
    ),
    CategoryDto(
      id: 'cat-chocolate',
      name: 'Chocolate Collections',
      slug: 'chocolate-collections',
      imageUrl: '$_productImages/box_gold.png',
    ),
    CategoryDto(
      id: 'cat-oud',
      name: 'Incense & Oud',
      slug: 'incense-oud',
      imageUrl: '$_productImages/box_navy.png',
    ),
    CategoryDto(
      id: 'cat-wedding',
      name: 'Wedding Favors',
      slug: 'wedding-favors',
      imageUrl: '$_productImages/box_blush.png',
    ),
    CategoryDto(
      id: 'cat-corporate',
      name: 'Corporate Gifts',
      slug: 'corporate-gifts',
      imageUrl: '$_productImages/box_navy.png',
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
