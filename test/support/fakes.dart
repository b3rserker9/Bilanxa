// In-memory fixtures for tests only. Never imported by the distributed app.
import 'dart:async';

import 'package:bilanqo/core/error/app_exception.dart';
import 'package:bilanqo/core/utils/money.dart';
import 'package:bilanqo/features/auth/domain/auth_repository.dart';
import 'package:bilanqo/features/transactions/domain/finance_repository.dart';
import 'package:bilanqo/features/transactions/domain/models.dart';

class DemoAuthRepository implements AuthRepository {
  final _changes = StreamController<SessionUser?>.broadcast();
  SessionUser? _user;
  @override
  Stream<SessionUser?> watch() async* {
    yield _user;
    yield* _changes.stream;
  }

  @override
  Future<void> login(String email, String password) async {
    _user = SessionUser('demo', email.trim());
    _changes.add(_user);
  }

  @override
  Future<void> register(String email, String password) =>
      login(email, password);
  @override
  Future<void> resetPassword(String email) async {}
  @override
  Future<void> logout() async {
    _user = null;
    _changes.add(null);
  }

  @override
  Future<String?> token({bool refresh = false}) async => null;
  void dispose() => _changes.close();
}

class DemoFinanceRepository implements FinanceRepository {
  DemoFinanceRepository({this.email = 'demo@example.com'});
  final String email;
  final _accounts = [
    Account('a1', 'Conto personale', AccountType.bank, Money.parse('2480.00')),
    Account('a2', 'Risparmi', AccountType.savings, Money.parse('1200.00')),
  ];
  final _categories = [
    const Category('c1', 'Stipendio', MovementType.income),
    const Category('c2', 'Spesa', MovementType.expense),
    const Category('c3', 'Tempo libero', MovementType.expense),
  ];
  final _movements = [
    Movement(
      't1',
      'a1',
      'c2',
      MovementType.expense,
      Money.parse('42.80'),
      'Spesa al supermercato',
      DateTime.now(),
    ),
    Movement(
      't2',
      'a1',
      'c1',
      MovementType.income,
      Money.parse('2100.00'),
      'Stipendio',
      DateTime.now(),
    ),
  ];
  int _sequence = 3;
  @override
  Future<Dashboard> dashboard() async => Dashboard(
    Money.parse('3680.00'),
    Money.parse('2100.00'),
    Money.parse('620.00'),
    Money.parse('1480.00'),
    List.unmodifiable(_movements.take(5)),
  );
  @override
  Future<List<Account>> accounts() async => List.unmodifiable(_accounts);
  @override
  Future<List<Category>> categories() async => List.unmodifiable(_categories);
  @override
  Future<List<Movement>> transactions() async => List.unmodifiable(_movements);
  @override
  Future<Profile> profile() async => Profile('demo', email, 'Utente demo');
  @override
  Future<void> createAccount(
    String name,
    AccountType type,
    Money initialBalance,
  ) async {
    if (name.trim().isEmpty) throw const AppException(Failure.validation);
    _accounts.add(
      Account('a${_sequence++}', name.trim(), type, initialBalance),
    );
  }

  @override
  Future<void> createTransaction(NewMovement movement) async {
    movement.validate();
    if (!_accounts.any((a) => a.id == movement.accountId) ||
        !_categories.any(
          (c) => c.id == movement.categoryId && c.type == movement.type,
        )) {
      throw const AppException(Failure.validation);
    }
    _movements.insert(
      0,
      Movement(
        't${_sequence++}',
        movement.accountId,
        movement.categoryId,
        movement.type,
        movement.amount,
        movement.description.trim(),
        movement.date,
      ),
    );
    // Dashboard totals are fixed sample values, deliberately not financial calculations.
  }
}
