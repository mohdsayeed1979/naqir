import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_query.freezed.dart';

enum ProductSortOption { newest, popular, priceLowToHigh, priceHighToLow }

@freezed
abstract class ProductQuery with _$ProductQuery {
  const factory ProductQuery({
    String? categoryId,
    String? searchTerm,
    double? minPrice,
    double? maxPrice,
    @Default(false) bool discountedOnly,
    @Default(false) bool featuredOnly,
    @Default(false) bool newOnly,
    @Default(ProductSortOption.newest) ProductSortOption sort,
    @Default(1) int page,
    @Default(20) int pageSize,
  }) = _ProductQuery;
}
