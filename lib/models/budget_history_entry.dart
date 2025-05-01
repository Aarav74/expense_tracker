import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

part 'budget_history_entry.g.dart';

@HiveType(typeId: 2)
class BudgetHistoryEntry {
  @HiveField(0)
  final double amount;
  
  @HiveField(1)
  final DateTime date;
  
  @HiveField(2)
  final String note;

  BudgetHistoryEntry(this.amount, this.date, [this.note = '']);

  String formattedDate() {
    return DateFormat.yMMMd().add_jm().format(date);
  }

  // Optional: Add a formatted amount string if needed
  String formattedAmount([String? currencySymbol]) {
    final formatter = NumberFormat.currency(
      symbol: currencySymbol ?? '',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  // Optional: Add equality comparison
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BudgetHistoryEntry &&
        other.amount == amount &&
        other.date == date &&
        other.note == note;
  }

  // Optional: Override hashCode
  @override
  int get hashCode => amount.hashCode ^ date.hashCode ^ note.hashCode;

  // Optional: Add copyWith method for easy modifications
  BudgetHistoryEntry copyWith({
    double? amount,
    DateTime? date,
    String? note,
  }) {
    return BudgetHistoryEntry(
      amount ?? this.amount,
      date ?? this.date,
      note ?? this.note,
    );
  }
}