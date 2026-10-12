import 'package:bilanqo/core/utils/money.dart';
import 'package:bilanqo/features/transactions/data/dto.dart';
import 'package:bilanqo/features/transactions/domain/models.dart';

import 'mock_dto.dart';

/// Synthetic local API schema. Not an adapter for the real backend.
class MockFinanceApiContract implements FinanceApiContract {
  const MockFinanceApiContract();
  @override
  Dashboard dashboard(Object? json) => MockDto.dashboard(json);
  @override
  List<Account> accounts(Object? json) => MockDto.list(json, MockDto.account);
  @override
  List<Category> categories(Object? json) =>
      MockDto.list(json, MockDto.category);
  @override
  List<Movement> transactions(Object? json) =>
      MockDto.list(json, MockDto.movement);
  @override
  Profile profile(Object? json) => MockDto.profile(json);
  @override
  Map<String, Object?> newAccount(
    String name,
    AccountType type,
    Money balance,
  ) => {'name': name, 'type': type.name, 'initialBalance': balance.decimal};
  @override
  Map<String, Object?> newMovement(NewMovement movement) =>
      MockDto.newMovement(movement);
}
