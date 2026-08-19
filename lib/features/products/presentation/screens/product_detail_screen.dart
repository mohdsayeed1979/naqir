import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:naqirgiftbox/core/constants/app_dimens.dart';
import 'package:naqirgiftbox/core/error/failures.dart';
import 'package:naqirgiftbox/core/localization/gen/app_localizations.dart';
import 'package:naqirgiftbox/core/router/route_paths.dart';
import 'package:naqirgiftbox/features/cart/presentation/providers/cart_providers.dart';
import 'package:naqirgiftbox/features/products/domain/entities/product.dart';
import 'package:naqirgiftbox/features/products/domain/entities/review.dart';
import 'package:naqirgiftbox/features/products/presentation/providers/product_providers.dart';
import 'package:naqirgiftbox/features/products/presentation/providers/recently_viewed_providers.dart';
import 'package:naqirgiftbox/features/products/presentation/providers/review_providers.dart';
import 'package:naqirgiftbox/features/products/presentation/widgets/product_image_gallery.dart';
import 'package:naqirgiftbox/features/wishlist/presentation/providers/wishlist_providers.dart';
import 'package:naqirgiftbox/shared/widgets/buttons/primary_button.dart';
import 'package:naqirgiftbox/shared/widgets/product_rail.dart';
import 'package:naqirgiftbox/shared/widgets/section_header.dart';
import 'package:naqirgiftbox/shared/widgets/states/error_state.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  const ProductDetailScreen({required this.productId, super.key});

  final String productId;

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  ProductVariant? _selectedVariant;
  int _quantity = 1;
  bool _descriptionExpanded = false;
  bool _hasRecordedView = false;

  void _onProductLoaded(Product product) {
    if (_selectedVariant == null && product.variants.isNotEmpty) {
      _selectedVariant = product.variants.first;
    }
    if (!_hasRecordedView) {
      _hasRecordedView = true;
      Future.microtask(
        () => ref.read(recentlyViewedProvider.notifier).recordView(product.id),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productDetailProvider(widget.productId));

    return Scaffold(
      body: productAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorState(
          failure: error is Failure ? error : const UnknownFailure(),
          onRetry: () =>
              ref.invalidate(productDetailProvider(widget.productId)),
        ),
        data: (product) {
          _onProductLoaded(product);
          return _ProductDetailContent(
            product: product,
            selectedVariant: _selectedVariant,
            quantity: _quantity,
            descriptionExpanded: _descriptionExpanded,
            onSelectVariant: (variant) =>
                setState(() => _selectedVariant = variant),
            onQuantityChanged: (qty) => setState(() => _quantity = qty),
            onToggleDescription: () =>
                setState(() => _descriptionExpanded = !_descriptionExpanded),
          );
        },
      ),
      bottomNavigationBar: productAsync.maybeWhen(
        data: (product) => _BottomActionBar(
          product: product,
          quantity: _quantity,
          selectedVariant: _selectedVariant,
        ),
        orElse: () => null,
      ),
    );
  }
}

class _ProductDetailContent extends ConsumerWidget {
  const _ProductDetailContent({
    required this.product,
    required this.selectedVariant,
    required this.quantity,
    required this.descriptionExpanded,
    required this.onSelectVariant,
    required this.onQuantityChanged,
    required this.onToggleDescription,
  });

  final Product product;
  final ProductVariant? selectedVariant;
  final int quantity;
  final bool descriptionExpanded;
  final ValueChanged<ProductVariant> onSelectVariant;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onToggleDescription;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isWishlisted = ref.watch(wishlistProvider).contains(product.id);
    final effectivePrice = selectedVariant?.priceOverride ?? product.price;

    final galleryImages = {
      product.primaryImage,
      ...product.images,
      ...product.variants.map((v) => v.imageUrl).whereType<String>(),
    }.where((path) => path.isNotEmpty).toList();

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: 380,
          backgroundColor: theme.colorScheme.surface,
          foregroundColor: theme.colorScheme.onSurface,
          // Pop through go_router (not Navigator.maybePop) so the route match
          // is actually removed. Otherwise the popped page lingers in
          // go_router's match list and re-materialises on the next branch
          // switch, colliding page keys (`!keyReservation.contains(key)`).
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => context.pop(),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: ProductImageGallery(
              images: galleryImages,
              heroTag: 'product-image-${product.id}',
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.share_outlined),
              onPressed: () => SharePlus.instance.share(
                ShareParams(
                  text:
                      '${product.name} — SAR ${effectivePrice.toStringAsFixed(0)}',
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                isWishlisted ? Icons.favorite : Icons.favorite_border,
                color: isWishlisted ? theme.colorScheme.error : null,
              ),
              onPressed: () =>
                  ref.read(wishlistProvider.notifier).toggle(product.id),
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: theme.textTheme.headlineSmall),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Icon(
                      Icons.star_rounded,
                      size: 18,
                      color: theme.colorScheme.tertiary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${product.rating} (${product.reviewCount})',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Icon(
                      product.inStock
                          ? Icons.check_circle_outline
                          : Icons.remove_circle_outline,
                      size: 18,
                      color: product.inStock
                          ? theme.colorScheme.primary
                          : theme.colorScheme.error,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      product.inStock
                          ? l10n.productInStock
                          : l10n.productOutOfStock,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Text(
                      'SAR ${effectivePrice.toStringAsFixed(0)}',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (product.hasDiscount) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        product.compareAtPrice!.toStringAsFixed(0),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ],
                ),
                if (product.variants.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Wrap(
                    spacing: AppSpacing.xs,
                    children: product.variants.map((variant) {
                      final selected = variant.id == selectedVariant?.id;
                      return ChoiceChip(
                        label: Text(variant.label),
                        selected: selected,
                        onSelected: variant.inStock
                            ? (_) => onSelectVariant(variant)
                            : null,
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.productQuantity,
                      style: theme.textTheme.titleSmall,
                    ),
                    _QuantityStepper(
                      quantity: quantity,
                      maxQuantity: product.stockQuantity,
                      onChanged: onQuantityChanged,
                    ),
                  ],
                ),
                const Divider(height: AppSpacing.xl),
                Text(
                  l10n.productDescription,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  product.description,
                  maxLines: descriptionExpanded ? null : 3,
                  overflow: descriptionExpanded ? null : TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                TextButton(
                  onPressed: onToggleDescription,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                  ),
                  child: Text(
                    descriptionExpanded
                        ? l10n.commonBack
                        : l10n.productMoreInformation,
                  ),
                ),
                if (product.specifications.isNotEmpty) ...[
                  const Divider(height: AppSpacing.xl),
                  Text(
                    l10n.productSpecifications,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ...product.specifications.entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 120,
                            child: Text(
                              entry.key,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              entry.value,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const Divider(height: AppSpacing.xl),
                Text(l10n.productReviews, style: theme.textTheme.titleMedium),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(child: _ReviewsList(productId: product.id)),
        Consumer(
          builder: (context, ref, _) {
            final related = ref.watch(relatedProductsProvider(product.id));
            return related.maybeWhen(
              data: (items) => items.isEmpty
                  ? const SliverToBoxAdapter(child: SizedBox.shrink())
                  : SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: AppSpacing.lg),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                            ),
                            child: SectionHeader(title: l10n.productRelated),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          ProductRail(
                            products: items,
                            heroNamespace: 'detail-related',
                          ),
                        ],
                      ),
                    ),
              orElse: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
            );
          },
        ),
        Consumer(
          builder: (context, ref, _) {
            final recentlyViewed = ref.watch(
              recentlyViewedProductsProvider(product.id),
            );
            return recentlyViewed.maybeWhen(
              data: (items) => items.isEmpty
                  ? const SliverToBoxAdapter(child: SizedBox.shrink())
                  : SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: AppSpacing.lg),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                            ),
                            child: SectionHeader(
                              title: l10n.productRecentlyViewed,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          ProductRail(
                            products: items,
                            heroNamespace: 'detail-recent',
                          ),
                        ],
                      ),
                    ),
              orElse: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
            );
          },
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
      ],
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.quantity,
    required this.maxQuantity,
    required this.onChanged,
  });

  final int quantity;
  final int maxQuantity;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: quantity > 1 ? () => onChanged(quantity - 1) : null,
          ),
          SizedBox(
            width: 28,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: quantity < maxQuantity
                ? () => onChanged(quantity + 1)
                : null,
          ),
        ],
      ),
    );
  }
}

class _ReviewsList extends ConsumerWidget {
  const _ReviewsList({required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviews = ref.watch(productReviewsProvider(productId));
    return reviews.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: LinearProgressIndicator(),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (items) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Column(
          children: items.map((review) => _ReviewTile(review: review)).toList(),
        ),
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.review});

  final Review review;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Text(
                  review.authorName.characters.first,
                  style: TextStyle(color: theme.colorScheme.onPrimaryContainer),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.authorName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: List.generate(
                        5,
                        (index) => Icon(
                          index < review.rating.round()
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          size: 14,
                          color: theme.colorScheme.tertiary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(review.comment, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _BottomActionBar extends ConsumerWidget {
  const _BottomActionBar({
    required this.product,
    required this.quantity,
    required this.selectedVariant,
  });

  final Product product;
  final int quantity;
  final ProductVariant? selectedVariant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.sm,
        ),
        child: Row(
          children: [
            Expanded(
              child: PrimaryButton(
                label: l10n.productAddToCart,
                outlined: true,
                onPressed: product.inStock
                    ? () {
                        ref
                            .read(cartProvider.notifier)
                            .addItem(
                              product: product,
                              quantity: quantity,
                              variant: selectedVariant,
                            );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${product.name} added to cart'),
                          ),
                        );
                      }
                    : null,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: PrimaryButton(
                label: l10n.productBuyNow,
                onPressed: product.inStock
                    ? () {
                        ref
                            .read(cartProvider.notifier)
                            .addItem(
                              product: product,
                              quantity: quantity,
                              variant: selectedVariant,
                            );
                        // /cart is a bottom-nav branch: switch to it with go()
                        // — pushing a shell-branch route duplicates the shell
                        // and its page keys (crashes/blank screens).
                        context.go(RoutePaths.cart);
                      }
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
