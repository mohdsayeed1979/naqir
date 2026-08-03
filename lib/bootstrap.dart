import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naqirgiftbox/app.dart';
import 'package:naqirgiftbox/core/config/app_config.dart';
import 'package:naqirgiftbox/core/di/injector.dart';
import 'package:naqirgiftbox/core/storage/hive/hive_boxes.dart';
import 'package:naqirgiftbox/features/notifications/data/notification_service.dart';

/// Single entrypoint shared by `main.dart` (and any future flavor-specific
/// entrypoints) — initializes storage/DI, installs an error boundary, then
/// runs the app.
Future<void> bootstrap() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      await HiveBoxes.init();
      await configureDependencies();
      await _initializeFirebaseIfEnabled();

      // Crashlytics hook point: once AppConfig.firebaseEnabled is on (see
      // docs/ARCHITECTURE.md §9), report both error channels below to
      // FirebaseCrashlytics.instance.recordFlutterError /
      // .recordError here instead of just logging.
      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        debugPrint('FlutterError: ${details.exceptionAsString()}');
      };

      runApp(const ProviderScope(child: NaqirGiftBoxApp()));
    },
    (error, stackTrace) {
      debugPrint('Uncaught zone error: $error\n$stackTrace');
    },
  );
}

/// No-ops until `AppConfig.firebaseEnabled` is turned on *and* a real
/// Firebase project has been wired via `flutterfire configure` (see
/// docs/ARCHITECTURE.md §9) — safe to call unconditionally either way.
Future<void> _initializeFirebaseIfEnabled() async {
  final config = getIt<AppConfig>();
  if (!config.firebaseEnabled) return;

  try {
    await Firebase.initializeApp();
    await getIt<NotificationService>().initialize();
  } catch (error) {
    debugPrint('Firebase initialization failed, continuing without it: $error');
  }
}
