import 'package:hive/hive.dart';

/// Wishlist is local-only device state (see docs/ARCHITECTURE.md — offline
/// support covers wishlist explicitly), so unlike Product/Category there is
/// no mock/remote split to abstract behind an interface: one Hive-backed
/// implementation is the whole story.
class WishlistRepository {
  WishlistRepository(this._box);

  final Box<String> _box;

  Set<String> getIds() => _box.keys.cast<String>().toSet();

  bool contains(String productId) => _box.containsKey(productId);

  Future<void> add(String productId) =>
      _box.put(productId, DateTime.now().toIso8601String());

  Future<void> remove(String productId) => _box.delete(productId);
}
