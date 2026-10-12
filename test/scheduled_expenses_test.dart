import 'dart:async';

import 'package:bilanqo/core/utils/money.dart';
import 'package:bilanqo/features/auth/data/auth_repository.dart';
import 'package:bilanqo/features/recurring/data/scheduled_expenses.dart';
import 'package:bilanqo/features/recurring/domain/scheduled_expense.dart';
import 'package:bilanqo/features/transactions/data/finance_repository.dart';
import 'package:bilanqo/features/transactions/domain/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fakes.dart';

ScheduledExpense fixture({DateTime? due, int months = 1}) => ScheduledExpense(
  id: 's1',
  name: 'Luce',
  amount: Money.parse('50'),
  variable: true,
  intervalMonths: months,
  nextDue: due ?? DateTime(2026, 1, 31),
  anchorDay: 31,
  accountId: 'a1',
  categoryId: 'c2',
);

class DelayedRepository extends DemoFinanceRepository {
  final gate = Completer<void>();
  int calls = 0;
  @override
  Future<void> createTransaction(NewMovement movement) async {
    calls++;
    await gate.future;
    await super.createTransaction(movement);
  }
}

void main() {
  test(
    'Monthly dates keep the original day across short months and leap years',
    () {
      final expense = fixture();
      final feb = expense.after(expense.nextDue);
      expect(feb, DateTime(2026, 2, 28));
      expect(expense.after(feb), DateTime(2026, 3, 31));
      expect(
        fixture(due: DateTime(2028, 1, 31)).after(DateTime(2028, 1, 31)),
        DateTime(2028, 2, 29),
      );
      expect(
        fixture(months: 2).after(DateTime(2026, 1, 31)),
        DateTime(2026, 3, 31),
      );
      expect(expense.datesIn(DateTime(2026, 3)).single, DateTime(2026, 3, 31));
    },
  );

  test('Paying is single-flight, records the actual amount, advances and prevents replay', () async {
    final auth = DemoAuthRepository();
    await auth.login('test@example.com', 'password');
    final repo = DelayedRepository();
    final container = ProviderContainer(
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
    container.listen(sessionProvider, (_, _) {});
    await container
        .read(sessionProvider.future)
        .timeout(const Duration(seconds: 3));
    container.listen(scheduledExpensesProvider, (_, _) {});
    final controller = container.read(scheduledExpensesProvider.notifier);
    final expense = fixture();
    controller.save(expense);
    expect((await repo.transactions()).length, 2);
    final payment = controller.pay(
      expense.id,
      due: expense.nextDue,
      amount: Money.parse('63.45'),
      paidDate: DateTime(2026, 2, 1),
      accountId: 'a1',
    );
    await controller.pay(
      expense.id,
      due: expense.nextDue,
      amount: Money.parse('63.45'),
      paidDate: DateTime(2026, 2, 1),
      accountId: 'a1',
    );
    expect(repo.calls, 1);
    repo.gate.complete();
    await payment;
    await controller.pay(
      expense.id,
      due: expense.nextDue,
      amount: Money.parse('63.45'),
      paidDate: DateTime(2026, 2, 1),
      accountId: 'a1',
    );
    expect(repo.calls, 1);
    final state = container.read(scheduledExpensesProvider);
    expect(state.expenses.single.nextDue, DateTime(2026, 2, 28));
    expect(state.history.single.amount.decimal, '63.45');
    expect(state.paidIn(DateTime(2026, 1)).decimal, '63.45');
    expect(state.expectedIn(DateTime(2026, 2)).decimal, '50.00');
    expect((await repo.transactions()).first.description, 'Luce');
    controller.setStatus(expense.id, ScheduleStatus.paused);
    expect(
      container
          .read(scheduledExpensesProvider)
          .expectedIn(DateTime(2026, 2))
          .decimal,
      '0.00',
    );
    controller.setStatus(expense.id, ScheduleStatus.active);
    controller.skip(expense.id);
    expect((await repo.transactions()).length, 3);
    expect(
      container.read(scheduledExpensesProvider).history.last.status,
      OccurrenceStatus.skipped,
    );
    expect(
      container.read(scheduledExpensesProvider).expenses.single.nextDue,
      DateTime(2026, 3, 31),
    );
    controller.setStatus(expense.id, ScheduleStatus.ended);
    expect(container.read(scheduledExpensesProvider).history.length, 2);
    controller.undoSkip(expense.id, DateTime(2026, 2, 28));
    expect(container.read(scheduledExpensesProvider).history.length, 1);
    expect(
      container.read(scheduledExpensesProvider).expenses.single.nextDue,
      DateTime(2026, 2, 28),
    );
    await auth.logout();
    await Future<void>.delayed(Duration.zero);
    expect(container.read(scheduledExpensesProvider).expenses, isEmpty);
  });

  test(
    'A failed payment does not advance the due date or mark it paid',
    () async {
      final repo = DelayedRepository();
      final container = ProviderContainer(
        overrides: [
          financeRepositoryProvider.overrideWithValue(repo),
          scheduledEnabledProvider.overrideWithValue(true),
          sessionProvider.overrideWith((ref) => Stream.value(null)),
        ],
      );
      addTearDown(container.dispose);
      container.listen(sessionProvider, (_, _) {});
      await container
          .read(sessionProvider.future)
          .timeout(const Duration(seconds: 3));
      final controller = container.read(scheduledExpensesProvider.notifier);
      final expense = fixture();
      controller.save(expense);
      final payment = controller.pay(
        's1',
        due: expense.nextDue,
        amount: Money.parse('10'),
        paidDate: DateTime(2026, 1, 31),
        accountId: 'a1',
      );
      final assertion = expectLater(payment, throwsStateError);
      repo.gate.completeError(StateError('Failed'));
      await assertion;
      final state = container.read(scheduledExpensesProvider);
      expect(state.expenses.single.nextDue, expense.nextDue);
      expect(state.history, isEmpty);
      expect(state.pending, isEmpty);
    },
  );
}
