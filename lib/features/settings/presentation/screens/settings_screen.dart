import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:naqirgiftbox/core/constants/app_dimens.dart';
import 'package:naqirgiftbox/core/localization/gen/app_localizations.dart';
import 'package:naqirgiftbox/core/router/route_paths.dart';
import 'package:naqirgiftbox/features/authentication/presentation/providers/auth_providers.dart';
import 'package:naqirgiftbox/features/cart/presentation/providers/cart_providers.dart';
import 'package:naqirgiftbox/features/checkout/presentation/providers/address_providers.dart';
import 'package:naqirgiftbox/features/notifications/presentation/providers/notification_preferences_provider.dart';
import 'package:naqirgiftbox/features/orders/presentation/providers/orders_providers.dart';
import 'package:naqirgiftbox/features/products/presentation/providers/recently_viewed_providers.dart';
import 'package:naqirgiftbox/features/wishlist/presentation/providers/wishlist_providers.dart';
import 'package:naqirgiftbox/shared/providers/locale_provider.dart';
import 'package:naqirgiftbox/shared/providers/theme_mode_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final isSignedIn = ref.watch(authProvider).valueOrNull != null;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Text(l10n.settingsDarkMode, style: theme.textTheme.titleSmall),
          const SizedBox(height: AppSpacing.xs),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(
                value: ThemeMode.system,
                icon: Icon(Icons.brightness_auto_rounded),
                label: Text('System'),
              ),
              ButtonSegment(
                value: ThemeMode.light,
                icon: Icon(Icons.light_mode_outlined),
                label: Text('Light'),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                icon: Icon(Icons.dark_mode_outlined),
                label: Text('Dark'),
              ),
            ],
            selected: {themeMode},
            onSelectionChanged: (selection) => ref
                .read(themeModeProvider.notifier)
                .setThemeMode(selection.first),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(l10n.settingsLanguage, style: theme.textTheme.titleSmall),
          const SizedBox(height: AppSpacing.xs),
          SegmentedButton<Locale>(
            segments: [
              ButtonSegment(
                value: const Locale('en'),
                label: Text(l10n.settingsEnglish),
              ),
              ButtonSegment(
                value: const Locale('ar'),
                label: Text(l10n.settingsArabic),
              ),
            ],
            selected: {locale},
            onSelectionChanged: (selection) =>
                ref.read(localeProvider.notifier).setLocale(selection.first),
          ),
          const SizedBox(height: AppSpacing.lg),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.settingsNotificationPreferences),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push(RoutePaths.notifications),
          ),
          if (isSignedIn) ...[
            const SizedBox(height: AppSpacing.lg),
            const Divider(),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.settingsAccount,
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.delete_forever_outlined,
                color: theme.colorScheme.error,
              ),
              title: Text(
                l10n.settingsDeleteAccount,
                style: TextStyle(color: theme.colorScheme.error),
              ),
              trailing: Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.error,
              ),
              onTap: () => _confirmDeleteAccount(context, ref),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmDeleteAccount(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteAccountWarningTitle),
        content: Text(l10n.deleteAccountWarningBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.deleteAccountCancel),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.deleteAccountConfirm),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    // Capture messenger/router before awaiting, then show a blocking spinner
    // so the destructive call can't be triggered twice.
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final result = await ref.read(authProvider.notifier).deleteAccount();

    if (context.mounted) Navigator.of(context).pop(); // dismiss spinner

    result.when(
      success: (_) {
        // Drop any in-memory user state so nothing stale survives the wipe.
        ref.invalidate(cartProvider);
        ref.invalidate(wishlistProvider);
        ref.invalidate(ordersProvider);
        ref.invalidate(addressListProvider);
        ref.invalidate(recentlyViewedProvider);
        ref.invalidate(notificationPreferencesProvider);
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.deleteAccountSuccess)),
        );
        // Return to the signed-out guest experience.
        router.go(RoutePaths.home);
      },
      failure: (failure) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.deleteAccountError)),
        );
      },
    );
  }
}
