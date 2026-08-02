import 'package:naqirgiftbox/core/constants/api_endpoints.dart';
import 'package:naqirgiftbox/core/network/api_client.dart';
import 'package:naqirgiftbox/features/products/data/datasources/product_data_source.dart';
import 'package:naqirgiftbox/features/products/data/models/product_dto.dart';
import 'package:naqirgiftbox/features/products/domain/entities/product_query.dart';

/// Ready for the Zid Partner API (or any other backend) — point
/// `AppConfig.apiBaseUrl` at it and flip `AppConfig.useMockData` off; no
/// other code changes. See docs/ARCHITECTURE.md §1.
class ProductRemoteDataSource implements ProductDataSource {
  ProductRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<({List<ProductDto> items, int totalCount})> getProducts(
    ProductQuery query,
  ) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.products,
      queryParameters: {
        if (query.categoryId != null) 'category_id': query.categoryId,
        if (query.searchTerm != null) 'q': query.searchTerm,
        if (query.minPrice != null) 'min_price': query.minPrice,
        if (query.maxPrice != null) 'max_price': query.maxPrice,
        if (query.discountedOnly) 'discounted_only': true,
        if (query.featuredOnly) 'featured_only': true,
        if (query.newOnly) 'new_only': true,
        'sort': query.sort.name,
        'page': query.page,
        'page_size': query.pageSize,
      },
    );
    final data = response.data!;
    final items = (data['items'] as List<dynamic>)
        .map((json) => ProductDto.fromJson(json as Map<String, dynamic>))
        .toList();
    return (
      items: items,
      totalCount: data['total_count'] as int? ?? items.length,
    );
  }

  @override
  Future<ProductDto> getProduct(String id) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.product(id),
    );
    return ProductDto.fromJson(response.data!);
  }

  @override
  Future<List<ProductDto>> getRelatedProducts(
    String productId, {
    int limit = 10,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.relatedProducts(productId),
      queryParameters: {'limit': limit},
    );
    final items = response.data!['items'] as List<dynamic>;
    return items
        .map((json) => ProductDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
