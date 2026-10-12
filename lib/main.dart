import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/app.dart';
import 'core/config/config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('it');
  await initializeDateFormatting('en');
  String? setupError;
  if (Config.mockConfigurationInvalid) {
    setupError = 'configuration';
  } else if (!Config.mockAuth) {
    try {
      // FlutterFire installs native configuration. The helper enables Dart options.
      await Firebase.initializeApp();
    } catch (_) {
      // Never log configuration details or fall back to a fake session.
      setupError = 'firebase';
    }
  }
  runApp(
    ProviderScope(
      retry: (_, _) => null,
      overrides: [setupErrorProvider.overrideWithValue(setupError)],
      child: const BilanqoApp(),
    ),
  );
}
