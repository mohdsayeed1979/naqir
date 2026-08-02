import 'package:hive_flutter/hive_flutter.dart';

/// Box name constants. Every box is `Box<String>` — structured values are
/// JSON-encoded through the same Freezed `toJson`/`fromJson` used for network
/// DTOs (see docs/ARCHITECTURE.md's dependency-version note) rather than
/// generated Hive TypeAdapters, so there's a single serialization mechanism.
abstract final class HiveBoxNames {
  static const settings = 'settings_box';
  static const cart = 'cart_box';
  static const wishlist = 'wishlist_box';
  static const recentlyViewed = 'recently_viewed_box';
  static const searchHistory = 'search_history_box';
  static const addresses = 'addresses_box';
  static const orders = 'orders_box';
}

/// Opens every Hive box once at bootstrap. Call [init] before `runApp`.
abstract final class HiveBoxes {
  static Future<void> init() async {
    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox<String>(HiveBoxNames.settings),
      Hive.openBox<String>(HiveBoxNames.cart),
      Hive.openBox<String>(HiveBoxNames.wishlist),
      Hive.openBox<String>(HiveBoxNames.recentlyViewed),
      Hive.openBox<String>(HiveBoxNames.searchHistory),
      Hive.openBox<String>(HiveBoxNames.addresses),
      Hive.openBox<String>(HiveBoxNames.orders),
    ]);
  }

  static Box<String> get settings => Hive.box<String>(HiveBoxNames.settings);
  static Box<String> get cart => Hive.box<String>(HiveBoxNames.cart);
  static Box<String> get wishlist => Hive.box<String>(HiveBoxNames.wishlist);
  static Box<String> get recentlyViewed =>
      Hive.box<String>(HiveBoxNames.recentlyViewed);
  static Box<String> get searchHistory =>
      Hive.box<String>(HiveBoxNames.searchHistory);
  static Box<String> get addresses => Hive.box<String>(HiveBoxNames.addresses);
  static Box<String> get orders => Hive.box<String>(HiveBoxNames.orders);
}
