import 'support/fakes.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bilanqo/app/theme/theme.dart';
import 'package:bilanqo/l10n/app_localizations.dart';
import 'package:bilanqo/core/error/app_exception.dart';
import 'package:bilanqo/core/utils/money.dart';
import 'package:bilanqo/features/transactions/domain/models.dart';
import 'package:bilanqo/features/transactions/data/finance_repository.dart';
import 'package:bilanqo/features/dashboard/presentation/dashboard_screen.dart';

void main() {
  Widget app(Future<Dashboard> Function() load, {double textScale = 1}) =>
      ProviderScope(
        retry: (_, _) => null,
        overrides: [dashboardProvider.overrideWith((ref) => load())],
        child: MaterialApp(
          theme: Tokens.theme(Brightness.light),
          locale: const Locale('it'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          ),
          home: const DashboardScreen(),
        ),
      );
  testWidgets('Dashboard loading, success and empty states', (tester) async {
    final pending = Completer<Dashboard>();
    await tester.pumpWidget(app(() => pending.future));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    pending.complete(
      Dashboard(
        Money.parse('10'),
        Money.parse('0'),
        Money.parse('0'),
        Money.parse('0'),
        [],
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Saldo totale'), findsOneWidget);
    expect(find.text('€ 10,00'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Aggiungi il tuo primo movimento per iniziare.'),
      200,
    );
    expect(
      find.text('Aggiungi il tuo primo movimento per iniziare.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets('Dashboard error and retry never invent balance', (tester) async {
    var calls = 0;
    await tester.pumpWidget(
      app(() {
        calls++;
        return Future.error(const AppException(Failure.network));
      }),
    );
    await tester.pumpAndSettle();
    expect(find.text('Saldo totale'), findsNothing);
    await tester.tap(find.text('Riprova'));
    await tester.pumpAndSettle();
    expect(calls, 2);
  });
  testWidgets('Narrow layout supports large text', (tester) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      app(() => DemoFinanceRepository().dashboard(), textScale: 1.8),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
