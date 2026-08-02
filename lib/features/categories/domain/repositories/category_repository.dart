import 'package:naqirgiftbox/core/error/result.dart';
import 'package:naqirgiftbox/features/categories/domain/entities/category.dart';

abstract class CategoryRepository {
  Future<Result<List<Category>>> getCategories();

  Future<Result<Category>> getCategory(String id);
}
