import 'package:bilanqo/app/app.dart';
import 'package:bilanqo/app/router/router.dart';
import 'package:bilanqo/features/auth/data/auth_repository.dart';
import 'package:bilanqo/features/recurring/data/scheduled_expenses.dart';
import 'package:bilanqo/features/transactions/data/finance_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fakes.dart';

void main() {
  testWidgets(
    'Create a variable bill, confirm actual payment and retain its history',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.localesTestValue = [const Locale('it')];
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);
      final auth = DemoAuthRepository();
      await auth.login('mario@example.com', 'password');
      final repo = DemoFinanceRepository();
      final container = ProviderContainer(
        retry: (_, _) => null,
        overrides: [
          authRepositoryProvider.overrideWithValue(auth),
          financeRepositoryProvider.overrideWithValue(repo),
          scheduledEnabledProvider.overrideWithValue(true),
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
      container.read(routerProvider).go('/transactions?tab=scheduled');
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.widgetWithText(ActionChip, 'Bolletta'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ActionChip, 'Bolletta'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).first, 'Luce casa');
      await tester.enterText(find.byType(TextFormField).last, '50,00');
      await tester.ensureVisible(find.text('Crea scadenza'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Crea scadenza'));
      await tester.pumpAndSettle();
      expect(
        container.read(scheduledExpensesProvider).expenses.single.variable,
        isTrue,
      );
      expect((await repo.transactions()).length, 2);
      await tester.ensureVisible(find.text('Segna come pagata'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Segna come pagata'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), '63,45');
      await tester.ensureVisible(
        find.widgetWithText(FilledButton, 'Conferma pagamento'),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Conferma pagamento'));
      await tester.pumpAndSettle();
      expect((await repo.transactions()).first.amount.decimal, '63.45');
      expect(
        container.read(scheduledExpensesProvider).history.single.name,
        'Luce casa',
      );
      await tester.ensureVisible(find.widgetWithText(ChoiceChip, 'Storico'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ChoiceChip, 'Storico'));
      await tester.pumpAndSettle();
      expect(find.text('Luce casa'), findsOneWidget);
      expect(find.text('€ 63,45'), findsOneWidget);
      tester.view.physicalSize = const Size(320, 700);
      tester.platformDispatcher.textScaleFactorTestValue = 1.8;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}
