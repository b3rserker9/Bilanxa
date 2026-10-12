import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/theme.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/components.dart';
import '../../../core/widgets/dropdown.dart';
import '../data/finance_repository.dart';
import '../domain/models.dart';

class NewTransactionScreen extends ConsumerWidget {
  const NewTransactionScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => BilanqoScaffold(
    title: context.l.newMovement,
    child: AsyncSection(
      value: ref.watch(accountsProvider),
      retry: () => ref.invalidate(accountsProvider),
      builder: (accounts) => accounts.isEmpty
          ? EmptyState(
              message: context.l.emptyAccounts,
              action: PrimaryButton(
                label: context.l.newAccount,
                onPressed: () => context.push('/accounts'),
              ),
            )
          : AsyncSection(
              value: ref.watch(categoriesProvider),
              retry: () => ref.invalidate(categoriesProvider),
              builder: (categories) => categories.isEmpty
                  ? EmptyState(message: context.l.noCategories)
                  : _TransactionForm(
                      accounts: accounts,
                      categories: categories,
                    ),
            ),
    ),
  );
}

class _TransactionForm extends ConsumerStatefulWidget {
  const _TransactionForm({required this.accounts, required this.categories});
  final List<Account> accounts;
  final List<Category> categories;
  @override
  ConsumerState<_TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends ConsumerState<_TransactionForm> {
  final _key = GlobalKey<FormState>();
  final _amount = TextEditingController(),
      _description = TextEditingController();
  String? _account, _category;
  MovementType _type = MovementType.expense;
  DateTime _date = DateUtils.dateOnly(DateTime.now());
  bool _busy = false;
  Object? _error;
  @override
  void initState() {
    super.initState();
    _account = widget.accounts.first.id;
  }

  @override
  void dispose() {
    _amount.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (mounted && date != null) setState(() => _date = date);
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
          .createTransaction(
            NewMovement(
              accountId: _account!,
              categoryId: _category!,
              type: _type,
              amount: Money.parse(_amount.text.trim().replaceAll(',', '.')),
              description: _description.text,
              date: _date,
            ),
          );
      if (!mounted) return;
      ref.invalidate(transactionsProvider);
      ref.invalidate(dashboardProvider);
      ref.invalidate(accountsProvider);
      context.go('/transactions');
    } catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final available = widget.categories.where((c) => c.type == _type).toList();
    return Form(
      key: _key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BilanqoDropdown<MovementType>(
            initialValue: _type,
            label: context.l.type,
            leading: Icons.swap_vert_rounded,
            items: MovementType.values
                .map(
                  (t) => DropdownMenuItem(
                    value: t,
                    child: Text(
                      t == MovementType.expense
                          ? context.l.expense
                          : context.l.income,
                    ),
                  ),
                )
                .toList(),
            onChanged: _busy
                ? null
                : (t) => setState(() {
                    _type = t!;
                    _category = null;
                  }),
          ),
          const SizedBox(height: Tokens.gap),
          BilanqoDropdown<String>(
            initialValue: _account,

            label: context.l.account,
            leading: Icons.account_balance_wallet_outlined,
            items: widget.accounts
                .map((a) => DropdownMenuItem(value: a.id, child: Text(a.name)))
                .toList(),
            onChanged: _busy ? null : (v) => setState(() => _account = v),
            validator: (v) => v == null ? context.l.required : null,
          ),
          const SizedBox(height: Tokens.gap),
          BilanqoDropdown<String>(
            key: ValueKey(_type),
            initialValue: _category,

            label: context.l.category,
            leading: Icons.category_outlined,
            items: available
                .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                .toList(),
            onChanged: _busy ? null : (v) => setState(() => _category = v),
            validator: (v) => v == null ? context.l.required : null,
          ),
          if (available.isEmpty) Text(context.l.noCategories),
          const SizedBox(height: Tokens.gap),
          TextFormField(
            controller: _amount,
            enabled: !_busy,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: context.l.amount,
              suffixText: 'EUR',
            ),
            validator: (v) {
              try {
                final money = Money.parse(
                  (v ?? '').trim().replaceAll(',', '.'),
                );
                return money.cents > BigInt.zero
                    ? null
                    : context.l.positiveAmount;
              } catch (_) {
                return context.l.invalidAmount;
              }
            },
          ),
          const SizedBox(height: Tokens.gap),
          TextFormField(
            controller: _description,
            enabled: !_busy,
            maxLength: 200,
            decoration: InputDecoration(labelText: context.l.description),
            validator: (v) =>
                (v ?? '').trim().isEmpty ? context.l.required : null,
          ),
          const SizedBox(height: Tokens.gap),
          OutlinedButton.icon(
            onPressed: _busy ? null : _pickDate,
            icon: const Icon(Icons.calendar_today_outlined),
            label: Text(
              '${context.l.date}: ${DateFormat.yMMMd(Localizations.localeOf(context).toString()).format(_date)}',
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: Tokens.gap),
            Text(context.errorMessage(_error!)),
          ],
          const SizedBox(height: Tokens.page),
          PrimaryButton(
            label: context.l.save,
            onPressed: available.isEmpty ? null : _save,
            busy: _busy,
          ),
        ],
      ),
    );
  }
}
