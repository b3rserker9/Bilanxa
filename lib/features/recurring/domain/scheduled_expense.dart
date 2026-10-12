import '../../../core/utils/money.dart';

enum ScheduleStatus { active, paused, ended }

enum OccurrenceStatus { paid, skipped }

DateTime dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

class ScheduledExpense {
  const ScheduledExpense({
    required this.id,
    required this.name,
    required this.amount,
    required this.variable,
    required this.intervalMonths,
    required this.nextDue,
    required this.anchorDay,
    required this.accountId,
    required this.categoryId,
    this.status = ScheduleStatus.active,
  });
  final String id, name, accountId, categoryId;
  final Money amount;
  final bool variable;
  final int intervalMonths, anchorDay;
  final DateTime nextDue;
  final ScheduleStatus status;

  DateTime after(DateTime due) {
    final target = DateTime(due.year, due.month + intervalMonths);
    final lastDay = DateTime(target.year, target.month + 1, 0).day;
    return DateTime(target.year, target.month, anchorDay.clamp(1, lastDay));
  }

  Iterable<DateTime> datesIn(DateTime month) sync* {
    if (status != ScheduleStatus.active) return;
    final start = DateTime(month.year, month.month);
    final end = DateTime(month.year, month.month + 1);
    var due = nextDue;
    // Jump by months, preserving the original day (31 → Feb 28 → Mar 31).
    final diff = (start.year - due.year) * 12 + start.month - due.month;
    if (diff > intervalMonths) {
      final jump = (diff ~/ intervalMonths) * intervalMonths;
      final target = DateTime(due.year, due.month + jump);
      due = DateTime(
        target.year,
        target.month,
        anchorDay.clamp(1, DateTime(target.year, target.month + 1, 0).day),
      );
    }
    while (due.isBefore(end)) {
      if (!due.isBefore(start)) yield due;
      due = after(due);
    }
  }

  ScheduledExpense copyWith({DateTime? nextDue, ScheduleStatus? status}) =>
      ScheduledExpense(
        id: id,
        name: name,
        amount: amount,
        variable: variable,
        intervalMonths: intervalMonths,
        nextDue: nextDue ?? this.nextDue,
        anchorDay: anchorDay,
        accountId: accountId,
        categoryId: categoryId,
        status: status ?? this.status,
      );

  void validate() {
    if (name.trim().isEmpty ||
        name.length > 80 ||
        amount.cents <= BigInt.zero ||
        ![1, 2, 3, 12].contains(intervalMonths) ||
        anchorDay < 1 ||
        anchorDay > 31 ||
        accountId.isEmpty ||
        categoryId.isEmpty) {
      throw const FormatException('Invalid schedule');
    }
  }
}

class ExpenseOccurrence {
  const ExpenseOccurrence({
    required this.scheduleId,
    required this.name,
    required this.due,
    required this.amount,
    required this.status,
    required this.date,
  });
  final String scheduleId, name;
  final DateTime due, date;
  final Money amount;
  final OccurrenceStatus status;
}

class ScheduledState {
  const ScheduledState({
    this.expenses = const [],
    this.history = const [],
    this.pending = const {},
  });
  final List<ScheduledExpense> expenses;
  final List<ExpenseOccurrence> history;
  final Set<String> pending;

  Money expectedIn(DateTime month) => Money(
    expenses.fold<BigInt>(
      BigInt.zero,
      (sum, expense) =>
          sum +
          expense.amount.cents * BigInt.from(expense.datesIn(month).length),
    ),
  );
  Money paidIn(DateTime month) => Money(
    history
        .where(
          (o) =>
              o.status == OccurrenceStatus.paid &&
              o.due.year == month.year &&
              o.due.month == month.month,
        )
        .fold<BigInt>(BigInt.zero, (sum, o) => sum + o.amount.cents),
  );
}
