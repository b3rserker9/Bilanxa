import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/theme.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/components.dart';
import '../../../core/widgets/dropdown.dart';
import '../../transactions/domain/models.dart';
import '../../transactions/data/finance_repository.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => BilanqoScaffold(
    title: context.l.accounts,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PrimaryButton(
          label: context.l.newAccount,
          onPressed: () => showDialog<void>(
            context: context,
            builder: (_) => const _AccountForm(),
          ),
        ),
        const SizedBox(height: Tokens.page),
        AsyncSection(
          value: ref.watch(accountsProvider),
          retry: () => ref.invalidate(accountsProvider),
          builder: (accounts) => accounts.isEmpty
              ? EmptyState(
                  message: context.l.emptyAccounts,
                  icon: Icons.account_balance_wallet_outlined,
                )
              : Column(
                  children: accounts
                      .map(
                        (a) => Padding(
                          padding: const EdgeInsets.only(bottom: Tokens.gap),
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(Tokens.gap),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    a.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium,
                                  ),
                                  Text(accountLabel(context, a.type)),
                                  const SizedBox(height: Tokens.small),
                                  AmountText(a.balance),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
        ),
      ],
    ),
  );
}

String accountLabel(BuildContext context, AccountType type) => switch (type) {
  AccountType.bank => context.l.bank,
  AccountType.cash => context.l.cash,
  AccountType.savings => context.l.savings,
};

class _AccountForm extends ConsumerStatefulWidget {
  const _AccountForm();
  @override
  ConsumerState<_AccountForm> createState() => _AccountFormState();
}

class _AccountFormState extends ConsumerState<_AccountForm> {
  final _key = GlobalKey<FormState>();
  final _name = TextEditingController(),
      _balance = TextEditingController(text: '0.00');
  AccountType _type = AccountType.bank;
  bool _busy = false;
  Object? _error;
  @override
  void dispose() {
    _name.dispose();
    _balance.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_key.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(financeRepositoryProvider)
          .createAccount(
            _name.text,
            _type,
            Money.parse(_balance.text.trim().replaceAll(',', '.')),
          );
      if (!mounted) return;
      ref.invalidate(accountsProvider);
      ref.invalidate(dashboardProvider);
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(context.l.newAccount),
    content: SizedBox(
      width: 400,
      child: SingleChildScrollView(
        child: Form(
          key: _key,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _name,
                maxLength: 80,
                decoration: InputDecoration(labelText: context.l.name),
                validator: (v) =>
                    (v ?? '').trim().isEmpty ? context.l.required : null,
              ),
              const SizedBox(height: Tokens.gap),
              BilanqoDropdown<AccountType>(
                initialValue: _type,

                label: context.l.accountType,
                leading: Icons.account_balance_wallet_outlined,
                items: AccountType.values
                    .map(
                      (t) => DropdownMenuItem(
                        value: t,
                        child: Text(accountLabel(context, t)),
                      ),
                    )
                    .toList(),
                onChanged: _busy ? null : (t) => setState(() => _type = t!),
              ),
              const SizedBox(height: Tokens.gap),
              TextFormField(
                controller: _balance,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                decoration: InputDecoration(
                  labelText: context.l.initialBalance,
                  suffixText: 'EUR',
                ),
                validator: (v) {
                  try {
                    Money.parse((v ?? '').trim().replaceAll(',', '.'));
                    return null;
                  } catch (_) {
                    return context.l.invalidAmount;
                  }
                },
              ),
              if (_error != null) ...[
                const SizedBox(height: Tokens.gap),
                Text(context.errorMessage(_error!)),
              ],
              const SizedBox(height: Tokens.page),
              PrimaryButton(
                label: context.l.save,
                onPressed: _save,
                busy: _busy,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
