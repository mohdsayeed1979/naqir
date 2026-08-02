/// Path segments for the generic REST contract described in
/// docs/ARCHITECTURE.md §1. Relative to [AppConfig.apiBaseUrl] — swap the
/// base URL to point at the Zid Partner API or any other backend without
/// touching call sites.
abstract final class ApiEndpoints {
  // Auth
  static const login = '/auth/login';
  static const register = '/auth/register';
  static const otpRequest = '/auth/otp/request';
  static const otpVerify = '/auth/otp/verify';
  static const forgotPassword = '/auth/forgot-password';
  static const refreshToken = '/auth/refresh';
  static const logout = '/auth/logout';

  // Catalog
  static const products = '/products';
  static String product(String id) => '/products/$id';
  static String relatedProducts(String id) => '/products/$id/related';
  static const categories = '/categories';
  static String category(String id) => '/categories/$id';

  // Search
  static const search = '/search';
  static const searchSuggestions = '/search/suggestions';
  static const searchTrending = '/search/trending';

  // Cart
  static const cart = '/cart';
  static const cartItems = '/cart/items';
  static const cartCoupon = '/cart/coupon';

  // Wishlist
  static const wishlist = '/wishlist';

  // Checkout / orders
  static const addresses = '/addresses';
  static const shippingMethods = '/shipping-methods';
  static const orders = '/orders';
  static String order(String id) => '/orders/$id';

  // Profile
  static const account = '/account';
  static const notificationPreferences = '/account/notification-preferences';
}
