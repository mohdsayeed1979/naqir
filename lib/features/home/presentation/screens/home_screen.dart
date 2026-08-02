import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:naqirgiftbox/core/constants/app_dimens.dart';
import 'package:naqirgiftbox/core/error/failures.dart';
import 'package:naqirgiftbox/core/localization/gen/app_localizations.dart';
import 'package:naqirgiftbox/core/router/route_paths.dart';
import 'package:naqirgiftbox/features/authentication/presentation/providers/auth_providers.dart';
import 'package:naqirgiftbox/features/categories/domain/entities/category.dart';
import 'package:naqirgiftbox/features/categories/presentation/providers/category_providers.dart';
import 'package:naqirgiftbox/features/home/presentation/providers/home_providers.dart';
import 'package:naqirgiftbox/features/home/presentation/widgets/promo_banner_carousel.dart';
import 'package:naqirgiftbox/shared/widgets/app_image.dart';
import 'package:naqirgiftbox/shared/widgets/cards/product_card.dart';
import 'package:naqirgiftbox/shared/widgets/inputs/app_search_bar.dart';
import 'package:naqirgiftbox/shared/widgets/loaders/shimmer_box.dart';
import 'package:naqirgiftbox/shared/widgets/product_rail.dart';
import 'package:naqirgiftbox/shared/widgets/section_header.dart';
import 'package:naqirgiftbox/shared/widgets/states/error_state.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(homeSectionsProvider);
    ref.invalidate(categoriesProvider);
    await ref.read(homeSectionsProvider.future);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final homeSections = ref.watch(homeSectionsProvider);
    final categories = ref.watch(categoriesProvider);
    final user = ref.watch(authProvider).valueOrNull;

    final banners = [
      PromoBanner(
        title: l10n.homeBannerGiftTitle,
        subtitle: l10n.homeBannerGiftSubtitle,
        icon: Icons.card_giftcard_rounded,
        colors: const [Color(0xFF9D6B3F), Color(0xFFC99846)],
      ),
      PromoBanner(
        title: l10n.homeBannerShippingTitle,
        subtitle: l10n.homeBannerShippingSubtitle,
        icon: Icons.local_shipping_rounded,
        colors: const [Color(0xFF6B4A2C), Color(0xFF9D6B3F)],
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _refresh(ref),
          child: homeSections.when(
            loading: () => const _HomeSkeleton(),
            error: (error, _) => ErrorState(
              failure: error is Failure ? error : const UnknownFailure(),
              onRetry: () => _refresh(ref),
            ),
            data: (sections) => CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.sm,
                      AppSpacing.md,
                      0,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user != null
                                    ? l10n.homeGreeting(
                                        user.fullName.split(' ').first,
                                      )
                                    : l10n.appName,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.notifications_none_rounded),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    child: AppSearchBarEntry(
                      onTap: () => context.push(RoutePaths.search),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.lg),
                ),
                SliverToBoxAdapter(
                  child: PromoBannerCarousel(banners: banners),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.lg),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    child: SectionHeader(
                      title: l10n.homeShopByCategory,
                      onSeeAll: () => context.push(RoutePaths.categories),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.sm),
                ),
                SliverToBoxAdapter(
                  child: categories.when(
                    data: (cats) => _CategoryRail(categories: cats),
                    loading: () => const SizedBox(height: 96),
                    error: (_, _) => const SizedBox.shrink(),
                  ),
                ),
                if (sections.featured.isNotEmpty) ...[
                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppSpacing.lg),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      child: SectionHeader(title: l10n.homeFeatured),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppSpacing.sm),
                  ),
                  SliverToBoxAdapter(
                    child: ProductRail(products: sections.featured),
                  ),
                ],
                if (sections.newArrivals.isNotEmpty) ...[
                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppSpacing.lg),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      child: SectionHeader(title: l10n.homeNewArrivals),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppSpacing.sm),
                  ),
                  SliverToBoxAdapter(
                    child: ProductRail(products: sections.newArrivals),
                  ),
                ],
                if (sections.bestSellers.isNotEmpty) ...[
                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppSpacing.lg),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      child: SectionHeader(title: l10n.homeBestSellers),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppSpacing.sm),
                  ),
                  SliverToBoxAdapter(
                    child: ProductRail(products: sections.bestSellers),
                  ),
                ],
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.xl),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryRail extends StatelessWidget {
  const _CategoryRail({required this.categories});

  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) {
          final category = categories[index];
          return InkWell(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            onTap: () => context.push(RoutePaths.categoryPath(category.id)),
            child: SizedBox(
              width: 68,
              child: Column(
                children: [
                  ClipOval(
                    child: AppImage(
                      category.imageUrl ?? '',
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    category.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        const ShimmerBox(width: 160, height: 20),
        const SizedBox(height: AppSpacing.md),
        ShimmerBox(
          width: double.infinity,
          height: 48,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        const SizedBox(height: AppSpacing.lg),
        ShimmerBox(
          width: double.infinity,
          height: 160,
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: List.generate(
            4,
            (_) => const Padding(
              padding: EdgeInsets.only(right: AppSpacing.md),
              child: ShimmerBox(
                width: 60,
                height: 60,
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        const ShimmerBox(width: 120, height: 20),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 260,
          child: Row(
            children: List.generate(
              3,
              (_) => const Padding(
                padding: EdgeInsets.only(right: AppSpacing.sm),
                child: SizedBox(width: 168, child: ProductCardSkeleton()),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
