import 'package:expense_tracker/models/expense.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/widgets/expense_chart.dart';
import 'package:expense_tracker/widgets/category_chip.dart';
import 'package:expense_tracker/services/database_service.dart';
import 'package:provider/provider.dart';

// Consistent color generator for categories
Color getCategoryColor(String category) {
  const colors = [
    Colors.green,
    Colors.blue,
    Colors.purple,
    Colors.orange,
    Colors.pink,
    Colors.red,
    Colors.indigo,
    Colors.teal,
  ];
  
  // Ensure consistent color for same category
  final index = category.hashCode % colors.length;
  return colors[index.abs()];
}

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<DatabaseService>(context);
    final expenses = db.expenses;
    final categoryTotals = _calculateCategoryTotals(expenses);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Analytics'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Spending Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: ExpenseChart(categoryData: categoryTotals),
            ),
            const SizedBox(height: 24),
            const Text(
              'Category Breakdown',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: categoryTotals.entries.map((entry) {
                    return CategoryChip(
                      category: entry.key,
                      amount: entry.value,
                      color: getCategoryColor(entry.key), percentage: '',
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, double> _calculateCategoryTotals(List<Expense> expenses) {
    final Map<String, double> result = {};
    for (var expense in expenses) {
      result.update(
        expense.category,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }
    return result;
  }
}