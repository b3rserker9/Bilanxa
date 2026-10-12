import 'support/fakes.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bilanqo/app/app.dart';
import 'package:bilanqo/app/router/router.dart';
import 'package:bilanqo/features/auth/data/auth_repository.dart';
import 'package:bilanqo/features/transactions/data/finance_repository.dart';

void main() {
  testWidgets('Auth listener redirects private route, login and logout', (
    tester,
  ) async {
    tester.platformDispatcher.localesTestValue = [const Locale('it')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    final auth = DemoAuthRepository();
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(auth),
        financeRepositoryProvider.overrideWithValue(DemoFinanceRepository()),
      ],
      retry: (_, _) => null,
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
    container.read(routerProvider).go('/accounts');
    await tester.pumpAndSettle();
    expect(find.text('Accedi'), findsOneWidget);
    await tester.enterText(
      find.byType(TextFormField).first,
      'mario@example.com',
    );
    await tester.enterText(find.byType(TextFormField).last, 'password123');
    await tester.ensureVisible(find.text('Accedi'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Accedi'));
    await tester.pumpAndSettle();
    expect(find.text('Saldo totale'), findsOneWidget);
    container.read(routerProvider).go('/profile');
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Esci'));
    await tester.tap(find.text('Esci'));
    await tester.pumpAndSettle();
    expect(find.text('Accedi'), findsOneWidget);
    expect(
      container.read(routerProvider).routeInformationProvider.value.uri.path,
      '/login',
    );
  });
}
