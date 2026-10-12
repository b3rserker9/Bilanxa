import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bilanqo/app/app.dart';
import 'package:bilanqo/core/config/config.dart';

void main() {
  testWidgets('Missing Firebase shows sign-in without fake access', (
    tester,
  ) async {
    tester.platformDispatcher.localesTestValue = [const Locale('it')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [setupErrorProvider.overrideWithValue('firebase')],
        child: const BilanqoApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Accedi'), findsOneWidget);
    expect(
      find.text('Il servizio di accesso non è ancora disponibile.'),
      findsOneWidget,
    );
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    expect(find.text('Saldo totale'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
