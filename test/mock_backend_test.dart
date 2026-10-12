import 'package:flutter_test/flutter_test.dart';
import 'package:bilanqo/core/network/api_client.dart';
import 'package:bilanqo/core/error/app_exception.dart';
import 'package:bilanqo/core/utils/money.dart';
import 'package:bilanqo/features/auth/data/mock_auth_repository.dart';
import 'package:bilanqo/features/transactions/data/dto.dart';
import 'package:bilanqo/features/transactions/data/finance_repository.dart';
import 'package:bilanqo/features/transactions/data/mock/mock_backend.dart';
import 'package:bilanqo/features/transactions/data/mock/mock_contract.dart';
import 'package:bilanqo/features/transactions/domain/models.dart';

void main() {
  test('Decimal DTO rejects JSON numbers and retains precision', () {
    expect(Dto.money('9007199254740993.01').decimal, '9007199254740993.01');
    expect(() => Dto.money(12.3), throwsFormatException);
    expect(() => Dto.money(null), throwsFormatException);
  });

  test(
    'Mock HTTP creates accounts and movements and updates aggregates',
    () async {
      final auth = MockAuthRepository();
      await auth.login('mario@example.com', 'password');
      final client = ApiClient(
        'https://mock.bilanqo.invalid',
        auth,
        adapter: MockBackendAdapter(email: 'mario@example.com'),
      );
      addTearDown(auth.dispose);
      addTearDown(client.close);
      final repository = HttpFinanceRepository(
        client,
        const MockFinanceApiContract(),
      );
      expect((await repository.profile()).email, 'mario@example.com');
      expect((await repository.categories()).length, 3);
      final before = await repository.dashboard();
      await repository.createAccount(
        'Contanti',
        AccountType.cash,
        Money.parse('20.00'),
      );
      final accounts = await repository.accounts();
      final account = accounts.last;
      expect(account.name, 'Contanti');
      await repository.createTransaction(
        NewMovement(
          accountId: account.id,
          categoryId: 'c2',
          type: MovementType.expense,
          amount: Money.parse('4.25'),
          description: 'Caffè',
          date: DateTime.now(),
        ),
      );
      expect((await repository.transactions()).first.description, 'Caffè');
      expect((await repository.accounts()).last.balance.decimal, '15.75');
      final after = await repository.dashboard();
      expect(after.total.cents, before.total.cents + BigInt.from(1575));
      expect(after.expense.cents, before.expense.cents + BigInt.from(425));
      expect(after.remaining.cents, before.remaining.cents - BigInt.from(425));
    },
  );

  test('Mock rejects a mismatched category and changes no data', () async {
    final auth = MockAuthRepository();
    await auth.login('mario@example.com', 'password');
    final client = ApiClient(
      'https://mock.bilanqo.invalid',
      auth,
      adapter: MockBackendAdapter(),
    );
    addTearDown(auth.dispose);
    addTearDown(client.close);
    final repository = HttpFinanceRepository(
      client,
      const MockFinanceApiContract(),
    );
    await expectLater(
      repository.createTransaction(
        NewMovement(
          accountId: 'a1',
          categoryId: 'c1',
          type: MovementType.expense,
          amount: Money.parse('4.25'),
          description: 'Caffè',
          date: DateTime.now(),
        ),
      ),
      throwsA(
        isA<AppException>().having((e) => e.kind, 'kind', Failure.validation),
      ),
    );
    expect((await repository.transactions()).length, 2);
  });
}
