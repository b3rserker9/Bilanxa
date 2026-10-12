import 'package:bilanqo/core/widgets/dropdown.dart';
import 'package:bilanqo/core/utils/money.dart';
import 'package:bilanqo/features/recurring/domain/scheduled_expense.dart';
import 'package:bilanqo/features/recurring/data/scheduled_expenses.dart';

import 'dart:async';

import 'package:bilanqo/features/transactions/data/finance_repository.dart';

// Generate real Flutter UI previews: flutter test tools/preview_test.dart
// --dart-define-from-file=config/local.json
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bilanqo/app/app.dart';
import 'package:bilanqo/app/theme/theme.dart';
import 'package:bilanqo/app/router/router.dart';
import 'package:bilanqo/features/auth/data/auth_repository.dart';

void main() {
  testWidgets('Render light and dark demo from app widgets', (tester) async {
    debugDisableShadows = false;
    addTearDown(() => debugDisableShadows = true);
    const sdk = String.fromEnvironment('FLUTTER_SDK');
    if (sdk.isEmpty) {
      throw StateError('Supply --dart-define=FLUTTER_SDK=/path/to/flutter');
    }
    await tester.runAsync(() async {
      final fontRoot = '$sdk/bin/cache/artifacts/material_fonts';
      final text = FontLoader('Roboto');
      for (final name in ['regular', 'medium', 'bold']) {
        text.addFont(
          File('$fontRoot/roboto-$name.ttf')
              .readAsBytes()
              .then((bytes) => ByteData.sublistView(bytes)),
        );
      }
      await text.load();
      final icons = FontLoader('MaterialIcons');
      icons.addFont(
        File('$fontRoot/materialicons-regular.otf')
            .readAsBytes()
            .then((bytes) => ByteData.sublistView(bytes)),
      );
      await icons.load();
      for (final family in ['Inter', 'PlusJakartaSans']) {
        final font = FontLoader(
          family == 'Inter' ? 'Inter' : 'Plus Jakarta Sans',
        );
        font.addFont(
          File('assets/fonts/$family.ttf')
              .readAsBytes()
              .then((bytes) => ByteData.sublistView(bytes)),
        );
        await font.load();
      }
    });
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.localesTestValue = [const Locale('it')];
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    final container = ProviderContainer(retry: (_, _) => null);
    addTearDown(container.dispose);
    final key = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: key,
        child: UncontrolledProviderScope(
          container: container,
          child: const BilanqoApp(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    Future<void> capture(String name) async {
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final picture = await boundary.toImage(pixelRatio: 2);
        final bytes = await picture.toByteData(format: ui.ImageByteFormat.png);
        await Directory('docs/previews').create(recursive: true);
        await File('docs/previews/$name.png')
            .writeAsBytes(bytes!.buffer.asUint8List());
        picture.dispose();
      });
    }

    await capture('login');
    container.read(routerProvider).go('/onboarding');
    await tester.pumpAndSettle();
    await capture('onboarding');
    container.read(routerProvider).go('/login');
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      final signedIn = Completer<void>();
      final subscription = container.listen(sessionProvider, (_, next) {
        if (next.asData?.value != null && !signedIn.isCompleted) {
          signedIn.complete();
        }
      });
      await container
          .read(authRepositoryProvider)
          .login('prova@example.com', 'password');
      await signedIn.future;
      subscription.close();
      await container.read(dashboardProvider.future);
    });
    await tester.pumpAndSettle();
    await capture('home-light');
    container.read(routerProvider).go('/transactions');
    await tester.runAsync(() => container.read(transactionsProvider.future));
    await tester.pumpAndSettle();
    await capture('transactions');
    container.read(routerProvider).go('/transactions/new');
    await tester.pumpAndSettle();
    await capture('new-movement');
    final accountDropdown = find.byType(BilanqoDropdown<String>).first;
    await tester.ensureVisible(accountDropdown);
    await tester.pumpAndSettle();
    await tester.tap(accountDropdown);
    await tester.pumpAndSettle();
    await capture('account-dropdown');
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    container.read(routerProvider).go('/accounts');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Crea un conto'));
    await tester.pumpAndSettle();
    await capture('new-account');
    await tester.tap(
      find.byWidgetPredicate((widget) => widget is BilanqoDropdown).first,
    );
    await tester.pumpAndSettle();
    await capture('account-type-dropdown');
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    container.read(routerProvider).pop();
    await tester.pumpAndSettle();
    final now = DateTime.now();
    final schedules = container.read(scheduledExpensesProvider.notifier);
    for (final sample in [
      ('Netflix', '12.99', false, 3),
      ('Luce casa', '65.00', true, 6),
      ('Affitto', '600.00', false, -2),
    ]) {
      final due = DateTime(now.year, now.month, now.day + sample.$4);
      schedules.save(
        ScheduledExpense(
          id: schedules.nextId(),
          name: sample.$1,
          amount: Money.parse(sample.$2),
          variable: sample.$3,
          intervalMonths: 1,
          nextDue: due,
          anchorDay: due.day,
          accountId: 'a1',
          categoryId: 'c2',
        ),
      );
    }
    container.read(routerProvider).go('/home');
    await tester.pumpAndSettle();
    await capture('home-scheduled');
    container.read(routerProvider).go('/transactions?tab=scheduled');
    await tester.pumpAndSettle();
    await capture('scheduled-expenses');
    await tester.ensureVisible(find.text('Aggiungi spesa fissa'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Aggiungi spesa fissa'));
    await tester.pumpAndSettle();
    await capture('scheduled-editor');
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    container.read(routerProvider).go('/home');
    await tester.pumpAndSettle();
    container.read(themeProvider.notifier).set(ThemeMode.dark);
    await tester.pumpAndSettle();
    await capture('home-dark');
    debugDisableShadows = true;
    expect(tester.takeException(), isNull);
  });
}
