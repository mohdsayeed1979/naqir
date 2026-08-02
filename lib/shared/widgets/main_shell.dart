import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:naqirgiftbox/core/localization/gen/app_localizations.dart';

/// Bottom-navigation scaffold for the five main tabs. Wraps a
/// [StatefulShellRoute] branch container, so each tab keeps its own
/// navigation stack and scroll position when switching away and back.
class MainShell extends StatelessWidget {
  const MainShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.storefront_outlined),
            selectedIcon: const Icon(Icons.storefront_rounded),
            label: l10n.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.grid_view_outlined),
            selectedIcon: const Icon(Icons.grid_view_rounded),
            label: l10n.navCategories,
          ),
          NavigationDestination(
            icon: const Icon(Icons.favorite_border_rounded),
            selectedIcon: const Icon(Icons.favorite_rounded),
            label: l10n.navWishlist,
          ),
          NavigationDestination(
            icon: const Icon(Icons.shopping_bag_outlined),
            selectedIcon: const Icon(Icons.shopping_bag_rounded),
            label: l10n.navCart,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline_rounded),
            selectedIcon: const Icon(Icons.person_rounded),
            label: l10n.navProfile,
          ),
        ],
      ),
    );
  }
}
