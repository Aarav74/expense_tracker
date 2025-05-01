import 'package:expense_tracker/services/currency_service.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:intl/intl.dart';

class TransactionList extends StatelessWidget {
  final List<Expense> expenses;
  final CurrencyService currency;
  final void Function(Expense)? onRemove;
  final bool showDelete;

  const TransactionList({
    super.key,
    required this.expenses,
    required this.currency,
    this.onRemove,
    this.showDelete = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: expenses.length,
      itemBuilder: (ctx, index) {
        final expense = expenses[index];
        final categoryColor = _getCategoryColor(expense.category);

        return Container(
          margin: EdgeInsets.symmetric(
            horizontal: theme.cardTheme.margin?.horizontal ?? 16,
            vertical: 4,
          ),
          child: showDelete && onRemove != null
              ? Dismissible(
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
                  onDismissed: (direction) => onRemove!(expense),
                  child: _buildExpenseCard(expense, categoryColor, theme),
                )
              : _buildExpenseCard(expense, categoryColor, theme),
        );
      },
    );
  }

  Widget _buildExpenseCard(Expense expense, Color categoryColor, ThemeData theme) {
    return Card(
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
                '-${currency.formatAmount(expense.amount)}',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_isToday(expense.date))
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
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
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

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Colors.orange;
      case 'transport':
        return Colors.blue;
      case 'entertainment':
        return Colors.purple;
      case 'bills':
        return Colors.red;
      case 'shopping':
        return Colors.teal;
      case 'healthcare':
        return Colors.pink;
      case 'education':
        return Colors.indigo;
      default:
        return Colors.green;
    }
  }
}