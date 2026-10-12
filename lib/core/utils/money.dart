import 'package:intl/intl.dart';

/// Exact cents for the initial EUR UI. No floating point conversions.
class Money {
  const Money(this.cents);
  final BigInt cents;
  factory Money.parse(String value) {
    if (!RegExp(r'^-?\d+(\.\d{1,2})?$').hasMatch(value)) {
      throw const FormatException('Invalid decimal');
    }
    final parts = value.replaceFirst('-', '').split('.');
    final minor = parts.length == 2 ? parts[1].padRight(2, '0') : '00';
    final cents =
        BigInt.parse(parts[0]) * BigInt.from(100) + BigInt.parse(minor);
    return Money(value.startsWith('-') ? -cents : cents);
  }
  String get decimal {
    final absolute = cents.abs();
    return '${cents.isNegative ? '-' : ''}${absolute ~/ BigInt.from(100)}.${(absolute % BigInt.from(100)).toString().padLeft(2, '0')}';
  }

  String format(String locale) {
    final symbols = NumberFormat.decimalPattern(locale).symbols;
    final parts = decimal.replaceFirst('-', '').split('.');
    final grouped = parts[0].replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'),
      (m) => '${m[1]}${symbols.GROUP_SEP}',
    );
    return '${cents.isNegative ? '−' : ''}$grouped${symbols.DECIMAL_SEP}${parts[1]} €';
  }
}
