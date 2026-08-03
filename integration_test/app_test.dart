// Full end-to-end happy path against the mock catalog: browse from Home to
// a product, add it to the cart, and confirm it shows up there.
//
// Run with a connected device/emulator or Chrome:
//   flutter test integration_test/app_test.dart -d <device-id>
//
// Written and reviewed for correctness against the current widget tree, but
// not executed in this session — no connected device/emulator was available
// and browser frame compositing was unavailable (see CHANGELOG). Please run
// it once before relying on it in CI.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:naqirgiftbox/app.dart';
import 'package:naqirgiftbox/core/di/injector.dart';
import 'package:naqirgiftbox/core/storage/hive/hive_boxes.dart';
import 'package:naqirgiftbox/shared/widgets/cards/product_card.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('browse a product, add it to cart, and see it in the cart tab', (
    tester,
  ) async {
    await HiveBoxes.init();
    await configureDependencies();

    await tester.pumpWidget(const ProviderScope(child: NaqirGiftBoxApp()));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    final skipButton = find.text('Skip');
    if (skipButton.evaluate().isNotEmpty) {
      await tester.tap(skipButton);
      await tester.pumpAndSettle();
    }

    // Home should be showing at least one product card once data loads.
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(ProductCard), findsWidgets);

    await tester.tap(find.byType(ProductCard).first);
    await tester.pumpAndSettle();

    // Product detail screen: add to cart via its bottom action bar. It
    // renders as an OutlinedButton (PrimaryButton's `outlined: true` case).
    final addToCartButton = find.widgetWithText(OutlinedButton, 'Add to cart');
    expect(addToCartButton, findsOneWidget);
    await tester.tap(addToCartButton);
    await tester.pumpAndSettle();

    // Go back to the shell, then to the Cart tab.
    if (Navigator.canPop(tester.element(find.byType(Scaffold).first))) {
      await tester.pageBack();
      await tester.pumpAndSettle();
    }

    await tester.tap(find.byIcon(Icons.shopping_bag_outlined));
    await tester.pumpAndSettle();

    // The empty-cart illustration must be gone, and a subtotal row present.
    expect(find.textContaining('SAR'), findsWidgets);
  });
}
