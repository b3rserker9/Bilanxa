import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/theme.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/components.dart';
import '../../transactions/data/finance_repository.dart';
import '../../transactions/domain/models.dart';
import '../../recurring/presentation/scheduled_expenses_panel.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final it = Localizations.localeOf(context).languageCode == 'it';
    final profile = ref.watch(profileProvider).asData?.value;
    return BilanqoScaffold(
      title: 'Bilanqo',
      actions: [
        IconButton(
          tooltip: context.l.profile,
          onPressed: () => context.push('/profile'),
          icon: const Icon(Icons.person_outline),
        ),
      ],
      child: AsyncSection(
        value: ref.watch(dashboardProvider),
        retry: () => ref.invalidate(dashboardProvider),
        builder: (data) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              it ? 'Bentornato' : 'Welcome back',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  profile == null
                      ? context.l.welcome
                      : '${it ? 'Ciao' : 'Hi'}, ${profile.name}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Chip(
                  label: Text(
                    DateFormat.yMMMM(Localizations.localeOf(context).toString())
                        .format(DateTime.now()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            BalanceCard(amount: data.total, footer: const _BalanceActions()),
            const SizedBox(height: 20),
            const UpcomingExpensesCard(),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      it ? 'Riepilogo mese' : 'Monthly overview',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final cards = [
                          SummaryCard(
                            label: context.l.income,
                            amount: data.income,
                            icon: Icons.south_west,
                          ),
                          SummaryCard(
                            label: context.l.expense,
                            amount: data.expense,
                            icon: Icons.north_east,
                          ),
                        ];
                        final split =
                            constraints.maxWidth >= Tokens.summaryBreakpoint &&
                            MediaQuery.textScalerOf(context).scale(1) < 1.5;
                        return Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: cards
                              .map(
                                (card) => SizedBox(
                                  width: split
                                      ? (constraints.maxWidth - 12) / 2
                                      : constraints.maxWidth,
                                  child: card,
                                ),
                              )
                              .toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary
                            .withValues(alpha: .08),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            context.l.remaining,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 8),
                          AmountText(data.remaining),
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: data.income.cents > BigInt.zero
                                ? (data.expense.cents.toDouble() /
                                          data.income.cents.toDouble())
                                      .clamp(0, 1)
                                : 0,
                            minHeight: 6,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _SpendingInsights(),
            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  context.l.recent,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: () => context.go('/transactions'),
                  child: Text(it ? 'Vedi tutti' : 'View all'),
                ),
              ],
            ),
            if (data.recent.isEmpty)
              EmptyState(message: context.l.emptyMovements)
            else
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: data.recent
                        .map((m) => TransactionTile(movement: m))
                        .toList(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SpendingInsights extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final it = Localizations.localeOf(context).languageCode == 'it';
    final categories =
        ref.watch(categoriesProvider).asData?.value ?? <Category>[];
    return AsyncSection(
      value: ref.watch(transactionsProvider),
      retry: () => ref.invalidate(transactionsProvider),
      builder: (items) {
        final now = DateTime.now();
        final end = DateTime(now.year, now.month, now.day + 1);
        final start = end.subtract(const Duration(days: 7));
        final bars = List<BigInt>.filled(7, BigInt.zero);
        final totals = <String, BigInt>{};
        for (final m in items.where((m) => m.type == MovementType.expense)) {
          if (m.date.year == now.year && m.date.month == now.month) {
            totals.update(
              m.categoryId,
              (v) => v + m.amount.cents,
              ifAbsent: () => m.amount.cents,
            );
          }
          if (!m.date.isBefore(start) && m.date.isBefore(end)) {
            final day = DateTime(
              m.date.year,
              m.date.month,
              m.date.day,
            ).difference(start).inDays;
            if (day >= 0 && day < 7) bars[day] += m.amount.cents;
          }
        }
        final max = bars.fold<BigInt>(BigInt.one, (v, n) => n > v ? n : v);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      it ? 'Andamento settimanale' : 'Weekly spending',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      it
                          ? 'Uscite negli ultimi 7 giorni'
                          : 'Expenses in the last 7 days',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(
                        7,
                        (i) => Expanded(
                          child: Column(
                            children: [
                              Tooltip(
                                message: Money(bars[i]).format(
                                  Localizations.localeOf(context).toString(),
                                ),
                                child: Container(
                                  width: 22,
                                  height:
                                      8 +
                                      64 * bars[i].toDouble() / max.toDouble(),
                                  decoration: BoxDecoration(
                                    color: i == 6
                                        ? Tokens.primaryContainer
                                        : Tokens.secondaryFixedDim.withValues(
                                            alpha: .7,
                                          ),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                DateFormat.E(
                                      Localizations.localeOf(context)
                                          .toString(),
                                    )
                                    .format(start.add(Duration(days: i)))
                                    .substring(0, 1),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (totals.isNotEmpty) ...[
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        it ? 'Spese per categoria' : 'Spending by category',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      for (final entry
                          in (totals.entries.toList()
                            ..sort((a, b) => b.value.compareTo(a.value))))
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const CircleAvatar(
                            backgroundColor: Tokens.secondaryContainer,
                            child: Icon(
                              Icons.category_outlined,
                              color: Tokens.primary,
                            ),
                          ),
                          title: Text(
                            categories
                                    .where((c) => c.id == entry.key)
                                    .firstOrNull
                                    ?.name ??
                                context.l.category,
                          ),
                          trailing: AmountText(
                            Money(entry.value),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _BalanceActions extends StatelessWidget {
  const _BalanceActions();
  @override
  Widget build(BuildContext context) {
    final it = Localizations.localeOf(context).languageCode == 'it';
    final labels = [
      it ? 'Movimento' : 'Add',
      context.l.accounts,
      it ? 'Dividi' : 'Split',
    ];
    final icons = [
      Icons.add,
      Icons.account_balance_wallet_outlined,
      Icons.call_split,
    ];
    final routes = ['/transactions/new', '/accounts', '/groups'];
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = MediaQuery.textScalerOf(context).scale(1) < 1.5;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(
            3,
            (i) => SizedBox(
              width: compact
                  ? (constraints.maxWidth - 16) / 3
                  : constraints.maxWidth,
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: i == 2
                      ? Colors.white
                      : Colors.white.withValues(alpha: .15),
                  foregroundColor: i == 2 ? Tokens.primary : Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 4,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () =>
                    i == 2 ? context.go(routes[i]) : context.push(routes[i]),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icons[i], size: 22),
                    const SizedBox(height: 6),
                    Text(labels[i], style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
