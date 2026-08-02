import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:naqirgiftbox/features/products/domain/entities/product.dart';

part 'paginated_products.freezed.dart';

@freezed
abstract class PaginatedProducts with _$PaginatedProducts {
  const factory PaginatedProducts({
    required List<Product> items,
    required int totalCount,
    required int page,
    required bool hasMore,
  }) = _PaginatedProducts;

  const PaginatedProducts._();

  static const empty = PaginatedProducts(
    items: [],
    totalCount: 0,
    page: 1,
    hasMore: false,
  );
}
