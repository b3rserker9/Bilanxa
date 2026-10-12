import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../features/transactions/domain/models.dart';
import '../error/app_exception.dart';
import '../utils/money.dart';
import '../config/config.dart';

import 'package:intl/intl.dart';

extension LocalizedContext on BuildContext {
  AppLocalizations get l => AppLocalizations.of(this)!;
  String errorMessage(Object error) {
    final kind = error is AppException ? error.kind : Failure.server;
    return switch (kind) {
      Failure.network => l.networkError,
      Failure.unauthorized => l.unauthorized,
      Failure.forbidden => l.forbidden,
      Failure.validation => l.validationError,
      Failure.configuration => l.configurationError,
      Failure.contract => l.contractError,
      Failure.auth => l.authError,
      Failure.server => l.genericError,
    };
  }
}

class BilanqoScaffold extends StatelessWidget {
  const BilanqoScaffold({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.floatingActionButton,
    this.showHeader = true,
    this.showMockBanner = true,
  });
  final String title;
  final Widget child;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final bool showHeader, showMockBanner;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: showHeader
        ? AppBar(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const BrandMark(size: 30),
                const SizedBox(width: 8),
                Text(title),
              ],
            ),
            actions: actions,
          )
        : null,
    floatingActionButton: floatingActionButton == null
        ? null
        : Padding(
            padding: const EdgeInsets.only(bottom: 88),
            child: floatingActionButton,
          ),
    body: SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: Tokens.maxWidth),
          child: ListView(
            padding: const EdgeInsets.all(Tokens.page),
            children: [
              if (showMockBanner && Config.mockApi && Config.mocksAllowed) ...[
                Card(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(Tokens.small),
                    child: Text(
                      context.l.mockMode,
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: Tokens.gap),
              ],
              child,
              const SizedBox(height: Tokens.page * 3),
            ],
          ),
        ),
      ),
    ),
  );
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.busy = false,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool busy;
  @override
  Widget build(BuildContext context) => FilledButton(
    onPressed: busy ? null : onPressed,
    child: busy
        ? SizedBox.square(
            dimension: Tokens.page,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              semanticsLabel: context.l.loading,
            ),
          )
        : Text(label),
  );
}

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(Tokens.page),
    child: Center(
      child: CircularProgressIndicator(semanticsLabel: context.l.loading),
    ),
  );
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.message,
    this.icon = Icons.receipt_long_outlined,
    this.action,
  });
  final String message;
  final IconData icon;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(Tokens.page),
      child: Column(
        children: [
          Icon(
            icon,
            size: Tokens.fieldHeight,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: Tokens.gap),
          Text(message, textAlign: TextAlign.center),
          if (action != null) ...[const SizedBox(height: Tokens.gap), action!],
        ],
      ),
    ),
  );
}

class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.error, required this.retry});
  final Object error;
  final VoidCallback retry;
  @override
  Widget build(BuildContext context) => EmptyState(
    message: context.errorMessage(error),
    icon: Icons.cloud_off_outlined,
    action: OutlinedButton(onPressed: retry, child: Text(context.l.retry)),
  );
}

class AsyncSection<T> extends StatelessWidget {
  const AsyncSection({
    super.key,
    required this.value,
    required this.retry,
    required this.builder,
  });
  final AsyncValue<T> value;
  final VoidCallback retry;
  final Widget Function(T) builder;
  @override
  Widget build(BuildContext context) => value.when(
    skipLoadingOnRefresh: false,
    data: builder,
    error: (e, _) => ErrorState(error: e, retry: retry),
    loading: () => const LoadingIndicator(),
  );
}

class AmountText extends StatelessWidget {
  const AmountText(this.amount, {super.key, this.style, this.color});
  final Money amount;
  final TextStyle? style;
  final Color? color;
  @override
  Widget build(BuildContext context) => Text(
    displayMoney(amount, Localizations.localeOf(context).toString()),
    style: (style ?? Theme.of(context).textTheme.titleLarge)?.copyWith(
      color: color,
    ),
  );
}

String displayMoney(Money amount, String locale) {
  final formatted = amount.format(locale).replaceAll(' €', '');
  return formatted.startsWith('−')
      ? '− € ${formatted.substring(1)}'
      : '€ $formatted';
}

class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key, required this.amount, this.footer});
  final Money amount;
  final Widget? footer;
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(28),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Tokens.primaryDark,
          Color(0xFF135342),
          Tokens.primaryContainer,
        ],
      ),
      boxShadow: const [
        BoxShadow(
          color: Color(0x25103F34),
          blurRadius: 24,
          offset: Offset(0, 8),
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.all(Tokens.page),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l.balance,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: Tokens.small),
          AmountText(
            amount,
            style: Theme.of(context).textTheme.headlineLarge,
            color: Colors.white,
          ),
          const SizedBox(height: 8),
          Text(
            context.l.accounts,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          if (footer != null) ...[const SizedBox(height: 20), footer!],
        ],
      ),
    ),
  );
}

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.label,
    required this.amount,
    required this.icon,
  });
  final String label;
  final Money amount;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Card(
    color: Theme.of(context).colorScheme.surfaceContainerLow,
    child: Padding(
      padding: const EdgeInsets.all(Tokens.gap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: icon == Icons.north_east
                ? Theme.of(context).colorScheme.error
                : Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: Tokens.small),
          Text(label),
          const SizedBox(height: Tokens.small),
          AmountText(
            amount,
            style: Theme.of(context).textTheme.titleMedium,
            color: icon == Icons.north_east
                ? Theme.of(context).colorScheme.error
                : Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    ),
  );
}

class TransactionTile extends StatelessWidget {
  const TransactionTile({super.key, required this.movement});
  final Movement movement;
  @override
  Widget build(BuildContext context) {
    final income = movement.type == MovementType.income;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final color = dark
        ? (income ? Tokens.incomeDark : Tokens.expenseDark)
        : (income ? Tokens.primary : Theme.of(context).colorScheme.secondary);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: dark
                  ? color.withValues(alpha: 0.12)
                  : (income
                        ? Tokens.mint.withValues(alpha: .5)
                        : Tokens.secondaryContainer.withValues(alpha: .6)),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              income ? Icons.south_west : Icons.receipt_long_outlined,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movement.description,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '${income ? context.l.income : context.l.expense} · ${DateFormat.yMMMd(Localizations.localeOf(context).toString()).format(movement.date)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              '${income ? '+' : '−'} ${displayMoney(movement.amount, Localizations.localeOf(context).toString())}',
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: income ? color : Theme.of(context).colorScheme.onSurface,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 64});
  final double size;
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: Tokens.primaryDark,
      borderRadius: BorderRadius.circular(size * .28),
    ),
    child: Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          left: size * .22,
          child: Container(
            width: size * .4,
            height: size * .4,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Tokens.primary,
            ),
          ),
        ),
        Positioned(
          right: size * .22,
          child: Container(
            width: size * .4,
            height: size * .4,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Tokens.mint,
            ),
          ),
        ),
      ],
    ),
  );
}
