import 'package:naqirgiftbox/features/products/data/models/product_dto.dart';
import 'package:naqirgiftbox/features/products/domain/entities/product_query.dart';

/// Implemented by both [ProductMockDataSource] and [ProductRemoteDataSource]
/// — [ProductRepositoryImpl] depends only on this interface, so switching
/// `AppConfig.useMockData` is the only thing that changes which one runs.
abstract class ProductDataSource {
  Future<({List<ProductDto> items, int totalCount})> getProducts(
    ProductQuery query,
  );

  Future<ProductDto> getProduct(String id);

  Future<List<ProductDto>> getRelatedProducts(
    String productId, {
    int limit = 10,
  });
}
