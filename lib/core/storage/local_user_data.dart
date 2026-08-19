import 'package:naqirgiftbox/core/storage/hive/hive_boxes.dart';
import 'package:naqirgiftbox/core/storage/secure/secure_storage_service.dart';

/// Single source of truth for "what local data belongs to the signed-in
/// user". Used by account deletion (Guideline 5.1.1(v)) to guarantee every
/// user-owned record on the device is erased — if a new per-user store is
/// added later, wipe it here so deletion stays complete.
class LocalUserDataStore {
  LocalUserDataStore(this._secureStorage);

  final SecureStorageService _secureStorage;

  /// Keys inside the shared settings box that hold user-specific data.
  /// Everything else in that box (onboarding-seen flag, locale, theme mode)
  /// is device preference, not personal data, and is intentionally kept so
  /// the app doesn't reset to onboarding after deletion.
  static const _userSettingsKeys = <String>[
    'cached_user',
    'notif_order_updates',
    'notif_promotions',
    'notif_new_arrivals',
  ];

  /// Erases every piece of user-owned data stored on this device: auth
  /// tokens (Keychain/Keystore), the cached profile, cart, wishlist,
  /// addresses, orders, recently-viewed and search history. Called only
  /// after the account itself has been deleted (or when signing out for
  /// deletion), never speculatively.
  Future<void> clearAll() async {
    await _secureStorage.clearTokens();

    await Future.wait<void>([
      HiveBoxes.cart.clear(),
      HiveBoxes.wishlist.clear(),
      HiveBoxes.recentlyViewed.clear(),
      HiveBoxes.searchHistory.clear(),
      HiveBoxes.addresses.clear(),
      HiveBoxes.orders.clear(),
    ]);

    final settings = HiveBoxes.settings;
    await settings.deleteAll(_userSettingsKeys.where(settings.containsKey));
  }
}
