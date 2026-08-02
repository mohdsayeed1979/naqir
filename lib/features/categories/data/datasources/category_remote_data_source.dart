import 'package:naqirgiftbox/core/constants/api_endpoints.dart';
import 'package:naqirgiftbox/core/network/api_client.dart';
import 'package:naqirgiftbox/features/categories/data/datasources/category_data_source.dart';
import 'package:naqirgiftbox/features/categories/data/models/category_dto.dart';

class CategoryRemoteDataSource implements CategoryDataSource {
  CategoryRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<CategoryDto>> getCategories() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.categories,
    );
    final items = response.data!['items'] as List<dynamic>;
    return items
        .map((json) => CategoryDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<CategoryDto> getCategory(String id) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.category(id),
    );
    return CategoryDto.fromJson(response.data!);
  }
}
