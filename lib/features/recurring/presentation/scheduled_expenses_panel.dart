import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/money.dart';
import '../../../core/widgets/components.dart';
import '../../../core/widgets/dropdown.dart';
import '../../transactions/data/finance_repository.dart';
import '../../transactions/domain/models.dart';
import '../data/scheduled_expenses.dart';
import '../domain/scheduled_expense.dart';

String tr(BuildContext context, String it, String en) =>
    Localizations.localeOf(context).languageCode == 'it' ? it : en;
String dateLabel(BuildContext context, DateTime date) =>
    DateFormat.yMMMd(Localizations.localeOf(context).toString()).format(date);
String frequencyLabel(BuildContext context, int months) => switch (months) {
  1 => tr(context, 'Ogni mese', 'Monthly'),
  2 => tr(context, 'Ogni 2 mesi', 'Every 2 months'),
  3 => tr(context, 'Ogni 3 mesi', 'Every 3 months'),
  _ => tr(context, 'Ogni anno', 'Yearly'),
};

void showScheduledEditor(
  BuildContext context, {
  ScheduledExpense? expense,
  String? preset,
  bool variable = false,
}) {
  showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) =>
        _ExpenseEditor(expense: expense, preset: preset, variable: variable),
  );
}

class UpcomingExpensesCard extends ConsumerWidget {
  const UpcomingExpensesCard({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(scheduledEnabledProvider)) return const SizedBox.shrink();
    final state = ref.watch(scheduledExpensesProvider);
    final active =
        state.expenses.where((e) => e.status == ScheduleStatus.active).toList()
          ..sort((a, b) => a.nextDue.compareTo(b.nextDue));
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => context.go('/transactions?tab=scheduled'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.event_repeat,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      tr(context, 'Spese fisse', 'Recurring expenses'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              const SizedBox(height: 12),
              if (active.isEmpty)
                Text(
                  tr(
                    context,
                    'Abbonamenti, bollette e affitto: tutte le scadenze in un posto.',
                    'Subscriptions, bills and rent: every due date in one place.',
                  ),
                )
              else ...[
                Text(
                  tr(context, 'Da pagare questo mese', 'Still due this month'),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                AmountText(state.expectedIn(DateTime.now())),
                const SizedBox(height: 8),
                Text(
                  '${active.first.name} · ${dateLabel(context, active.first.nextDue)}${active.first.nextDue.isBefore(dateOnly(DateTime.now())) ? tr(context, ' · In ritardo', ' · Overdue') : ''}',
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class ScheduledExpensesPanel extends ConsumerStatefulWidget {
  const ScheduledExpensesPanel({super.key});
  @override
  ConsumerState<ScheduledExpensesPanel> createState() =>
      _ScheduledExpensesPanelState();
}

class _ScheduledExpensesPanelState
    extends ConsumerState<ScheduledExpensesPanel> {
  int tab = 0;
  DateTime month = DateTime(DateTime.now().year, DateTime.now().month);
  @override
  Widget build(BuildContext context) {
    if (!ref.watch(scheduledEnabledProvider)) {
      return EmptyState(
        icon: Icons.event_repeat,
        message: tr(
          context,
          'Le spese programmate sono disponibili nella modalità prova.',
          'Scheduled expenses are available in demo mode.',
        ),
      );
    }
    final state = ref.watch(scheduledExpensesProvider);
    final active =
        state.expenses.where((e) => e.status == ScheduleStatus.active).toList()
          ..sort((a, b) => a.nextDue.compareTo(b.nextDue));
    final end = DateTime(month.year, month.month + 1);
    final due = active.where((e) => e.nextDue.isBefore(end)).toList();
    final paid = state.paidIn(month);
    final remaining = state.expectedIn(month);
    final history =
        state.history
            .where(
              (o) => o.due.year == month.year && o.due.month == month.month,
            )
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          tr(context, 'Le tue spese fisse', 'Your recurring expenses'),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          tr(
            context,
            'Abbonamenti, bollette e affitto, sotto controllo.',
            'Subscriptions, bills and rent, under control.',
          ),
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    IconButton(
                      tooltip: tr(context, 'Mese precedente', 'Previous month'),
                      onPressed: () => setState(
                        () => month = DateTime(month.year, month.month - 1),
                      ),
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Expanded(
                      child: Text(
                        DateFormat.yMMMM(
                          Localizations.localeOf(context).toString(),
                        ).format(month),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    IconButton(
                      tooltip: tr(context, 'Mese successivo', 'Next month'),
                      onPressed: () => setState(
                        () => month = DateTime(month.year, month.month + 1),
                      ),
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
                Text(
                  tr(context, 'Da pagare nel mese', 'Due this month'),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 6),
                AmountText(
                  remaining,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 12),
                Text(
                  '${tr(context, 'Già pagato', 'Already paid')}: ${displayMoney(paid, Localizations.localeOf(context).toString())}',
                ),
                if (active.any((e) => e.variable)) ...[
                  const SizedBox(height: 8),
                  Text(
                    tr(
                      context,
                      'Importi variabili inclusi come stime.',
                      'Variable amounts included as estimates.',
                    ),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                if (due.any(
                  (e) => e.nextDue.isBefore(DateTime(month.year, month.month)),
                )) ...[
                  const SizedBox(height: 8),
                  Text(
                    tr(
                      context,
                      'Qui sotto trovi anche scadenze precedenti ancora da confermare.',
                      'Earlier unconfirmed due dates are also listed below.',
                    ),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () => showScheduledEditor(context),
          icon: const Icon(Icons.add),
          label: Text(
            tr(context, 'Aggiungi spesa fissa', 'Add recurring expense'),
          ),
        ),
        const SizedBox(height: 20),
        if (state.expenses.isEmpty) ...[
          EmptyState(
            icon: Icons.event_repeat,
            message: tr(
              context,
              'Inizia dalle spese che si ripetono. Scegli un esempio o crea la tua.',
              'Start with expenses that repeat. Choose an example or create your own.',
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ActionChip(
                avatar: const Icon(Icons.play_circle_outline, size: 18),
                label: Text(tr(context, 'Abbonamento', 'Subscription')),
                onPressed: () => showScheduledEditor(
                  context,
                  preset: tr(context, 'Abbonamento', 'Subscription'),
                ),
              ),
              ActionChip(
                avatar: const Icon(Icons.bolt, size: 18),
                label: Text(tr(context, 'Bolletta', 'Utility bill')),
                onPressed: () => showScheduledEditor(
                  context,
                  preset: tr(context, 'Bolletta', 'Utility bill'),
                  variable: true,
                ),
              ),
              ActionChip(
                avatar: const Icon(Icons.home_outlined, size: 18),
                label: Text(tr(context, 'Affitto', 'Rent')),
                onPressed: () => showScheduledEditor(
                  context,
                  preset: tr(context, 'Affitto', 'Rent'),
                ),
              ),
            ],
          ),
        ] else ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(
              3,
              (i) => ChoiceChip(
                label: Text(
                  [
                    tr(context, 'Da pagare', 'Due'),
                    tr(context, 'Storico', 'History'),
                    tr(context, 'Gestisci', 'Manage'),
                  ][i],
                ),
                selected: tab == i,
                labelStyle: TextStyle(
                  color: tab == i
                      ? Colors.white
                      : Theme.of(context).colorScheme.onSurface,
                ),
                onSelected: (_) => setState(() => tab = i),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (tab == 0 && due.isEmpty)
            EmptyState(
              message: tr(
                context,
                'Tutto in ordine: nessuna scadenza da pagare in questo mese.',
                'All clear: no bills due in this month.',
              ),
              icon: Icons.check_circle_outline,
            ),
          if (tab == 0)
            for (final expense in due)
              _ExpenseCard(
                expense: expense,
                busy: state.pending.contains(expense.id),
              ),
          if (tab == 1 && history.isEmpty)
            EmptyState(
              message: tr(
                context,
                'Qui vedrai le scadenze pagate o saltate.',
                'Paid and skipped occurrences will appear here.',
              ),
              icon: Icons.history,
            ),
          if (tab == 1)
            for (final occurrence in history)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        occurrence.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${occurrence.status == OccurrenceStatus.paid ? tr(context, 'Pagata', 'Paid') : tr(context, 'Saltata', 'Skipped')} · ${dateLabel(context, occurrence.due)}',
                      ),
                      if (occurrence.status == OccurrenceStatus.paid) ...[
                        const SizedBox(height: 8),
                        AmountText(occurrence.amount),
                      ],
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
          if (tab == 2)
            for (final expense in state.expenses)
              _ExpenseCard(
                expense: expense,
                busy: state.pending.contains(expense.id),
                management: true,
              ),
        ],
      ],
    );
  }
}

class _ExpenseCard extends ConsumerWidget {
  const _ExpenseCard({
    required this.expense,
    required this.busy,
    this.management = false,
  });
  final ScheduledExpense expense;
  final bool busy, management;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overdue =
        expense.status == ScheduleStatus.active &&
        expense.nextDue.isBefore(dateOnly(DateTime.now()));
    final controller = ref.read(scheduledExpensesProvider.notifier);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .surfaceContainerLow,
                    child: Icon(
                      expense.variable ? Icons.bolt : Icons.event_repeat,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      expense.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  PopupMenuButton<String>(
                    enabled: !busy,
                    tooltip: tr(context, 'Gestisci spesa', 'Manage expense'),
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          showScheduledEditor(context, expense: expense);
                        case 'skip':
                          controller.skip(expense.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              action: SnackBarAction(
                                label: tr(context, 'Annulla', 'Undo'),
                                onPressed: () => controller.undoSkip(
                                  expense.id,
                                  expense.nextDue,
                                ),
                              ),
                              content: Text(
                                tr(
                                  context,
                                  'Scadenza saltata. Nessuna spesa registrata.',
                                  'Occurrence skipped. No transaction recorded.',
                                ),
                              ),
                            ),
                          );
                        case 'pause':
                          controller.setStatus(
                            expense.id,
                            ScheduleStatus.paused,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                tr(
                                  context,
                                  'Spesa in pausa. La trovi in Gestisci.',
                                  'Expense paused. Find it under Manage.',
                                ),
                              ),
                            ),
                          );
                        case 'resume':
                          controller.setStatus(
                            expense.id,
                            ScheduleStatus.active,
                          );
                        case 'end':
                          controller.setStatus(
                            expense.id,
                            ScheduleStatus.ended,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                tr(
                                  context,
                                  'Spesa terminata. Lo storico è conservato.',
                                  'Expense ended. History is kept.',
                                ),
                              ),
                            ),
                          );
                      }
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Text(tr(context, 'Modifica', 'Edit')),
                      ),
                      if (expense.status == ScheduleStatus.active) ...[
                        PopupMenuItem(
                          value: 'skip',
                          child: Text(
                            tr(
                              context,
                              'Salta questa scadenza',
                              'Skip this occurrence',
                            ),
                          ),
                        ),
                        PopupMenuItem(
                          value: 'pause',
                          child: Text(tr(context, 'Metti in pausa', 'Pause')),
                        ),
                      ],
                      if (expense.status != ScheduleStatus.active)
                        PopupMenuItem(
                          value: 'resume',
                          child: Text(tr(context, 'Riattiva', 'Resume')),
                        ),
                      if (expense.status != ScheduleStatus.ended)
                        PopupMenuItem(
                          value: 'end',
                          child: Text(tr(context, 'Termina', 'End')),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '${frequencyLabel(context, expense.intervalMonths)} · ${expense.variable ? tr(context, 'Importo stimato', 'Estimated amount') : tr(context, 'Importo fisso', 'Fixed amount')}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              AmountText(expense.amount),
              const SizedBox(height: 12),
              Text(
                expense.status == ScheduleStatus.paused
                    ? tr(context, 'In pausa', 'Paused')
                    : expense.status == ScheduleStatus.ended
                    ? tr(
                        context,
                        'Terminata · storico conservato',
                        'Ended · history kept',
                      )
                    : '${overdue ? tr(context, 'In ritardo', 'Overdue') : tr(context, 'Scadenza', 'Due')} · ${dateLabel(context, expense.nextDue)}',
                style: TextStyle(
                  color: overdue
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              if (!management && expense.status == ScheduleStatus.active) ...[
                const SizedBox(height: 16),
                PrimaryButton(
                  label: tr(context, 'Segna come pagata', 'Mark as paid'),
                  busy: busy,
                  onPressed: () => showModalBottomSheet<void>(
                    context: context,
                    useRootNavigator: true,
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .surfaceContainerLowest,
                    isScrollControlled: true,
                    showDragHandle: true,
                    builder: (_) => _PaymentSheet(expense: expense),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetLayout extends StatelessWidget {
  const _SheetLayout({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => SafeArea(
    child: ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * .9,
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          8,
          20,
          MediaQuery.viewInsetsOf(context).bottom + 24,
        ),
        child: child,
      ),
    ),
  );
}

class _ExpenseEditor extends ConsumerStatefulWidget {
  const _ExpenseEditor({this.expense, this.preset, this.variable = false});
  final ScheduledExpense? expense;
  final String? preset;
  final bool variable;
  @override
  ConsumerState<_ExpenseEditor> createState() => _ExpenseEditorState();
}

class _ExpenseEditorState extends ConsumerState<_ExpenseEditor> {
  final form = GlobalKey<FormState>();
  late final TextEditingController name, amount;
  late bool variable;
  late int interval;
  late DateTime due;
  String? account, category;
  @override
  void initState() {
    super.initState();
    name = TextEditingController(
      text: widget.expense?.name ?? widget.preset ?? '',
    );
    amount = TextEditingController(
      text: widget.expense?.amount.decimal.replaceAll('.', ',') ?? '',
    );
    variable = widget.expense?.variable ?? widget.variable;
    interval = widget.expense?.intervalMonths ?? 1;
    due = widget.expense?.nextDue ?? dateOnly(DateTime.now());
    account = widget.expense?.accountId;
    category = widget.expense?.categoryId;
  }

  @override
  void dispose() {
    name.dispose();
    amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _SheetLayout(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.expense == null
              ? tr(context, 'Nuova spesa fissa', 'New recurring expense')
              : tr(context, 'Modifica spesa fissa', 'Edit recurring expense'),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          tr(
            context,
            'Programma una scadenza. Nessun addebito automatico.',
            'Schedule a due date. No automatic charges.',
          ),
        ),
        const SizedBox(height: 20),
        AsyncSection(
          value: ref.watch(accountsProvider),
          retry: () => ref.invalidate(accountsProvider),
          builder: (accounts) => accounts.isEmpty
              ? EmptyState(
                  message: context.l.emptyAccounts,
                  action: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context.push('/accounts');
                    },
                    child: Text(context.l.newAccount),
                  ),
                )
              : AsyncSection(
                  value: ref.watch(categoriesProvider),
                  retry: () => ref.invalidate(categoriesProvider),
                  builder: (categories) {
                    final expenses = categories
                        .where((c) => c.type == MovementType.expense)
                        .toList();
                    if (expenses.isEmpty) {
                      return EmptyState(message: context.l.noCategories);
                    }
                    account ??= accounts.first.id;
                    category ??= expenses.first.id;
                    return Form(
                      key: form,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: name,
                            maxLength: 80,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: InputDecoration(
                              labelText: tr(
                                context,
                                'Nome della spesa',
                                'Expense name',
                              ),
                              hintText: tr(
                                context,
                                'Es. Netflix, luce, affitto',
                                'e.g. Netflix, electricity, rent',
                              ),
                            ),
                            validator: (v) => (v ?? '').trim().isEmpty
                                ? context.l.required
                                : null,
                          ),
                          const SizedBox(height: 12),
                          SwitchListTile.adaptive(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              tr(
                                context,
                                'L’importo cambia ogni volta',
                                'The amount changes each time',
                              ),
                            ),
                            subtitle: Text(
                              tr(
                                context,
                                'Attivalo per bollette e spese variabili.',
                                'Use for utility bills and variable expenses.',
                              ),
                            ),
                            value: variable,
                            onChanged: (value) =>
                                setState(() => variable = value),
                          ),
                          TextFormField(
                            controller: amount,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              labelText: variable
                                  ? tr(
                                      context,
                                      'Importo stimato',
                                      'Estimated amount',
                                    )
                                  : context.l.amount,
                              suffixText: '€',
                            ),
                            validator: (v) => _validateAmount(context, v),
                          ),
                          const SizedBox(height: 16),
                          BilanqoDropdown<int>(
                            label: tr(context, 'Si ripete', 'Repeats'),
                            initialValue: interval,
                            leading: Icons.event_repeat,
                            items: [
                              for (final n in [1, 2, 3, 12])
                                DropdownMenuItem(
                                  value: n,
                                  child: Text(frequencyLabel(context, n)),
                                ),
                            ],
                            onChanged: (value) =>
                                setState(() => interval = value!),
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: () async {
                              final selected = await showDatePicker(
                                context: context,
                                initialDate: due,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (mounted && selected != null) {
                                setState(() => due = selected);
                              }
                            },
                            icon: const Icon(Icons.calendar_month),
                            label: Text(
                              '${tr(context, 'Prossima scadenza', 'Next due date')}: ${dateLabel(context, due)}',
                            ),
                          ),
                          const SizedBox(height: 12),
                          ExpansionTile(
                            tilePadding: EdgeInsets.zero,
                            title: Text(
                              tr(
                                context,
                                'Conto e categoria',
                                'Account and category',
                              ),
                            ),
                            subtitle: Text(
                              tr(
                                context,
                                'Già compilati, puoi cambiarli',
                                'Already filled in, you can change them',
                              ),
                            ),
                            childrenPadding: const EdgeInsets.only(bottom: 16),
                            children: [
                              BilanqoDropdown<String>(
                                initialValue: account,
                                label: context.l.account,
                                items: accounts
                                    .map(
                                      (a) => DropdownMenuItem(
                                        value: a.id,
                                        child: Text(a.name),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) =>
                                    setState(() => account = value),
                                validator: (value) =>
                                    accounts.any((a) => a.id == value)
                                    ? null
                                    : context.l.required,
                              ),
                              const SizedBox(height: 16),
                              BilanqoDropdown<String>(
                                initialValue: category,
                                label: context.l.category,
                                items: expenses
                                    .map(
                                      (c) => DropdownMenuItem(
                                        value: c.id,
                                        child: Text(c.name),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) =>
                                    setState(() => category = value),
                                validator: (value) =>
                                    expenses.any((c) => c.id == value)
                                    ? null
                                    : context.l.required,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          PrimaryButton(
                            label: widget.expense == null
                                ? tr(
                                    context,
                                    'Crea scadenza',
                                    'Create schedule',
                                  )
                                : tr(
                                    context,
                                    'Salva modifiche',
                                    'Save changes',
                                  ),
                            onPressed: () {
                              if (!form.currentState!.validate()) return;
                              final controller = ref.read(
                                scheduledExpensesProvider.notifier,
                              );
                              controller.save(
                                ScheduledExpense(
                                  id: widget.expense?.id ?? controller.nextId(),
                                  name: name.text.trim(),
                                  amount: Money.parse(
                                    amount.text.trim().replaceAll(',', '.'),
                                  ),
                                  variable: variable,
                                  intervalMonths: interval,
                                  nextDue: due,
                                  anchorDay: widget.expense?.nextDue == due
                                      ? widget.expense!.anchorDay
                                      : due.day,
                                  accountId: account!,
                                  categoryId: category!,
                                  status:
                                      widget.expense?.status ??
                                      ScheduleStatus.active,
                                ),
                              );
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    tr(
                                      context,
                                      'Spesa fissa salvata',
                                      'Recurring expense saved',
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    ),
  );
}

String? _validateAmount(BuildContext context, String? value) {
  try {
    return Money.parse((value ?? '').trim().replaceAll(',', '.')).cents >
            BigInt.zero
        ? null
        : context.l.positiveAmount;
  } catch (_) {
    return context.l.invalidAmount;
  }
}

class _PaymentSheet extends ConsumerStatefulWidget {
  const _PaymentSheet({required this.expense});
  final ScheduledExpense expense;
  @override
  ConsumerState<_PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends ConsumerState<_PaymentSheet> {
  final form = GlobalKey<FormState>();
  late final TextEditingController amount;
  late String account;
  DateTime date = dateOnly(DateTime.now());
  bool busy = false;
  Object? error;
  @override
  void initState() {
    super.initState();
    amount = TextEditingController(
      text: widget.expense.amount.decimal.replaceAll('.', ','),
    );
    account = widget.expense.accountId;
  }

  @override
  void dispose() {
    amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _SheetLayout(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          tr(context, 'Conferma pagamento', 'Confirm payment'),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          '${widget.expense.name} · ${dateLabel(context, widget.expense.nextDue)}',
        ),
        const SizedBox(height: 12),
        Text(
          widget.expense.variable
              ? tr(
                  context,
                  'Inserisci l’importo effettivo della bolletta.',
                  'Enter the actual bill amount.',
                )
              : tr(
                  context,
                  'Verrà registrata una spesa nei Movimenti.',
                  'An expense will be recorded in Transactions.',
                ),
        ),
        const SizedBox(height: 20),
        AsyncSection(
          value: ref.watch(accountsProvider),
          retry: () => ref.invalidate(accountsProvider),
          builder: (accounts) => Form(
            key: form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: amount,
                  enabled: !busy,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: tr(context, 'Importo pagato', 'Amount paid'),
                    suffixText: '€',
                  ),
                  validator: (v) => _validateAmount(context, v),
                ),
                const SizedBox(height: 16),
                BilanqoDropdown<String>(
                  label: tr(context, 'Pagata da', 'Paid from'),
                  initialValue: account,
                  items: accounts
                      .map(
                        (a) =>
                            DropdownMenuItem(value: a.id, child: Text(a.name)),
                      )
                      .toList(),
                  onChanged: busy
                      ? null
                      : (value) => setState(() => account = value!),
                  validator: (value) => accounts.any((a) => a.id == value)
                      ? null
                      : context.l.required,
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: busy
                      ? null
                      : () async {
                          final selected = await showDatePicker(
                            context: context,
                            initialDate: date,
                            firstDate: DateTime(2000),
                            lastDate: dateOnly(DateTime.now()),
                          );
                          if (mounted && selected != null) {
                            setState(() => date = selected);
                          }
                        },
                  icon: const Icon(Icons.calendar_today_outlined),
                  label: Text('${context.l.date}: ${dateLabel(context, date)}'),
                ),
                if (error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    context.errorMessage(error!),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                PrimaryButton(
                  label: tr(context, 'Conferma pagamento', 'Confirm payment'),
                  busy: busy,
                  onPressed: () async {
                    if (busy || !form.currentState!.validate()) return;
                    setState(() {
                      busy = true;
                      error = null;
                    });
                    try {
                      await ref
                          .read(scheduledExpensesProvider.notifier)
                          .pay(
                            widget.expense.id,
                            due: widget.expense.nextDue,
                            amount: Money.parse(
                              amount.text.trim().replaceAll(',', '.'),
                            ),
                            paidDate: date,
                            accountId: account,
                          );
                      if (!context.mounted) return;
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            tr(
                              context,
                              'Pagamento registrato. Prossima scadenza pronta.',
                              'Payment recorded. Next due date ready.',
                            ),
                          ),
                        ),
                      );
                    } catch (e) {
                      if (mounted) setState(() => error = e);
                    } finally {
                      if (mounted) setState(() => busy = false);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
