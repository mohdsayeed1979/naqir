import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:naqirgiftbox/core/localization/gen/app_localizations.dart';
import 'package:naqirgiftbox/core/router/route_paths.dart';
import 'package:naqirgiftbox/features/authentication/presentation/providers/auth_providers.dart';
import 'package:naqirgiftbox/features/authentication/presentation/screens/forgot_password_screen.dart';
import 'package:naqirgiftbox/features/authentication/presentation/screens/login_screen.dart';
import 'package:naqirgiftbox/features/authentication/presentation/screens/otp_screen.dart';
import 'package:naqirgiftbox/features/authentication/presentation/screens/register_screen.dart';
import 'package:naqirgiftbox/features/cart/presentation/screens/cart_screen.dart';
import 'package:naqirgiftbox/features/categories/presentation/screens/categories_screen.dart';
import 'package:naqirgiftbox/features/checkout/presentation/screens/add_address_screen.dart';
import 'package:naqirgiftbox/features/checkout/presentation/screens/checkout_screen.dart';
import 'package:naqirgiftbox/features/home/presentation/screens/home_screen.dart';
import 'package:naqirgiftbox/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:naqirgiftbox/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:naqirgiftbox/features/orders/presentation/screens/order_detail_screen.dart';
import 'package:naqirgiftbox/features/orders/presentation/screens/orders_screen.dart';
import 'package:naqirgiftbox/features/products/domain/entities/product_query.dart';
import 'package:naqirgiftbox/features/products/presentation/screens/product_detail_screen.dart';
import 'package:naqirgiftbox/features/products/presentation/screens/product_listing_screen.dart';
import 'package:naqirgiftbox/features/profile/presentation/screens/addresses_screen.dart';
import 'package:naqirgiftbox/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:naqirgiftbox/features/profile/presentation/screens/profile_screen.dart';
import 'package:naqirgiftbox/features/search/presentation/screens/search_screen.dart';
import 'package:naqirgiftbox/features/settings/presentation/screens/settings_screen.dart';
import 'package:naqirgiftbox/features/splash/presentation/screens/splash_screen.dart';
import 'package:naqirgiftbox/features/wishlist/presentation/screens/wishlist_screen.dart';
import 'package:naqirgiftbox/shared/widgets/main_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

const _authRequiredPrefixes = [
  RoutePaths.checkout,
  RoutePaths.orders,
  RoutePaths.editProfile,
  RoutePaths.addresses,
];

/// Rebuilt whenever [authProvider] changes — acceptable here since auth
/// transitions (login/logout) are rare events, not per-frame state; see the
/// note in docs/ARCHITECTURE.md if a refresh-listenable bridge is ever
/// needed instead.
final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  final isAuthenticated = authState.valueOrNull != null;
  final isAuthResolved = !authState.isLoading;

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RoutePaths.splash,
    redirect: (context, state) {
      final location = state.matchedLocation;
      final requiresAuth = _authRequiredPrefixes.any(
        (prefix) => location.startsWith(prefix),
      );
      if (requiresAuth && isAuthResolved && !isAuthenticated) {
        return '${RoutePaths.login}?redirect=$location';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: RoutePaths.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RoutePaths.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: RoutePaths.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RoutePaths.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: RoutePaths.otp,
        builder: (context, state) => const OtpScreen(),
      ),
      GoRoute(
        path: RoutePaths.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: RoutePaths.search,
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: RoutePaths.allProducts,
        builder: (context, state) => ProductListingScreen(
          initialQuery: const ProductQuery(),
          title: AppLocalizations.of(context).productsAllProducts,
        ),
      ),
      GoRoute(
        path: RoutePaths.category,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final title =
              state.extra as String? ??
              AppLocalizations.of(context).categoriesTitle;
          return ProductListingScreen(
            initialQuery: ProductQuery(categoryId: id),
            title: title,
          );
        },
      ),
      GoRoute(
        path: RoutePaths.product,
        builder: (context, state) =>
            ProductDetailScreen(productId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: RoutePaths.checkout,
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: RoutePaths.orders,
        builder: (context, state) => const OrdersScreen(),
      ),
      GoRoute(
        path: RoutePaths.orderDetail,
        builder: (context, state) =>
            OrderDetailScreen(orderId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: RoutePaths.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: RoutePaths.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: RoutePaths.editProfile,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: RoutePaths.addAddress,
        builder: (context, state) => const AddAddressScreen(),
      ),
      GoRoute(
        path: RoutePaths.addresses,
        builder: (context, state) => const AddressesScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.categories,
                builder: (context, state) => const CategoriesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.wishlist,
                builder: (context, state) => const WishlistScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.cart,
                builder: (context, state) => const CartScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.profile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
