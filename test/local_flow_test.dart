import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bilanqo/app/app.dart';
import 'package:bilanqo/app/router/router.dart';
import 'package:bilanqo/core/config/config.dart';
import 'package:bilanqo/core/utils/money.dart';
import 'package:bilanqo/features/auth/data/auth_repository.dart';
import 'package:bilanqo/features/transactions/data/finance_repository.dart';
import 'package:bilanqo/features/transactions/domain/models.dart';

void main() {
  testWidgets('Local configuration uses HTTP mocks and resets each session', (
    tester,
  ) async {
    tester.platformDispatcher.localesTestValue = [const Locale('it')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    final container = ProviderContainer(retry: (_, _) => null);
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const BilanqoApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Accedi'), findsOneWidget);

    Future<void> signIn(String email) async {
      final signedIn = Completer<void>();
      final subscription = container.listen(sessionProvider, (_, next) {
        if (next.asData?.value?.email == email && !signedIn.isCompleted) {
          signedIn.complete();
        }
      });
      await container.read(authRepositoryProvider).login(email, 'password');
      await signedIn.future;
      subscription.close();
      await container.read(dashboardProvider.future);
    }

    await tester.runAsync(() => signIn('mario@example.com'));
    await tester.pumpAndSettle();
    expect(find.text('Saldo totale'), findsOneWidget);
    expect(
      find.text('MODALITÀ PROVA · Dati simulati, modifiche temporanee'),
      findsWidgets,
    );
    await tester.runAsync(() async {
      await container
          .read(financeRepositoryProvider)
          .createAccount(
            'Prova temporanea',
            AccountType.cash,
            Money.parse('10'),
          );
      expect(
        (await container.read(financeRepositoryProvider).accounts()).length,
        3,
      );
    });
    await container.read(authRepositoryProvider).logout();
    await tester.pumpAndSettle();
    expect(
      container.read(routerProvider).routeInformationProvider.value.uri.path,
      '/login',
    );
    await tester.runAsync(() => signIn('anna@example.com'));
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      expect(
        (await container.read(financeRepositoryProvider).accounts()).length,
        2,
      );
      expect(
        (await container.read(financeRepositoryProvider).profile()).email,
        'anna@example.com',
      );
    });
    expect(tester.takeException(), isNull);
  }, skip: !(Config.mockApi && Config.mockAuth && Config.mocksAllowed));
}
