import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:naqirgiftbox/core/error/failures.dart';
import 'package:naqirgiftbox/features/products/domain/entities/product.dart';
import 'package:naqirgiftbox/features/products/domain/entities/product_query.dart';

part 'product_list_state.freezed.dart';

@freezed
abstract class ProductListState with _$ProductListState {
  const factory ProductListState({
    required ProductQuery query,
    @Default([]) List<Product> items,
    @Default(0) int totalCount,
    @Default(false) bool hasMore,
    @Default(true) bool isLoading,
    @Default(false) bool isLoadingMore,
    Failure? failure,
  }) = _ProductListState;
}
