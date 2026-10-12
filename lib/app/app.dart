import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import 'router/router.dart';
import 'theme/theme.dart';

class BilanqoApp extends ConsumerWidget {
  const BilanqoApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp.router(
    title: 'Bilanqo',
    debugShowCheckedModeBanner: false,
    theme: Tokens.theme(Brightness.light),
    darkTheme: Tokens.theme(Brightness.dark),
    themeMode: ref.watch(themeProvider),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    routerConfig: ref.watch(routerProvider),
  );
}
