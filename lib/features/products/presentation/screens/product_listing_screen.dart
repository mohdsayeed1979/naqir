import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:naqirgiftbox/core/constants/app_dimens.dart';
import 'package:naqirgiftbox/core/localization/gen/app_localizations.dart';
import 'package:naqirgiftbox/core/router/route_paths.dart';
import 'package:naqirgiftbox/features/cart/presentation/providers/cart_providers.dart';
import 'package:naqirgiftbox/features/products/domain/entities/product_query.dart';
import 'package:naqirgiftbox/features/products/presentation/providers/product_list_notifier.dart';
import 'package:naqirgiftbox/features/products/presentation/providers/product_list_state.dart';
import 'package:naqirgiftbox/features/wishlist/presentation/providers/wishlist_providers.dart';
import 'package:naqirgiftbox/shared/widgets/cards/product_card.dart';
import 'package:naqirgiftbox/shared/widgets/states/empty_state.dart';
import 'package:naqirgiftbox/shared/widgets/states/error_state.dart';

/// Drives both "/category/:id" and the general "All Products" route — the
/// only difference is the [initialQuery] seeded into [productListProvider].
class ProductListingScreen extends ConsumerStatefulWidget {
  const ProductListingScreen({
    required this.initialQuery,
    required this.title,
    super.key,
  });

  final ProductQuery initialQuery;
  final String title;

  @override
  ConsumerState<ProductListingScreen> createState() =>
      _ProductListingScreenState();
}

class _ProductListingScreenState extends ConsumerState<ProductListingScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 400) {
      ref
          .read(productListProvider(widget.initialQuery).notifier)
          .loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(productListProvider(widget.initialQuery));

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.productsTotalCount(state.totalCount),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _showFilterSheet(context),
                  icon: const Icon(Icons.tune_rounded, size: 18),
                  label: Text(l10n.productsFilter),
                ),
                TextButton.icon(
                  onPressed: () => _showSortSheet(context),
                  icon: const Icon(Icons.sort_rounded, size: 18),
                  label: Text(l10n.productsSortBy),
                ),
              ],
            ),
          ),
          Expanded(child: _buildBody(context, state)),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, ProductListState state) {
    final l10n = AppLocalizations.of(context);
    final wishlist = ref.watch(wishlistProvider);

    if (state.isLoading) {
      return GridView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: AppSpacing.sm,
          crossAxisSpacing: AppSpacing.sm,
          childAspectRatio: 0.62,
        ),
        itemCount: 6,
        itemBuilder: (context, _) => const ProductCardSkeleton(),
      );
    }

    if (state.failure != null && state.items.isEmpty) {
      return ErrorState(
        failure: state.failure!,
        onRetry: () => ref
            .read(productListProvider(widget.initialQuery).notifier)
            .refresh(),
      );
    }

    if (state.items.isEmpty) {
      return EmptyState(
        icon: Icons.inventory_2_outlined,
        title: l10n.commonNoResultsFound,
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(productListProvider(widget.initialQuery).notifier).refresh(),
      child: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(AppSpacing.md),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: AppSpacing.sm,
          crossAxisSpacing: AppSpacing.sm,
          childAspectRatio: 0.62,
        ),
        itemCount: state.items.length + (state.isLoadingMore ? 2 : 0),
        itemBuilder: (context, index) {
          if (index >= state.items.length) return const ProductCardSkeleton();
          final product = state.items[index];
          return ProductCard(
            product: product,
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
          );
        },
      ),
    );
  }

  void _showSortSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final notifier = ref.read(
      productListProvider(widget.initialQuery).notifier,
    );
    final options = {
      ProductSortOption.newest: l10n.productsSortNewest,
      ProductSortOption.popular: l10n.productsSortPopular,
      ProductSortOption.priceLowToHigh: l10n.productsSortPriceLowToHigh,
      ProductSortOption.priceHighToLow: l10n.productsSortPriceHighToLow,
    };

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.entries
              .map(
                (entry) => ListTile(
                  title: Text(entry.value),
                  onTap: () {
                    notifier.updateSort(entry.key);
                    Navigator.of(context).pop();
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentQuery = ref
        .read(productListProvider(widget.initialQuery))
        .query;
    var minPrice = currentQuery.minPrice;
    var maxPrice = currentQuery.maxPrice;
    var discountedOnly = currentQuery.discountedOnly;

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.productsPriceRange,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                RangeSlider(
                  min: 0,
                  max: 300,
                  divisions: 30,
                  labels: RangeLabels(
                    (minPrice ?? 0).round().toString(),
                    (maxPrice ?? 300).round().toString(),
                  ),
                  values: RangeValues(minPrice ?? 0, maxPrice ?? 300),
                  onChanged: (values) => setSheetState(() {
                    minPrice = values.start;
                    maxPrice = values.end;
                  }),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.productsDiscountedOnly),
                  value: discountedOnly,
                  onChanged: (value) =>
                      setSheetState(() => discountedOnly = value),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          ref
                              .read(
                                productListProvider(
                                  widget.initialQuery,
                                ).notifier,
                              )
                              .applyFilters(
                                (q) => q.copyWith(
                                  minPrice: null,
                                  maxPrice: null,
                                  discountedOnly: false,
                                ),
                              );
                          Navigator.of(context).pop();
                        },
                        child: Text(l10n.commonClear),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          ref
                              .read(
                                productListProvider(
                                  widget.initialQuery,
                                ).notifier,
                              )
                              .applyFilters(
                                (q) => q.copyWith(
                                  minPrice: minPrice,
                                  maxPrice: maxPrice,
                                  discountedOnly: discountedOnly,
                                ),
                              );
                          Navigator.of(context).pop();
                        },
                        child: Text(l10n.commonApply),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
