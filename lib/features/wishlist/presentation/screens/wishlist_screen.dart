import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:naqirgiftbox/core/constants/app_dimens.dart';
import 'package:naqirgiftbox/core/localization/gen/app_localizations.dart';
import 'package:naqirgiftbox/core/router/route_paths.dart';
import 'package:naqirgiftbox/features/cart/presentation/providers/cart_providers.dart';
import 'package:naqirgiftbox/features/wishlist/presentation/providers/wishlist_providers.dart';
import 'package:naqirgiftbox/shared/widgets/cards/product_card.dart';
import 'package:naqirgiftbox/shared/widgets/states/empty_state.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final products = ref.watch(wishlistProductsProvider);
    final wishlistIds = ref.watch(wishlistProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.wishlistTitle)),
      body: products.when(
        loading: () => GridView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: AppSpacing.sm,
            crossAxisSpacing: AppSpacing.sm,
            childAspectRatio: 0.62,
          ),
          itemCount: 4,
          itemBuilder: (context, _) => const ProductCardSkeleton(),
        ),
        error: (_, _) => EmptyState(
          icon: Icons.error_outline_rounded,
          title: l10n.commonSomethingWentWrong,
        ),
        data: (items) {
          if (items.isEmpty) {
            return EmptyState(
              icon: Icons.favorite_border_rounded,
              title: l10n.wishlistEmpty,
              message: l10n.wishlistEmptySubtitle,
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.sm,
              crossAxisSpacing: AppSpacing.sm,
              childAspectRatio: 0.62,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final product = items[index];
              return ProductCard(
                product: product,
                isWishlisted: wishlistIds.contains(product.id),
                onTap: () => context.push(RoutePaths.productPath(product.id)),
                onToggleWishlist: () =>
                    ref.read(wishlistProvider.notifier).toggle(product.id),
                onAddToCart: () {
                  ref.read(cartProvider.notifier).addItem(product: product);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${product.name} added to cart')),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
