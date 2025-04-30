import 'package:expense_tracker/screens/analytics_screen.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:intl/intl.dart';

class TransactionList extends StatelessWidget {
  final List<Expense> expenses;
  final void Function(Expense) onRemove;

  const TransactionList({
    super.key,
    required this.expenses,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return ListView.builder(
      shrinkWrap: true, // Add this
      physics: const NeverScrollableScrollPhysics(), // Add this
      itemCount: expenses.length,
      itemBuilder: (ctx, index) {
        final expense = expenses[index];
        final categoryColor = getCategoryColor(expense.category);

        return Container(
          margin: EdgeInsets.symmetric(
            horizontal: theme.cardTheme.margin?.horizontal ?? 16,
            vertical: 4,
          ),
          child: Dismissible(
            key: ValueKey(expense.id),
            background: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.error,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(
                Icons.delete,
                color: Colors.white,
                size: 30,
              ),
            ),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) => onRemove(expense),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    // ignore: deprecated_member_use
                    backgroundColor: categoryColor.withOpacity(0.2),
                    child: Icon(
                      _getCategoryIcon(expense.category),
                      color: categoryColor,
                    ),
                  ),
                  title: Text(
                    expense.category,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (expense.location != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                expense.location!,
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      Text(
                        DateFormat.yMMMd().format(expense.date),
                        style: theme.textTheme.bodySmall,
                      ),
                      if (expense.description != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            expense.description!,
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '-${currencyFormat.format(expense.amount)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (expense.date.isToday())
                        Text(
                          'Today',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.fastfood;
      case 'transport':
        return Icons.directions_car;
      case 'entertainment':
        return Icons.movie;
      case 'bills':
        return Icons.receipt;
      case 'shopping':
        return Icons.shopping_bag;
      case 'healthcare':
        return Icons.medical_services;
      case 'education':
        return Icons.school;
      default:
        return Icons.money;
    }
  }
}

extension DateExtensions on DateTime {
  bool isToday() {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
}