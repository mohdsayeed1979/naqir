import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naqirgiftbox/core/localization/gen/app_localizations.dart';
import 'package:naqirgiftbox/core/router/app_router.dart';
import 'package:naqirgiftbox/core/theme/app_theme.dart';
import 'package:naqirgiftbox/shared/providers/locale_provider.dart';
import 'package:naqirgiftbox/shared/providers/theme_mode_provider.dart';

class NaqirGiftBoxApp extends ConsumerWidget {
  const NaqirGiftBoxApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'Naqir Gift Box',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      themeMode: themeMode,
      theme: AppTheme.light(locale.languageCode),
      darkTheme: AppTheme.dark(locale.languageCode),
      locale: locale,
      supportedLocales: supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
    );
  }
}
