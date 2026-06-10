import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static final _currencyFormatter = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 2,
  );

  static final _compactFormatter = NumberFormat.compact();

  static final _dateFormatter = DateFormat('MMM dd, yyyy');
  static final _shortDateFormatter = DateFormat('MMM dd');
  static final _monthFormatter = DateFormat('MMM');

  static String currency(double value) {
    if (value % 1 == 0) {
      return NumberFormat.currency(
        symbol: '\$',
        decimalDigits: 0,
      ).format(value);
    }
    return _currencyFormatter.format(value);
  }

  static String compactNumber(num value) => _compactFormatter.format(value);

  static String date(DateTime date) => _dateFormatter.format(date);

  static String shortDate(DateTime date) => _shortDateFormatter.format(date);

  static String month(DateTime date) => _monthFormatter.format(date);

  static String monthFromInt(int month) {
    final date = DateTime(2024, month);
    return DateFormat('MMMM').format(date);
  }

  /// Short 3-letter month name, e.g. "Jan", "Feb"
  static String monthShort(int month) {
    final date = DateTime(2024, month);
    return _monthFormatter.format(date);
  }

  /// Compact currency for chart axis, e.g. "$13K", "$1.5M"
  static String compactCurrency(double value) {
    if (value >= 1000000) {
      return '\$${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '\$${(value / 1000).toStringAsFixed(0)}K';
    }
    return '\$${value.toStringAsFixed(0)}';
  }

  /// e.g. "+12.4%" or "-3.2%"
  static String growthRate(double rate) {
    final sign = rate >= 0 ? '+' : '';
    return '$sign${rate.toStringAsFixed(1)}%';
  }

  static String initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}
