import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:naqirgiftbox/features/orders/domain/entities/order.dart';

class OrdersRepository {
  OrdersRepository(this._box);

  final Box<String> _box;

  /// Most recent first.
  List<Order> getAll() {
    final orders = _box.values
        .map((raw) {
          try {
            return Order.fromJson(jsonDecode(raw) as Map<String, dynamic>);
          } catch (_) {
            return null;
          }
        })
        .whereType<Order>()
        .toList();
    orders.sort((a, b) => b.placedAt.compareTo(a.placedAt));
    return orders;
  }

  Order? getById(String id) => getAll().where((o) => o.id == id).firstOrNull;

  Future<void> save(Order order) =>
      _box.put(order.id, jsonEncode(order.toJson()));
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
