import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naqirgiftbox/core/storage/hive/hive_boxes.dart';
import 'package:naqirgiftbox/features/products/domain/entities/product.dart';
import 'package:naqirgiftbox/features/products/presentation/providers/product_providers.dart';
import 'package:naqirgiftbox/features/wishlist/data/wishlist_repository.dart';

final wishlistRepositoryProvider = Provider<WishlistRepository>(
  (ref) => WishlistRepository(HiveBoxes.wishlist),
);

class WishlistNotifier extends Notifier<Set<String>> {
  late WishlistRepository _repository;

  @override
  Set<String> build() {
    _repository = ref.watch(wishlistRepositoryProvider);
    return _repository.getIds();
  }

  bool isWishlisted(String productId) => state.contains(productId);

  Future<void> toggle(String productId) async {
    if (state.contains(productId)) {
      await _repository.remove(productId);
      state = {...state}..remove(productId);
    } else {
      await _repository.add(productId);
      state = {...state, productId};
    }
  }
}

final wishlistProvider = NotifierProvider<WishlistNotifier, Set<String>>(
  WishlistNotifier.new,
);

/// Resolves the current wishlist ids into full [Product]s for the wishlist
/// screen. Mock/local lookups are effectively free, so a fan-out of
/// individual `getProduct` calls is simpler than adding a batch endpoint
/// this early — revisit if/when a real backend makes that latency matter.
final wishlistProductsProvider = FutureProvider<List<Product>>((ref) async {
  final ids = ref.watch(wishlistProvider);
  final repository = ref.watch(productRepositoryProvider);

  final products = <Product>[];
  for (final id in ids) {
    final result = await repository.getProduct(id);
    result.when(success: products.add, failure: (_) {});
  }
  return products;
});
