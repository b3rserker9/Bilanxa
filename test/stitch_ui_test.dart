import 'package:bilanqo/app/app.dart';
import 'package:bilanqo/app/router/router.dart';
import 'package:bilanqo/features/auth/data/auth_repository.dart';
import 'package:bilanqo/features/transactions/data/finance_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fakes.dart';

void main() {
  testWidgets(
    'Transaction search, type filters, month and detail use repository data',
    (tester) async {
      tester.view.physicalSize = const Size(390, 1000);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.localesTestValue = [const Locale('it')];
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);
      final auth = DemoAuthRepository();
      await auth.login('mario@example.com', 'password');
      final container = ProviderContainer(
        retry: (_, _) => null,
        overrides: [
          authRepositoryProvider.overrideWithValue(auth),
          financeRepositoryProvider.overrideWithValue(DemoFinanceRepository()),
        ],
      );
      addTearDown(() {
        container.dispose();
        auth.dispose();
      });
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const BilanqoApp(),
        ),
      );
      await tester.pumpAndSettle();
      container.read(routerProvider).go('/transactions');
      await tester.pumpAndSettle();
      expect(find.text('Spesa al supermercato'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'stipendio');
      await tester.pumpAndSettle();
      expect(find.text('Spesa al supermercato'), findsNothing);
      await tester.tap(find.byTooltip('Cancella ricerca'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ChoiceChip, 'Le tue spese'));
      await tester.pumpAndSettle();
      expect(find.text('Stipendio'), findsNothing);
      await tester.ensureVisible(find.text('Spesa al supermercato'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Spesa al supermercato'));
      await tester.pumpAndSettle();
      expect(find.text('Dettaglio operazione'), findsOneWidget);
      expect(find.text('Conto personale'), findsOneWidget);
      await tester.tap(find.text('Chiudi'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byTooltip('Mese precedente'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Mese precedente'));
      await tester.pumpAndSettle();
      expect(find.text('Nessun movimento trovato'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Onboarding advances through three slides and opens registration',
    (tester) async {
      tester.platformDispatcher.localesTestValue = [const Locale('it')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);
      final auth = DemoAuthRepository();
      final container = ProviderContainer(
        retry: (_, _) => null,
        overrides: [authRepositoryProvider.overrideWithValue(auth)],
      );
      addTearDown(() {
        container.dispose();
        auth.dispose();
      });
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const BilanqoApp(),
        ),
      );
      await tester.pumpAndSettle();
      container.read(routerProvider).go('/onboarding');
      await tester.pumpAndSettle();
      for (var i = 0; i < 2; i++) {
        await tester.ensureVisible(find.text('Continua'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Continua'));
        await tester.pumpAndSettle();
      }
      expect(find.text('Trova il tuo equilibrio finanziario'), findsOneWidget);
      await tester.ensureVisible(find.text('Inizia subito'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Inizia subito'));
      await tester.pumpAndSettle();
      expect(
        container.read(routerProvider).routeInformationProvider.value.uri.path,
        '/register',
      );
      expect(tester.takeException(), isNull);
    },
  );
}
