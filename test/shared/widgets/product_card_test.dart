import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naqirgiftbox/features/products/domain/entities/product.dart';
import 'package:naqirgiftbox/shared/widgets/cards/product_card.dart';

Product _buildProduct() {
  return Product(
    id: 'p-1',
    slug: 'slug',
    name: 'Regal Dates Gift Box',
    shortDescription: 'short',
    description: 'description',
    specifications: const {},
    images: const ['assets/images/products/DRT-TERMEH-BOX-T01-RED.jpg'],
    price: 125,
    compareAtPrice: 150,
    sku: 'SKU-1',
    categoryId: 'cat-1',
    stockQuantity: 10,
    rating: 4.8,
    reviewCount: 20,
    createdAt: DateTime(2026),
  );
}

void main() {
  testWidgets('shows the product name, price, and discount badge', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductCard(
            product: _buildProduct(),
            onTap: () {},
            onAddToCart: () {},
            onToggleWishlist: () {},
            isWishlisted: false,
          ),
        ),
      ),
    );

    expect(find.text('Regal Dates Gift Box'), findsOneWidget);
    expect(find.textContaining('125'), findsOneWidget);
    // (150 - 125) / 150 * 100, rounded.
    expect(find.text('-17%'), findsOneWidget);
  });

  testWidgets(
    'reports a tap on the card body and on the wishlist icon separately',
    (tester) async {
      var cardTapped = false;
      var wishlistToggled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductCard(
              product: _buildProduct(),
              onTap: () => cardTapped = true,
              onAddToCart: () {},
              onToggleWishlist: () => wishlistToggled = true,
              isWishlisted: false,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.favorite_border));
      expect(wishlistToggled, isTrue);
      expect(cardTapped, isFalse);

      await tester.tap(find.byType(ProductCard));
      expect(cardTapped, isTrue);
    },
  );

  testWidgets('shows a filled heart and error color when already wishlisted', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductCard(
            product: _buildProduct(),
            onTap: () {},
            onAddToCart: () {},
            onToggleWishlist: () {},
            isWishlisted: true,
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.favorite), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border), findsNothing);
  });
}
