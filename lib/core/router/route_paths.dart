abstract final class RoutePaths {
  static const splash = '/splash';
  static const onboarding = '/onboarding';

  static const login = '/login';
  static const register = '/register';
  static const otp = '/otp';
  static const forgotPassword = '/forgot-password';

  static const home = '/home';
  static const categories = '/categories';
  static const wishlist = '/wishlist';
  static const cart = '/cart';
  static const profile = '/profile';

  static const search = '/search';
  static const allProducts = '/products';
  static const category = '/category/:id';
  static String categoryPath(String id) => '/category/$id';

  static const product = '/product/:id';
  static String productPath(String id) => '/product/$id';

  static const checkout = '/checkout';
  static const orders = '/orders';
  static const orderDetail = '/orders/:id';
  static String orderDetailPath(String id) => '/orders/$id';

  static const settings = '/settings';
  static const editProfile = '/profile/edit';
  static const addresses = '/profile/addresses';
  static const addAddress = '/profile/addresses/add';
}
