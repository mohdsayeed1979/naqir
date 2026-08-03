import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naqirgiftbox/core/constants/app_dimens.dart';
import 'package:naqirgiftbox/core/localization/gen/app_localizations.dart';
import 'package:naqirgiftbox/features/notifications/presentation/providers/notification_preferences_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final prefs = ref.watch(notificationPreferencesProvider);
    final notifier = ref.read(notificationPreferencesProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileNotifications)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        children: [
          SwitchListTile(
            title: const Text('Order updates'),
            subtitle: const Text('Shipping and delivery status changes'),
            value: prefs.orderUpdates,
            onChanged: notifier.setOrderUpdates,
          ),
          SwitchListTile(
            title: const Text('Promotions & offers'),
            subtitle: const Text('Discounts, coupons, and seasonal campaigns'),
            value: prefs.promotions,
            onChanged: notifier.setPromotions,
          ),
          SwitchListTile(
            title: const Text('New arrivals'),
            subtitle: const Text('New gift boxes and collections'),
            value: prefs.newArrivals,
            onChanged: notifier.setNewArrivals,
          ),
        ],
      ),
    );
  }
}
