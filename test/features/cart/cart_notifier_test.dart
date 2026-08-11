import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:naqirgiftbox/features/cart/data/cart_repository.dart';
import 'package:naqirgiftbox/features/cart/domain/entities/cart.dart';
import 'package:naqirgiftbox/features/cart/presentation/providers/cart_providers.dart';
import 'package:naqirgiftbox/features/products/domain/entities/product.dart';

class MockCartRepository extends Mock implements CartRepository {}

Product _buildProduct({String id = 'p-1', double price = 50}) {
  return Product(
    id: id,
    slug: 'slug-$id',
    name: 'Test product $id',
    shortDescription: 'short',
    description: 'description',
    specifications: const {},
    images: const ['assets/images/products/DRT-TERMEH-BOX-T01-RED.jpg'],
    price: price,
    sku: 'SKU-$id',
    categoryId: 'cat-1',
    stockQuantity: 10,
    rating: 4.5,
    reviewCount: 3,
    createdAt: DateTime(2026),
  );
}

void main() {
  late MockCartRepository repository;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(const Cart());
  });

  setUp(() {
    repository = MockCartRepository();
    when(() => repository.getCart()).thenReturn(const Cart());
    when(() => repository.saveCart(any())).thenAnswer((_) async {});
    when(
      () => repository.validateCoupon(any(), any()),
    ).thenReturn((isValid: true, discount: 10.0, errorMessage: null));

    container = ProviderContainer(
      overrides: [cartRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
  });

  test('addItem adds a new line item and persists it', () async {
    final notifier = container.read(cartProvider.notifier);

    await notifier.addItem(product: _buildProduct());

    final cart = container.read(cartProvider);
    expect(cart.items, hasLength(1));
    expect(cart.items.first.quantity, 1);
    expect(cart.subtotal, 50);
    verify(() => repository.saveCart(any())).called(1);
  });

  test(
    'addItem increments quantity instead of duplicating the line item',
    () async {
      final notifier = container.read(cartProvider.notifier);
      final product = _buildProduct();

      await notifier.addItem(product: product);
      await notifier.addItem(product: product, quantity: 2);

      final cart = container.read(cartProvider);
      expect(cart.items, hasLength(1));
      expect(cart.items.first.quantity, 3);
    },
  );

  test('two different products create two line items', () async {
    final notifier = container.read(cartProvider.notifier);

    await notifier.addItem(product: _buildProduct(id: 'p-1'));
    await notifier.addItem(product: _buildProduct(id: 'p-2', price: 75));

    final cart = container.read(cartProvider);
    expect(cart.items, hasLength(2));
    expect(cart.subtotal, 125);
  });

  test(
    'updateQuantity removes the line item once quantity reaches zero',
    () async {
      final notifier = container.read(cartProvider.notifier);
      await notifier.addItem(product: _buildProduct());
      final lineId = container.read(cartProvider).items.first.id;

      await notifier.updateQuantity(lineId, 0);

      expect(container.read(cartProvider).items, isEmpty);
    },
  );

  test('applyCoupon applies the discount the repository reports', () async {
    final notifier = container.read(cartProvider.notifier);
    await notifier.addItem(product: _buildProduct());

    final result = await notifier.applyCoupon('WELCOME10');

    expect(result.success, isTrue);
    final cart = container.read(cartProvider);
    expect(cart.couponDiscount, 10.0);
    expect(cart.total, cart.subtotal - 10.0);
  });

  test(
    'applyCoupon surfaces a validation failure without touching the cart',
    () async {
      when(() => repository.validateCoupon(any(), any())).thenReturn((
        isValid: false,
        discount: 0.0,
        errorMessage: 'Invalid code',
      ));
      final notifier = container.read(cartProvider.notifier);
      await notifier.addItem(product: _buildProduct());

      final result = await notifier.applyCoupon('BAD');

      expect(result.success, isFalse);
      expect(result.errorMessage, 'Invalid code');
      expect(container.read(cartProvider).couponDiscount, 0);
    },
  );

  test('clear empties the cart and persists the empty state', () async {
    final notifier = container.read(cartProvider.notifier);
    await notifier.addItem(product: _buildProduct());

    await notifier.clear();

    expect(container.read(cartProvider).isEmpty, isTrue);
  });
}
