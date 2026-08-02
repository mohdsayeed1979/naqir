import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:naqirgiftbox/features/products/domain/entities/product.dart';
import 'package:naqirgiftbox/features/products/domain/entities/product_query.dart';
import 'package:naqirgiftbox/features/products/presentation/providers/product_providers.dart';

part 'home_providers.freezed.dart';

@freezed
abstract class HomeSections with _$HomeSections {
  const factory HomeSections({
    @Default([]) List<Product> featured,
    @Default([]) List<Product> newArrivals,
    @Default([]) List<Product> bestSellers,
  }) = _HomeSections;
}

final homeSectionsProvider = FutureProvider<HomeSections>((ref) async {
  final repository = ref.watch(productRepositoryProvider);

  final results = await Future.wait([
    repository.getProducts(
      const ProductQuery(featuredOnly: true, pageSize: 10),
    ),
    repository.getProducts(const ProductQuery(newOnly: true, pageSize: 10)),
    repository.getProducts(
      const ProductQuery(sort: ProductSortOption.popular, pageSize: 10),
    ),
  ]);

  List<Product> unwrap(int index) => results[index].when(
    success: (data) => data.items,
    failure: (failure) => throw failure,
  );

  return HomeSections(
    featured: unwrap(0),
    newArrivals: unwrap(1),
    bestSellers: unwrap(2),
  );
});
