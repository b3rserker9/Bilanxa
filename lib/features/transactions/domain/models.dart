import '../../../core/utils/money.dart';

enum MovementType { income, expense }

enum AccountType { bank, cash, savings }

class Account {
  const Account(this.id, this.name, this.type, this.balance);
  final String id, name;
  final AccountType type;
  final Money balance;
}

class Category {
  const Category(this.id, this.name, this.type);
  final String id, name;
  final MovementType type;
}

class Movement {
  const Movement(
    this.id,
    this.accountId,
    this.categoryId,
    this.type,
    this.amount,
    this.description,
    this.date,
  );
  final String id, accountId, categoryId, description;
  final MovementType type;
  final Money amount;
  final DateTime date;
}

class NewMovement {
  const NewMovement({
    required this.accountId,
    required this.categoryId,
    required this.type,
    required this.amount,
    required this.description,
    required this.date,
  });
  final String accountId, categoryId, description;
  final MovementType type;
  final Money amount;
  final DateTime date;
  void validate() {
    if (accountId.isEmpty ||
        categoryId.isEmpty ||
        amount.cents <= BigInt.zero ||
        description.trim().isEmpty ||
        description.length > 200) {
      throw const FormatException('Invalid movement');
    }
  }
}

class Dashboard {
  const Dashboard(
    this.total,
    this.income,
    this.expense,
    this.remaining,
    this.recent,
  );
  final Money total, income, expense, remaining;
  final List<Movement> recent;
}

class Profile {
  const Profile(this.id, this.email, this.name);
  final String id, email, name;
}
