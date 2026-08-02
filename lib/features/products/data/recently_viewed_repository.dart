import 'package:hive/hive.dart';

/// Local-only device state, same rationale as [WishlistRepository] — no
/// mock/remote split needed. Stores product id -> viewed-at timestamp so the
/// most-recent view always sorts first.
class RecentlyViewedRepository {
  RecentlyViewedRepository(this._box);

  final Box<String> _box;

  static const _maxEntries = 20;

  /// Most-recently-viewed product ids first.
  List<String> getIds() {
    final entries =
        _box.keys
            .cast<String>()
            .map((id) => MapEntry(id, _box.get(id)!))
            .toList()
          ..sort((a, b) => b.value.compareTo(a.value));
    return entries.map((e) => e.key).toList();
  }

  Future<void> recordView(String productId) async {
    await _box.put(productId, DateTime.now().toIso8601String());
    final ids = getIds();
    if (ids.length > _maxEntries) {
      for (final staleId in ids.skip(_maxEntries)) {
        await _box.delete(staleId);
      }
    }
  }
}
