import 'package:flutter/material.dart';
import 'package:naqirgiftbox/core/constants/app_dimens.dart';
import 'package:naqirgiftbox/features/products/domain/entities/product.dart';
import 'package:naqirgiftbox/shared/widgets/app_image.dart';
import 'package:naqirgiftbox/shared/widgets/loaders/shimmer_box.dart';

/// The app's signature product tile: full-bleed image, floating wishlist/add
/// buttons, discount badge, and a rating row. A pure presentational widget —
/// the parent screen owns wishlist/cart state and passes callbacks in.
class ProductCard extends StatelessWidget {
  const ProductCard({
    required this.product,
    required this.onTap,
    required this.onAddToCart,
    required this.onToggleWishlist,
    required this.isWishlisted,
    super.key,
    this.heroTag,
  });

  final Product product;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;
  final VoidCallback onToggleWishlist;
  final bool isWishlisted;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      clipBehavior: Clip.antiAlias,
      elevation: AppElevation.card,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.10),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: heroTag ?? 'product-image-${product.id}',
                    child: AppImage(product.primaryImage, fit: BoxFit.cover),
                  ),
                  if (product.hasDiscount)
                    Positioned(
                      top: AppSpacing.xs,
                      left: AppSpacing.xs,
                      child: _Badge(
                        label: '-${product.discountPercent!.round()}%',
                        color: colorScheme.error,
                        onColor: theme.colorScheme.onError,
                      ),
                    ),
                  if (product.isNew && !product.hasDiscount)
                    Positioned(
                      top: AppSpacing.xs,
                      left: AppSpacing.xs,
                      child: _Badge(
                        label: 'NEW',
                        color: colorScheme.tertiary,
                        onColor: colorScheme.onTertiary,
                      ),
                    ),
                  Positioned(
                    top: AppSpacing.xs,
                    right: AppSpacing.xs,
                    child: _CircleIconButton(
                      icon: isWishlisted
                          ? Icons.favorite
                          : Icons.favorite_border,
                      iconColor: isWishlisted
                          ? colorScheme.error
                          : colorScheme.onSurface,
                      onPressed: onToggleWishlist,
                    ),
                  ),
                  Positioned(
                    bottom: AppSpacing.xs,
                    right: AppSpacing.xs,
                    child: _CircleIconButton(
                      icon: Icons.add_shopping_cart_rounded,
                      iconColor: colorScheme.onPrimary,
                      backgroundColor: colorScheme.primary,
                      onPressed: product.inStock ? onAddToCart : null,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.sm,
                AppSpacing.sm,
                AppSpacing.sm,
                AppSpacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        size: 16,
                        color: colorScheme.tertiary,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        product.rating.toStringAsFixed(1),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        ' (${product.reviewCount})',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Row(
                    children: [
                      Text(
                        'SAR ${product.price.toStringAsFixed(0)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (product.hasDiscount) ...[
                        const SizedBox(width: AppSpacing.xxs),
                        Text(
                          product.compareAtPrice!.toStringAsFixed(0),
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(child: ShimmerBox(borderRadius: BorderRadius.zero)),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: const [
                ShimmerBox(width: 120, height: 14),
                SizedBox(height: AppSpacing.xs),
                ShimmerBox(width: 60, height: 12),
                SizedBox(height: AppSpacing.xs),
                ShimmerBox(width: 80, height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.color,
    required this.onColor,
  });

  final String label;
  final Color color;
  final Color onColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: onColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.iconColor,
    required this.onPressed,
    this.backgroundColor,
  });

  final IconData icon;
  final Color iconColor;
  final Color? backgroundColor;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final bg =
        backgroundColor ??
        Theme.of(context).colorScheme.surface.withValues(alpha: 0.9);
    return Material(
      color: bg,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(7),
          child: Icon(
            icon,
            size: 18,
            color: onPressed == null
                ? iconColor.withValues(alpha: 0.4)
                : iconColor,
          ),
        ),
      ),
    );
  }
}
