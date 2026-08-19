import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naqirgiftbox/core/constants/app_dimens.dart';
import 'package:naqirgiftbox/core/router/route_paths.dart';
import 'package:naqirgiftbox/features/cart/presentation/providers/cart_providers.dart';
import 'package:naqirgiftbox/features/products/domain/entities/product.dart';
import 'package:naqirgiftbox/features/wishlist/presentation/providers/wishlist_providers.dart';
import 'package:go_router/go_router.dart';
import 'package:naqirgiftbox/shared/widgets/cards/product_card.dart';

/// Horizontal scroller of [ProductCard]s — reused by Home's rails and the
/// product-detail screen's "Related Products"/"Recently Viewed" sections, so
/// wishlist/cart wiring lives in exactly one place.
class ProductRail extends ConsumerWidget {
  const ProductRail({
    required this.products,
    required this.heroNamespace,
    super.key,
    this.height = 260,
    this.cardWidth = 168,
  });

  final List<Product> products;

  /// Unique per rail. The same product can appear in more than one rail (e.g.
  /// Featured *and* Best Sellers), so each card's Hero tag is namespaced to
  /// keep it unique within the page — two heroes sharing a tag in one subtree
  /// throws and cascades into a Navigator key assertion. Namespaced tags don't
  /// match the detail screen's `product-image-<id>` hero, so rails don't play
  /// the shared-element flight (grid/search/wishlist still do).
  final String heroNamespace;
  final double height;
  final double cardWidth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlist = ref.watch(wishlistProvider);

    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: products.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final product = products[index];
          return SizedBox(
            width: cardWidth,
            child: ProductCard(
              product: product,
              heroTag: '$heroNamespace-${product.id}',
              isWishlisted: wishlist.contains(product.id),
              onTap: () => context.push(RoutePaths.productPath(product.id)),
              onToggleWishlist: () =>
                  ref.read(wishlistProvider.notifier).toggle(product.id),
              onAddToCart: () {
                ref.read(cartProvider.notifier).addItem(product: product);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${product.name} added to cart')),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
