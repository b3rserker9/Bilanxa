import 'support/fakes.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:bilanqo/core/utils/validators.dart';
import 'package:bilanqo/core/utils/money.dart';

import 'support/fixture_dto.dart';

import 'package:bilanqo/features/transactions/domain/models.dart';
import 'package:bilanqo/app/router/router.dart';

void main() {
  test('Login and registration validation', () {
    expect(Validators.email('mario@example.com'), true);
    expect(Validators.email('mario@'), false);
    expect(Validators.password(''), false);
    expect(Validators.password('short'), true);
    expect(Validators.registrationPassword('short'), false);
  });
  test('Exact decimal parsing, no double', () {
    expect(Money.parse('9007199254740993.01').decimal, '9007199254740993.01');
    expect(Money.parse('0.1').decimal, '0.10');
    expect(Money.parse('-42.50').format('it'), '−42,50 €');
    expect(() => Money.parse('1.001'), throwsFormatException);
    expect(() => Money.parse('1e2'), throwsFormatException);
  });
  test('DTO validates provisional schema and rejects numeric money', () {
    final json = {
      'id': 'a1',
      'name': 'Main',
      'type': 'bank',
      'balance': '10.25',
    };
    expect(MockDto.account(json).balance.decimal, '10.25');
    expect(
      () => MockDto.account({...json, 'balance': 10.25}),
      throwsFormatException,
    );
    expect(() => MockDto.account({'id': 'a1'}), throwsFormatException);
  });
  test('Protect private routes and retain public auth routes', () {
    expect(
      authRedirect(path: '/home', loading: true, signedIn: false),
      '/splash',
    );
    for (final path in [
      '/home',
      '/accounts',
      '/transactions/new',
      '/profile',
      '/budgets',
      '/groups',
    ]) {
      expect(
        authRedirect(path: path, loading: false, signedIn: false),
        '/login',
      );
    }
    expect(
      authRedirect(path: '/register', loading: false, signedIn: false),
      null,
    );
    expect(
      authRedirect(path: '/login', loading: false, signedIn: true),
      '/home',
    );
  });
  test('Demo authentication emits session and logout', () async {
    final auth = DemoAuthRepository();
    final sessions = <String?>[];
    final subscription = auth.watch().listen((u) => sessions.add(u?.email));
    await Future<void>.delayed(Duration.zero);
    await auth.login('mario@example.com', 'password');
    await Future<void>.delayed(Duration.zero);
    await auth.logout();
    await Future<void>.delayed(Duration.zero);
    expect(sessions, [null, 'mario@example.com', null]);
    await subscription.cancel();
    auth.dispose();
  });
  test('Create movement with valid linked account/category', () async {
    final repo = DemoFinanceRepository();
    final movement = NewMovement(
      accountId: 'a1',
      categoryId: 'c2',
      type: MovementType.expense,
      amount: Money.parse('19.99'),
      description: 'Lunch',
      date: DateTime(2026, 10, 10),
    );
    expect(MockDto.newMovement(movement)['amount'], '19.99');
    expect(MockDto.newMovement(movement)['date'], '2026-10-10');
    await repo.createTransaction(movement);
    expect((await repo.transactions()).first.description, 'Lunch');
    expect(
      () => NewMovement(
        accountId: 'a1',
        categoryId: 'c2',
        type: MovementType.expense,
        amount: Money.parse('0'),
        description: 'Lunch',
        date: DateTime.now(),
      ).validate(),
      throwsFormatException,
    );
  });
}
