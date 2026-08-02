import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naqirgiftbox/core/storage/hive/hive_boxes.dart';
import 'package:naqirgiftbox/features/products/data/recently_viewed_repository.dart';
import 'package:naqirgiftbox/features/products/domain/entities/product.dart';
import 'package:naqirgiftbox/features/products/presentation/providers/product_providers.dart';

final recentlyViewedRepositoryProvider = Provider<RecentlyViewedRepository>(
  (ref) => RecentlyViewedRepository(HiveBoxes.recentlyViewed),
);

class RecentlyViewedNotifier extends Notifier<List<String>> {
  late RecentlyViewedRepository _repository;

  @override
  List<String> build() {
    _repository = ref.watch(recentlyViewedRepositoryProvider);
    return _repository.getIds();
  }

  Future<void> recordView(String productId) async {
    await _repository.recordView(productId);
    state = _repository.getIds();
  }
}

final recentlyViewedProvider =
    NotifierProvider<RecentlyViewedNotifier, List<String>>(
      RecentlyViewedNotifier.new,
    );

/// Resolves ids to [Product]s, excluding [excludingProductId] (the product
/// currently on screen, so it doesn't show up in its own rail).
final recentlyViewedProductsProvider =
    FutureProvider.family<List<Product>, String?>((
      ref,
      excludingProductId,
    ) async {
      final ids = ref
          .watch(recentlyViewedProvider)
          .where((id) => id != excludingProductId)
          .take(10);
      final repository = ref.watch(productRepositoryProvider);

      final products = <Product>[];
      for (final id in ids) {
        final result = await repository.getProduct(id);
        result.when(success: products.add, failure: (_) {});
      }
      return products;
    });
