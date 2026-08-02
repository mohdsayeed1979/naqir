import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:naqirgiftbox/core/constants/app_dimens.dart';
import 'package:naqirgiftbox/core/error/failures.dart';
import 'package:naqirgiftbox/core/localization/gen/app_localizations.dart';
import 'package:naqirgiftbox/core/router/route_paths.dart';
import 'package:naqirgiftbox/features/categories/domain/entities/category.dart';
import 'package:naqirgiftbox/features/categories/presentation/providers/category_providers.dart';
import 'package:naqirgiftbox/shared/widgets/app_image.dart';
import 'package:naqirgiftbox/shared/widgets/loaders/shimmer_box.dart';
import 'package:naqirgiftbox/shared/widgets/states/empty_state.dart';
import 'package:naqirgiftbox/shared/widgets/states/error_state.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.categoriesTitle),
        actions: [
          IconButton(
            tooltip: l10n.productsAllProducts,
            icon: const Icon(Icons.apps_rounded),
            onPressed: () => context.push(RoutePaths.allProducts),
          ),
        ],
      ),
      body: categories.when(
        loading: () => GridView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: AppSpacing.md,
            crossAxisSpacing: AppSpacing.md,
            childAspectRatio: 1.3,
          ),
          itemCount: 6,
          itemBuilder: (context, _) =>
              ShimmerBox(borderRadius: BorderRadius.circular(AppRadius.lg)),
        ),
        error: (error, _) => ErrorState(
          failure: error is Failure ? error : const UnknownFailure(),
          onRetry: () => ref.invalidate(categoriesProvider),
        ),
        data: (items) {
          if (items.isEmpty) {
            return EmptyState(
              icon: Icons.category_outlined,
              title: l10n.categoriesEmpty,
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
              childAspectRatio: 1.3,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) =>
                _CategoryTile(category: items[index]),
          );
        },
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category});

  final Category category;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      clipBehavior: Clip.antiAlias,
      elevation: AppElevation.card,
      shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.10),
      child: InkWell(
        onTap: () => context.push(
          RoutePaths.categoryPath(category.id),
          extra: category.name,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            AppImage(category.imageUrl ?? '', fit: BoxFit.cover),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0),
                    Colors.black.withValues(alpha: 0.55),
                  ],
                ),
              ),
            ),
            Positioned(
              left: AppSpacing.sm,
              right: AppSpacing.sm,
              bottom: AppSpacing.sm,
              child: Text(
                category.name,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
