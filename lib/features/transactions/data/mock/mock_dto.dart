import 'package:bilanqo/core/utils/money.dart';
import 'package:bilanqo/features/transactions/domain/models.dart';

/// Local mock wire format. Never used to parse real Spring Boot responses.
abstract final class MockDto {
  static Map<String, dynamic> object(Object? value) {
    if (value is! Map<String, dynamic>) {
      throw const FormatException('Expected object');
    }
    return value;
  }

  static String string(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! String || value.isEmpty) {
      throw FormatException('Invalid $key');
    }
    return value;
  }

  static List<T> list<T>(Object? value, T Function(Object?) parser) {
    if (value is! List) throw const FormatException('Expected array');
    return value.map(parser).toList(growable: false);
  }

  static Account account(Object? value) {
    final j = object(value);
    return Account(
      string(j, 'id'),
      string(j, 'name'),
      AccountType.values.byName(string(j, 'type')),
      Money.parse(string(j, 'balance')),
    );
  }

  static Category category(Object? value) {
    final j = object(value);
    return Category(
      string(j, 'id'),
      string(j, 'name'),
      MovementType.values.byName(string(j, 'type')),
    );
  }

  static Movement movement(Object? value) {
    final j = object(value);
    final rawDate = string(j, 'date');
    final date = DateTime.tryParse(rawDate);
    if (date == null ||
        !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(rawDate) ||
        dateString(date) != rawDate) {
      throw const FormatException('Invalid date');
    }
    final amount = Money.parse(string(j, 'amount'));
    if (amount.cents <= BigInt.zero) {
      throw const FormatException('Invalid amount');
    }
    return Movement(
      string(j, 'id'),
      string(j, 'accountId'),
      string(j, 'categoryId'),
      MovementType.values.byName(string(j, 'type')),
      amount,
      string(j, 'description'),
      date,
    );
  }

  static Dashboard dashboard(Object? value) {
    final j = object(value);
    return Dashboard(
      Money.parse(string(j, 'totalBalance')),
      Money.parse(string(j, 'monthlyIncome')),
      Money.parse(string(j, 'monthlyExpense')),
      Money.parse(string(j, 'remaining')),
      list(j['recentTransactions'], movement),
    );
  }

  static Profile profile(Object? value) {
    final j = object(value);
    return Profile(string(j, 'id'), string(j, 'email'), string(j, 'name'));
  }

  static String dateString(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  static Map<String, Object?> newMovement(NewMovement value) {
    value.validate();
    return {
      'accountId': value.accountId,
      'categoryId': value.categoryId,
      'type': value.type.name,
      'amount': value.amount.decimal,
      'description': value.description.trim(),
      'date': dateString(value.date),
    };
  }
}
