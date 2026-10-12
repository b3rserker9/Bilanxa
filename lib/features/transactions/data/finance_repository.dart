import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/app_exception.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/money.dart';
import '../../auth/data/auth_repository.dart';
import '../domain/finance_repository.dart';
import '../domain/models.dart';
import 'dto.dart';

class HttpFinanceRepository implements FinanceRepository {
  HttpFinanceRepository(this.client, this.contract);
  final ApiClient client;
  final FinanceApiContract contract;
  Future<T> _parse<T>(
    Future<Object?> response,
    T Function(Object?) parser,
  ) async {
    final value = await response;
    try {
      return parser(value);
    } on FormatException {
      throw const AppException(Failure.contract);
    } on ArgumentError {
      throw const AppException(Failure.contract);
    }
  }

  @override
  Future<Dashboard> dashboard() =>
      _parse(client.get('/api/v1/dashboard'), contract.dashboard);
  @override
  Future<List<Account>> accounts() =>
      _parse(client.get('/api/v1/accounts'), contract.accounts);
  @override
  Future<List<Category>> categories() =>
      _parse(client.get('/api/v1/categories'), contract.categories);
  @override
  Future<List<Movement>> transactions() =>
      _parse(client.get('/api/v1/transactions'), contract.transactions);
  @override
  Future<Profile> profile() =>
      _parse(client.get('/api/v1/me'), contract.profile);
  @override
  Future<void> createAccount(
    String name,
    AccountType type,
    Money initialBalance,
  ) async {
    if (name.trim().isEmpty) throw const AppException(Failure.validation);
    await client.post(
      '/api/v1/accounts',
      contract.newAccount(name.trim(), type, initialBalance),
    );
  }

  @override
  Future<void> createTransaction(NewMovement movement) async {
    await client.post('/api/v1/transactions', contract.newMovement(movement));
  }
}

final financeRepositoryProvider = Provider<FinanceRepository>((ref) {
  final session = ref.watch(sessionProvider).asData?.value;
  if (session == null) throw const AppException(Failure.unauthorized);
  final contract = ref.watch(financeApiContractProvider);
  return HttpFinanceRepository(ref.watch(apiClientProvider), contract);
});
final dashboardProvider = FutureProvider<Dashboard>(
  (ref) => ref.watch(financeRepositoryProvider).dashboard(),
);
final accountsProvider = FutureProvider<List<Account>>(
  (ref) => ref.watch(financeRepositoryProvider).accounts(),
);
final categoriesProvider = FutureProvider<List<Category>>(
  (ref) => ref.watch(financeRepositoryProvider).categories(),
);
final transactionsProvider = FutureProvider<List<Movement>>(
  (ref) => ref.watch(financeRepositoryProvider).transactions(),
);
final profileProvider = FutureProvider<Profile>(
  (ref) => ref.watch(financeRepositoryProvider).profile(),
);
