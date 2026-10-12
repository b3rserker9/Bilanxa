import 'models.dart';
import '../../../core/utils/money.dart';

abstract interface class FinanceRepository {
  Future<Dashboard> dashboard();
  Future<List<Account>> accounts();
  Future<List<Category>> categories();
  Future<List<Movement>> transactions();
  Future<Profile> profile();
  Future<void> createAccount(
    String name,
    AccountType type,
    Money initialBalance,
  );
  Future<void> createTransaction(NewMovement movement);
}
