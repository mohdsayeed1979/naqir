import 'package:naqirgiftbox/core/error/result.dart';
import 'package:naqirgiftbox/features/products/domain/entities/paginated_products.dart';
import 'package:naqirgiftbox/features/products/domain/entities/product.dart';
import 'package:naqirgiftbox/features/products/domain/entities/product_query.dart';

abstract class ProductRepository {
  Future<Result<PaginatedProducts>> getProducts(ProductQuery query);

  Future<Result<Product>> getProduct(String id);

  Future<Result<List<Product>>> getRelatedProducts(
    String productId, {
    int limit = 10,
  });
}
