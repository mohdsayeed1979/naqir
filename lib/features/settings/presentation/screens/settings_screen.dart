import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:naqirgiftbox/core/constants/app_dimens.dart';
import 'package:naqirgiftbox/core/localization/gen/app_localizations.dart';
import 'package:naqirgiftbox/core/router/route_paths.dart';
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
        ],
      ),
    );
  }
}
