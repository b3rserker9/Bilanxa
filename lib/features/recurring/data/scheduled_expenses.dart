import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/config.dart';
import '../../../core/utils/money.dart';
import '../../auth/data/auth_repository.dart';
import '../../transactions/data/finance_repository.dart';
import '../../transactions/domain/models.dart';
import '../domain/scheduled_expense.dart';

final scheduledEnabledProvider = Provider<bool>(
  (ref) => Config.mockApi && Config.mocksAllowed,
);
final scheduledExpensesProvider =
    NotifierProvider<ScheduledExpensesController, ScheduledState>(
      ScheduledExpensesController.new,
    );

/// Local prototype, isolated per authenticated session like the existing mocks.
class ScheduledExpensesController extends Notifier<ScheduledState> {
  int _sequence = 0;
  int _generation = 0;
  @override
  ScheduledState build() {
    ref.watch(sessionProvider);
    _generation++;
    return const ScheduledState();
  }

  void _requireEnabled() {
    if (!ref.read(scheduledEnabledProvider)) {
      throw StateError('Scheduled expenses unavailable');
    }
  }

  String nextId() => 'scheduled-${++_sequence}';
  void save(ScheduledExpense expense) {
    _requireEnabled();
    expense.validate();
    if (state.pending.contains(expense.id)) return;
    state = ScheduledState(
      expenses: [...state.expenses.where((e) => e.id != expense.id), expense],
      history: state.history,
      pending: state.pending,
    );
  }

  void setStatus(String id, ScheduleStatus status) {
    _requireEnabled();
    if (state.pending.contains(id)) return;
    state = ScheduledState(
      expenses: state.expenses
          .map((e) => e.id == id ? e.copyWith(status: status) : e)
          .toList(),
      history: state.history,
      pending: state.pending,
    );
  }

  void skip(String id) {
    _requireEnabled();
    final expense = state.expenses.where((e) => e.id == id).firstOrNull;
    if (expense == null ||
        expense.status != ScheduleStatus.active ||
        state.pending.contains(id)) {
      return;
    }
    _resolve(expense, expense.amount, OccurrenceStatus.skipped, DateTime.now());
  }

  void undoSkip(String id, DateTime due) {
    final expense = state.expenses.where((e) => e.id == id).firstOrNull;
    final record = state.history.lastOrNull;
    if (expense == null ||
        record == null ||
        state.pending.contains(id) ||
        record.scheduleId != id ||
        record.due != due ||
        record.status != OccurrenceStatus.skipped ||
        expense.nextDue != expense.after(due)) {
      return;
    }
    state = ScheduledState(
      expenses: state.expenses
          .map((e) => e.id == id ? e.copyWith(nextDue: due) : e)
          .toList(),
      history: state.history.sublist(0, state.history.length - 1),
      pending: state.pending,
    );
  }

  void _resolve(
    ScheduledExpense expense,
    Money amount,
    OccurrenceStatus status,
    DateTime date,
  ) {
    state = ScheduledState(
      expenses: state.expenses
          .map(
            (e) => e.id == expense.id
                ? e.copyWith(nextDue: e.after(expense.nextDue))
                : e,
          )
          .toList(),
      history: [
        ...state.history,
        ExpenseOccurrence(
          scheduleId: expense.id,
          name: expense.name,
          due: expense.nextDue,
          amount: amount,
          status: status,
          date: dateOnly(date),
        ),
      ],
      pending: {...state.pending}..remove(expense.id),
    );
  }

  Future<void> pay(
    String id, {
    required DateTime due,
    required Money amount,
    required DateTime paidDate,
    required String accountId,
  }) async {
    _requireEnabled();
    final expense = state.expenses.where((e) => e.id == id).firstOrNull;
    if (expense == null ||
        expense.status != ScheduleStatus.active ||
        state.pending.contains(id) ||
        dateOnly(due) != dateOnly(expense.nextDue)) {
      return;
    }
    final movement = NewMovement(
      accountId: accountId,
      categoryId: expense.categoryId,
      type: MovementType.expense,
      amount: amount,
      description: expense.name,
      date: dateOnly(paidDate),
    );
    movement.validate();
    final generation = _generation;
    state = ScheduledState(
      expenses: state.expenses,
      history: state.history,
      pending: {...state.pending, id},
    );
    try {
      await ref.read(financeRepositoryProvider).createTransaction(movement);
      if (!ref.mounted || generation != _generation) return;
      _resolve(expense, amount, OccurrenceStatus.paid, paidDate);
      ref.invalidate(transactionsProvider);
      ref.invalidate(dashboardProvider);
      ref.invalidate(accountsProvider);
    } catch (_) {
      if (ref.mounted && generation == _generation) {
        state = ScheduledState(
          expenses: state.expenses,
          history: state.history,
          pending: {...state.pending}..remove(id),
        );
      }
      rethrow;
    }
  }
}
