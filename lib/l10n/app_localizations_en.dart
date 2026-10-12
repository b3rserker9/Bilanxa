// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get home => 'Home';

  @override
  String get transactions => 'Transactions';

  @override
  String get groups => 'Groups';

  @override
  String get budgets => 'Budgets';

  @override
  String get profile => 'Profile';

  @override
  String get accounts => 'Accounts';

  @override
  String get login => 'Sign in';

  @override
  String get register => 'Create account';

  @override
  String get reset => 'Reset password';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get invalidEmail => 'Enter a valid email';

  @override
  String get invalidPassword => 'Enter your password';

  @override
  String get weakPassword => 'Use at least 8 characters';

  @override
  String get welcome => 'Your finances, made simple.';

  @override
  String get intro =>
      'A place to understand your spending and make room for your plans.';

  @override
  String get firebaseSetup => 'The sign-in service is not available yet.';

  @override
  String get resetSent =>
      'If this email is registered, you will receive password reset instructions.';

  @override
  String get networkError =>
      'We cannot connect. Check your connection and try again.';

  @override
  String get unauthorized =>
      'Your session is invalid. Sign out and sign in again.';

  @override
  String get genericError => 'We could not complete this action. Try again.';

  @override
  String get authError =>
      'Sign-in failed. Check your details or try again later.';

  @override
  String get contractError =>
      'The received data is incompatible with this app version.';

  @override
  String get configurationError =>
      'The service is not available yet. Please try again later.';

  @override
  String get validationError => 'Check your details and try again.';

  @override
  String get forbidden => 'You do not have access to this data.';

  @override
  String get retry => 'Retry';

  @override
  String get empty => 'Nothing here yet';

  @override
  String get emptyMovements => 'Add your first transaction to get started.';

  @override
  String get emptyAccounts =>
      'Create an account to start tracking your spending.';

  @override
  String get balance => 'Total balance';

  @override
  String get income => 'Your income';

  @override
  String get expense => 'Your spending';

  @override
  String get remaining => 'What is left this month?';

  @override
  String get recent => 'Recent transactions';

  @override
  String get addMovement => 'Add transaction';

  @override
  String get addExpense => 'Add expense';

  @override
  String get newAccount => 'Create account';

  @override
  String get name => 'Name';

  @override
  String get accountType => 'Account type';

  @override
  String get bank => 'Bank account';

  @override
  String get cash => 'Cash';

  @override
  String get savings => 'Savings';

  @override
  String get initialBalance => 'Opening balance';

  @override
  String get amount => 'Amount';

  @override
  String get invalidAmount => 'Enter a valid amount with up to 2 decimals';

  @override
  String get positiveAmount => 'Amount must be greater than zero';

  @override
  String get required => 'This field is required';

  @override
  String get save => 'Save';

  @override
  String get description => 'Description';

  @override
  String get date => 'Date';

  @override
  String get account => 'Account';

  @override
  String get category => 'Category';

  @override
  String get type => 'Type';

  @override
  String get newMovement => 'New transaction';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get groupsText =>
      'Split with friends. Soon you will be able to manage shared expenses and repayments in one place.';

  @override
  String get budgetsText =>
      'Make room for your goals. Soon you will be able to choose how much to spend each month.';

  @override
  String get theme => 'Appearance';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get system => 'System';

  @override
  String get logout => 'Sign out';

  @override
  String get loading => 'Loading';

  @override
  String get noCategories => 'No category available for this transaction type.';

  @override
  String get tooLong => 'Use at most 200 characters';

  @override
  String get month => 'This month';

  @override
  String get mockMode => 'TEST MODE · Simulated data, temporary changes';

  @override
  String get mockLogin =>
      'Try the app with a valid email and any password. No real account will be created.';

  @override
  String get mockReset => 'Test mode: no email was sent.';
}
