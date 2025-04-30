import 'package:intl/intl.dart';

String formatCurrency(double amount) {
  return NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 2,
  ).format(amount);
}

String formatDate(DateTime date) {
  return DateFormat('MMM d, y').format(date);
}