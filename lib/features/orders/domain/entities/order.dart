import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:naqirgiftbox/features/checkout/domain/entities/address.dart';

part 'order.freezed.dart';
part 'order.g.dart';

enum OrderStatus { placed, confirmed, shipped, delivered, cancelled }

@freezed
abstract class OrderItem with _$OrderItem {
  const factory OrderItem({
    required String productId,
    required String productName,
    required String productImage,
    required double unitPrice,
    required int quantity,
    String? variantLabel,
  }) = _OrderItem;

  const OrderItem._();

  factory OrderItem.fromJson(Map<String, dynamic> json) =>
      _$OrderItemFromJson(json);

  double get lineTotal => unitPrice * quantity;
}

/// Orders are created locally at checkout and persisted as JSON — there is
/// no orders endpoint yet (see docs/ARCHITECTURE.md §1), so every order stays
/// at [OrderStatus.placed]. The tracking UI is fully built and reflects
/// whatever status is stored; it just has nothing driving it forward yet.
@freezed
abstract class Order with _$Order {
  const factory Order({
    required String id,
    required List<OrderItem> items,
    required double subtotal,
    required double discount,
    required double shippingFee,
    required double total,
    required Address shippingAddress,
    required String shippingMethodLabel,
    required OrderStatus status,
    required DateTime placedAt,
  }) = _Order;

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
}
