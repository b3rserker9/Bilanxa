import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/app_exception.dart';
import '../../../core/utils/money.dart';
import '../domain/models.dart';
import 'mock/mock_contract.dart';
import '../../../core/config/config.dart';

/// Map the documented backend schema into presentation/domain models here.
/// A concrete adapter requires the actual Spring Boot docs/api-contract.md.
abstract interface class FinanceApiContract {
  Dashboard dashboard(Object? json);
  List<Account> accounts(Object? json);
  List<Category> categories(Object? json);
  List<Movement> transactions(Object? json);
  Profile profile(Object? json);
  Map<String, Object?> newAccount(String name, AccountType type, Money balance);
  Map<String, Object?> newMovement(NewMovement movement);
}

// Fail explicitly before any financial request rather than assume field names,
// enum casing, response envelopes, currencies, or pagination.
final financeApiContractProvider = Provider<FinanceApiContract>(
  (ref) => Config.mockApi && Config.mocksAllowed
      ? const MockFinanceApiContract()
      : throw const AppException(Failure.configuration),
);

abstract final class Dto {
  /// The only monetary wire representation specified so far is a string.
  static Money money(Object? value) {
    if (value is! String) {
      throw const FormatException('Expected decimal string');
    }
    return Money.parse(value);
  }
}
