import 'package:naqirgiftbox/features/categories/data/models/category_dto.dart';

abstract class CategoryDataSource {
  Future<List<CategoryDto>> getCategories();

  Future<CategoryDto> getCategory(String id);
}
