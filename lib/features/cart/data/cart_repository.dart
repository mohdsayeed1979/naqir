import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:naqirgiftbox/features/cart/domain/entities/cart.dart';

/// Cart is local-only device state — see the note on [Cart] for why there's
/// no mock/remote data-source split here the way Product/Category have one.
class CartRepository {
  CartRepository(this._box);

  final Box<String> _box;

  static const _cartKey = 'cart_data';

  Cart getCart() {
    final raw = _box.get(_cartKey);
    if (raw == null) return const Cart();
    try {
      return Cart.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const Cart();
    }
  }

  Future<void> saveCart(Cart cart) =>
      _box.put(_cartKey, jsonEncode(cart.toJson()));

  /// Mock coupon rules, standing in for a real coupon-validation endpoint —
  /// call sites (`CartNotifier.applyCoupon`) don't change when one exists.
  ({bool isValid, double discount, String? errorMessage}) validateCoupon(
    String code,
    double subtotal,
  ) {
    switch (code.trim().toUpperCase()) {
      case 'WELCOME10':
        return (isValid: true, discount: subtotal * 0.10, errorMessage: null);
      case 'SAVE20':
        return (isValid: true, discount: 20.0, errorMessage: null);
      default:
        return (
          isValid: false,
          discount: 0.0,
          errorMessage: 'Invalid or expired coupon code.',
        );
    }
  }
}
