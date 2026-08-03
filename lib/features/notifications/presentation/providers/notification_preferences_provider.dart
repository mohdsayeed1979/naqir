import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:naqirgiftbox/core/storage/hive/hive_boxes.dart';

part 'notification_preferences_provider.freezed.dart';

@freezed
abstract class NotificationPreferences with _$NotificationPreferences {
  const factory NotificationPreferences({
    @Default(true) bool orderUpdates,
    @Default(true) bool promotions,
    @Default(false) bool newArrivals,
  }) = _NotificationPreferences;
}

class NotificationPreferencesNotifier
    extends Notifier<NotificationPreferences> {
  static const _orderUpdatesKey = 'notif_order_updates';
  static const _promotionsKey = 'notif_promotions';
  static const _newArrivalsKey = 'notif_new_arrivals';

  @override
  NotificationPreferences build() {
    final box = HiveBoxes.settings;
    return NotificationPreferences(
      orderUpdates: (box.get(_orderUpdatesKey) ?? 'true') == 'true',
      promotions: (box.get(_promotionsKey) ?? 'true') == 'true',
      newArrivals: (box.get(_newArrivalsKey) ?? 'false') == 'true',
    );
  }

  Future<void> setOrderUpdates(bool value) async {
    state = state.copyWith(orderUpdates: value);
    await HiveBoxes.settings.put(_orderUpdatesKey, value.toString());
  }

  Future<void> setPromotions(bool value) async {
    state = state.copyWith(promotions: value);
    await HiveBoxes.settings.put(_promotionsKey, value.toString());
  }

  Future<void> setNewArrivals(bool value) async {
    state = state.copyWith(newArrivals: value);
    await HiveBoxes.settings.put(_newArrivalsKey, value.toString());
  }
}

final notificationPreferencesProvider =
    NotifierProvider<NotificationPreferencesNotifier, NotificationPreferences>(
      NotificationPreferencesNotifier.new,
    );
