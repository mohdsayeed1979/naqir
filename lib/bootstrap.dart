import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naqirgiftbox/app.dart';
import 'package:naqirgiftbox/core/di/injector.dart';
import 'package:naqirgiftbox/core/storage/hive/hive_boxes.dart';

/// Single entrypoint shared by `main.dart` (and any future flavor-specific
/// entrypoints) — initializes storage/DI, installs an error boundary, then
/// runs the app.
Future<void> bootstrap() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      await HiveBoxes.init();
      await configureDependencies();

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
