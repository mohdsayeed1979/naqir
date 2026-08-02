import 'package:freezed_annotation/freezed_annotation.dart';

part 'cart.freezed.dart';
part 'cart.g.dart';

/// Cart is local-only device state persisted straight to Hive as JSON (see
/// docs/ARCHITECTURE.md's dependency-version note) — unlike Product/Category
/// there's no separate wire DTO because there's no remote counterpart yet,
/// so `fromJson`/`toJson` live directly on the domain entity.
@freezed
abstract class CartItem with _$CartItem {
  const factory CartItem({
    required String id,
    required String productId,
    required String productName,
    required String productImage,
    required double unitPrice,
    required int quantity,
    String? variantId,
    String? variantLabel,
  }) = _CartItem;

  const CartItem._();

  factory CartItem.fromJson(Map<String, dynamic> json) =>
      _$CartItemFromJson(json);

  double get lineTotal => unitPrice * quantity;
}

@freezed
abstract class Cart with _$Cart {
  const factory Cart({
    @Default([]) List<CartItem> items,
    String? couponCode,
    @Default(0) double couponDiscount,
  }) = _Cart;

  const Cart._();

  factory Cart.fromJson(Map<String, dynamic> json) => _$CartFromJson(json);

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.lineTotal);

  double get total => (subtotal - couponDiscount).clamp(0, double.infinity);

  bool get isEmpty => items.isEmpty;
}
