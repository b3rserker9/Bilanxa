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
import '../../recurring/presentation/scheduled_expenses_panel.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key, this.scheduled = false});
  final bool scheduled;
  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  final search = TextEditingController();
  MovementType? type;
  String? account;
  DateTime month = DateTime(DateTime.now().year, DateTime.now().month);
  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final it = Localizations.localeOf(context).languageCode == 'it';
    final locale = Localizations.localeOf(context).toString();
    final accounts = ref.watch(accountsProvider).asData?.value ?? <Account>[];
    return BilanqoScaffold(
      title: context.l.transactions,
      floatingActionButton: widget.scheduled
          ? null
          : FloatingActionButton.extended(
              onPressed: () => context.push('/transactions/new'),
              icon: const Icon(Icons.add),
              label: Text(context.l.newMovement),
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<bool>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(
                value: false,
                label: Text(
                  it ? 'Registrate' : 'Recorded',
                  maxLines: 2,
                  textAlign: TextAlign.center,
                ),
                icon: MediaQuery.textScalerOf(context).scale(1) > 1.3
                    ? null
                    : const Icon(Icons.receipt_long_outlined),
              ),
              ButtonSegment(
                value: true,
                label: Text(
                  it ? 'Programmate' : 'Scheduled',
                  maxLines: 2,
                  textAlign: TextAlign.center,
                ),
                icon: MediaQuery.textScalerOf(context).scale(1) > 1.3
                    ? null
                    : const Icon(Icons.event_repeat),
              ),
            ],
            selected: {widget.scheduled},
            onSelectionChanged: (value) => context.go(
              value.first ? '/transactions?tab=scheduled' : '/transactions',
            ),
          ),
          const SizedBox(height: 20),
          if (widget.scheduled)
            const ScheduledExpensesPanel()
          else
            AsyncSection(
              value: ref.watch(transactionsProvider),
              retry: () => ref.invalidate(transactionsProvider),
              builder: (items) {
                final monthly = items
                    .where(
                      (m) =>
                          m.date.year == month.year &&
                          m.date.month == month.month,
                    )
                    .toList();
                final expense = monthly
                    .where((m) => m.type == MovementType.expense)
                    .fold<BigInt>(
                      BigInt.zero,
                      (sum, m) => sum + m.amount.cents,
                    );
                final filtered =
                    monthly
                        .where(
                          (m) =>
                              (type == null || m.type == type) &&
                              (account == null || m.accountId == account) &&
                              m.description.toLowerCase().contains(
                                search.text.trim().toLowerCase(),
                              ),
                        )
                        .toList()
                      ..sort((a, b) => b.date.compareTo(a.date));
                final grouped = <DateTime, List<Movement>>{};
                for (final m in filtered) {
                  grouped
                      .putIfAbsent(
                        DateTime(m.date.year, m.date.month, m.date.day),
                        () => [],
                      )
                      .add(m);
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  tooltip: it
                                      ? 'Mese precedente'
                                      : 'Previous month',
                                  onPressed: () => setState(
                                    () => month = DateTime(
                                      month.year,
                                      month.month - 1,
                                    ),
                                  ),
                                  icon: const Icon(Icons.chevron_left),
                                ),
                                Expanded(
                                  child: Text(
                                    DateFormat.yMMMM(locale).format(month),
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium,
                                  ),
                                ),
                                IconButton(
                                  tooltip: it
                                      ? 'Mese successivo'
                                      : 'Next month',
                                  onPressed: () => setState(
                                    () => month = DateTime(
                                      month.year,
                                      month.month + 1,
                                    ),
                                  ),
                                  icon: const Icon(Icons.chevron_right),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              it ? 'Totale uscite mese' : 'Monthly expenses',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 8),
                            AmountText(
                              Money(expense),
                              style: Theme.of(context).textTheme.headlineLarge,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: search,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: it
                            ? 'Cerca un movimento…'
                            : 'Search transactions…',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: search.text.isEmpty
                            ? null
                            : IconButton(
                                tooltip: it
                                    ? 'Cancella ricerca'
                                    : 'Clear search',
                                onPressed: () => setState(search.clear),
                                icon: const Icon(Icons.close),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final value in [
                          null,
                          MovementType.expense,
                          MovementType.income,
                        ])
                          ChoiceChip(
                            label: Text(
                              value == null
                                  ? (it ? 'Tutti' : 'All')
                                  : value == MovementType.expense
                                  ? context.l.expense
                                  : context.l.income,
                            ),
                            selected: type == value,
                            labelStyle: TextStyle(
                              color: type == value
                                  ? Colors.white
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                            onSelected: (_) => setState(() => type = value),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    BilanqoDropdown<String>(
                      key: ValueKey(account),
                      initialValue: account,

                      leading: Icons.account_balance_wallet_outlined,
                      items: [
                        DropdownMenuItem<String>(
                          value: null,
                          child: Text(it ? 'Tutti i conti' : 'All accounts'),
                        ),
                        ...accounts.map(
                          (a) => DropdownMenuItem(
                            value: a.id,
                            child: Text(a.name),
                          ),
                        ),
                      ],
                      onChanged: (value) => setState(() => account = value),
                    ),
                    const SizedBox(height: 24),
                    if (items.isEmpty)
                      EmptyState(message: context.l.emptyMovements)
                    else if (filtered.isEmpty)
                      EmptyState(
                        message: it
                            ? 'Nessun movimento trovato'
                            : 'No transactions found',
                        action: TextButton(
                          onPressed: () => setState(() {
                            search.clear();
                            type = null;
                            account = null;
                          }),
                          child: Text(
                            it ? 'Reimposta filtri' : 'Reset filters',
                          ),
                        ),
                      )
                    else
                      for (final entry in grouped.entries) ...[
                        Text(
                          DateFormat.yMMMMd(locale).format(entry.key),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Column(
                              children: entry.value
                                  .map(
                                    (m) => InkWell(
                                      borderRadius: Tokens.round,
                                      onTap: () =>
                                          _detail(context, m, accounts),
                                      child: TransactionTile(movement: m),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  void _detail(BuildContext context, Movement m, List<Account> accounts) {
    final it = Localizations.localeOf(context).languageCode == 'it';
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                it ? 'Dettaglio operazione' : 'Transaction details',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 20),
              Text(
                m.description,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              AmountText(
                m.amount,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 20),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_month),
                title: Text(context.l.date),
                subtitle: Text(
                  DateFormat.yMMMMd(Localizations.localeOf(context).toString())
                      .format(m.date),
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.account_balance_wallet_outlined),
                title: Text(context.l.account),
                subtitle: Text(
                  accounts
                          .where((a) => a.id == m.accountId)
                          .firstOrNull
                          ?.name ??
                      m.accountId,
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  m.type == MovementType.income
                      ? Icons.south_west
                      : Icons.north_east,
                ),
                title: Text(
                  m.type == MovementType.income
                      ? context.l.income
                      : context.l.expense,
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: Text(it ? 'Chiudi' : 'Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
