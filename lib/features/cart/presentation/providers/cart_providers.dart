import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naqirgiftbox/core/storage/hive/hive_boxes.dart';
import 'package:naqirgiftbox/features/cart/data/cart_repository.dart';
import 'package:naqirgiftbox/features/cart/domain/entities/cart.dart';
import 'package:naqirgiftbox/features/products/domain/entities/product.dart';

final cartRepositoryProvider = Provider<CartRepository>(
  (ref) => CartRepository(HiveBoxes.cart),
);

class CartNotifier extends Notifier<Cart> {
  late CartRepository _repository;

  @override
  Cart build() {
    _repository = ref.watch(cartRepositoryProvider);
    return _repository.getCart();
  }

  Future<void> addItem({
    required Product product,
    int quantity = 1,
    ProductVariant? variant,
  }) async {
    final lineId = variant != null ? '${product.id}_${variant.id}' : product.id;
    final existingIndex = state.items.indexWhere((item) => item.id == lineId);

    final List<CartItem> updatedItems;
    if (existingIndex >= 0) {
      updatedItems = [...state.items];
      final existing = updatedItems[existingIndex];
      updatedItems[existingIndex] = existing.copyWith(
        quantity: existing.quantity + quantity,
      );
    } else {
      updatedItems = [
        ...state.items,
        CartItem(
          id: lineId,
          productId: product.id,
          productName: product.name,
          productImage: variant?.imageUrl ?? product.primaryImage,
          unitPrice: variant?.priceOverride ?? product.price,
          quantity: quantity,
          variantId: variant?.id,
          variantLabel: variant?.label,
        ),
      ];
    }
    await _persist(state.copyWith(items: updatedItems));
  }

  Future<void> updateQuantity(String lineItemId, int quantity) async {
    if (quantity <= 0) {
      await removeItem(lineItemId);
      return;
    }
    final updatedItems = state.items
        .map(
          (item) =>
              item.id == lineItemId ? item.copyWith(quantity: quantity) : item,
        )
        .toList();
    await _persist(state.copyWith(items: updatedItems));
  }

  Future<void> removeItem(String lineItemId) async {
    final updatedItems = state.items
        .where((item) => item.id != lineItemId)
        .toList();
    await _persist(state.copyWith(items: updatedItems));
  }

  Future<void> clear() => _persist(const Cart());

  Future<({bool success, String? errorMessage})> applyCoupon(
    String code,
  ) async {
    final result = _repository.validateCoupon(code, state.subtotal);
    if (!result.isValid) {
      return (success: false, errorMessage: result.errorMessage);
    }
    await _persist(
      state.copyWith(
        couponCode: code.trim().toUpperCase(),
        couponDiscount: result.discount,
      ),
    );
    return (success: true, errorMessage: null);
  }

  Future<void> removeCoupon() =>
      _persist(state.copyWith(couponCode: null, couponDiscount: 0));

  Future<void> _persist(Cart cart) async {
    state = cart;
    await _repository.saveCart(cart);
  }
}

final cartProvider = NotifierProvider<CartNotifier, Cart>(CartNotifier.new);
