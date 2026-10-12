import 'package:bilanqo/core/widgets/dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bilanqo/app/app.dart';
import 'package:bilanqo/app/router/router.dart';
import 'package:bilanqo/features/auth/data/auth_repository.dart';
import 'package:bilanqo/features/transactions/data/finance_repository.dart';

import 'support/fakes.dart';

void main() {
  testWidgets('Transaction form validates, saves and returns to list', (
    tester,
  ) async {
    tester.platformDispatcher.localesTestValue = [const Locale('it')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    final auth = DemoAuthRepository();
    await auth.login('mario@example.com', 'password');
    final repository = DemoFinanceRepository();
    final container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        authRepositoryProvider.overrideWithValue(auth),
        financeRepositoryProvider.overrideWithValue(repository),
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
    container.read(routerProvider).go('/transactions/new');
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Salva'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salva'));
    await tester.pumpAndSettle();
    expect(find.text('Questo campo è obbligatorio'), findsWidgets);
    final category = find.byType(BilanqoDropdown<String>).last;
    await tester.ensureVisible(category);
    await tester.pumpAndSettle();
    await tester.tap(category);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Spesa').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, '12,30');
    await tester.enterText(find.byType(TextFormField).last, 'Pranzo di prova');
    await tester.ensureVisible(find.text('Salva'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salva'));
    await tester.pumpAndSettle();
    expect(
      container.read(routerProvider).routeInformationProvider.value.uri.path,
      '/transactions',
    );
    expect(find.text('Pranzo di prova'), findsOneWidget);
    expect((await repository.transactions()).first.amount.decimal, '12.30');
    expect(tester.takeException(), isNull);
  });
}
