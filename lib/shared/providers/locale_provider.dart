import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naqirgiftbox/core/storage/hive/hive_boxes.dart';

const _localeKey = 'locale_code';
const supportedLocales = [Locale('en'), Locale('ar')];

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    final stored = HiveBoxes.settings.get(_localeKey);
    if (stored != null) {
      return supportedLocales.firstWhere(
        (locale) => locale.languageCode == stored,
        orElse: () => const Locale('en'),
      );
    }

    final deviceLanguageCode =
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    return supportedLocales.firstWhere(
      (locale) => locale.languageCode == deviceLanguageCode,
      orElse: () => const Locale('en'),
    );
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    await HiveBoxes.settings.put(_localeKey, locale.languageCode);
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);
