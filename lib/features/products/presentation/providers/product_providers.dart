import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naqirgiftbox/core/di/injector.dart';
import 'package:naqirgiftbox/features/products/domain/entities/product.dart';
import 'package:naqirgiftbox/features/products/domain/repositories/product_repository.dart';

final productRepositoryProvider = Provider<ProductRepository>(
  (ref) => getIt<ProductRepository>(),
);

final productDetailProvider = FutureProvider.family<Product, String>((
  ref,
  id,
) async {
  final repository = ref.watch(productRepositoryProvider);
  final result = await repository.getProduct(id);
  return result.when(
    success: (data) => data,
    failure: (failure) => throw failure,
  );
});

final relatedProductsProvider = FutureProvider.family<List<Product>, String>((
  ref,
  productId,
) async {
  final repository = ref.watch(productRepositoryProvider);
  final result = await repository.getRelatedProducts(productId);
  return result.when(
    success: (data) => data,
    failure: (failure) => throw failure,
  );
});
