import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naqirgiftbox/core/storage/hive/hive_boxes.dart';
import 'package:naqirgiftbox/features/orders/data/orders_repository.dart';
import 'package:naqirgiftbox/features/orders/domain/entities/order.dart';

final ordersRepositoryProvider = Provider<OrdersRepository>(
  (ref) => OrdersRepository(HiveBoxes.orders),
);

class OrdersNotifier extends Notifier<List<Order>> {
  late OrdersRepository _repository;

  @override
  List<Order> build() {
    _repository = ref.watch(ordersRepositoryProvider);
    return _repository.getAll();
  }

  Future<void> placeOrder(Order order) async {
    await _repository.save(order);
    state = _repository.getAll();
  }
}

final ordersProvider = NotifierProvider<OrdersNotifier, List<Order>>(
  OrdersNotifier.new,
);

final orderByIdProvider = Provider.family<Order?, String>((ref, id) {
  return ref.watch(ordersProvider).where((o) => o.id == id).firstOrNull;
});

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
