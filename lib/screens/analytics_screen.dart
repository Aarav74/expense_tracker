import 'package:expense_tracker/models/expense.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/widgets/category_chip.dart';
import 'package:expense_tracker/services/database_service.dart';
import 'package:expense_tracker/services/currency_service.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

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
  
  final index = category.hashCode % colors.length;
  return colors[index.abs()];
}

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int _selectedTimeFrame = 0; // 0=All, 1=Weekly, 2=Monthly, 3=Yearly
  final List<String> _timeFrames = ['All', 'Weekly', 'Monthly', 'Yearly'];

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<DatabaseService>(context);
    final currencyService = Provider.of<CurrencyService>(context, listen: false);
    final expenses = _filterExpensesByTimeFrame(db.expenses);
    final categoryTotals = _calculateCategoryTotals(expenses);
    final timeData = _calculateTimeData(expenses);
    final averageSpending = _calculateAverageSpending(expenses);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Analytics'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time frame selector
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_timeFrames.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(_timeFrames[index]),
                      selected: _selectedTimeFrame == index,
                      onSelected: (selected) {
                        setState(() {
                          _selectedTimeFrame = selected ? index : 0;
                        });
                      },
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),

            // Summary cards
            Row(
              children: [
                _buildSummaryCard(
                  'Total',
                  currencyService.formatAmount(categoryTotals.values.fold(0.0, (sum, amount) => sum + amount)),
                  Colors.blue,
                ),
                const SizedBox(width: 8),
                _buildSummaryCard(
                  'Average',
                  currencyService.formatAmount(averageSpending),
                  Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Time-based chart
            const Text(
              'Spending Trend',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 200,
              child: _buildTimeChart(timeData, currencyService),
            ),
            const SizedBox(height: 16),

            // Category breakdown
            const Text(
              'Category Breakdown',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: categoryTotals.entries.map((entry) {
                    final percentage = categoryTotals.values.fold(0.0, (sum, amount) => sum + amount) > 0
                        ? (entry.value / categoryTotals.values.fold(0.0, (sum, amount) => sum + amount)) * 100
                        : 0.0;
                    
                    return CategoryChip(
                      category: entry.key,
                      amount: entry.value,
                      color: getCategoryColor(entry.key),
                      percentage: '${percentage.toStringAsFixed(1)}%',
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

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Expanded(
      child: Card(
        // ignore: deprecated_member_use
        color: color.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeChart(Map<String, double> timeData, CurrencyService currencyService) {
    final barGroups = timeData.entries.map((entry) {
      return BarChartGroupData(
        x: timeData.keys.toList().indexOf(entry.key),
        barRods: [
          BarChartRodData(
            toY: entry.value,
            color: Colors.blue,
            width: 16,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final period = timeData.keys.elementAt(group.x);
              return BarTooltipItem(
                '$period\n${currencyService.formatAmount(rod.toY)}',
                const TextStyle(color: Colors.white),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final label = timeData.keys.elementAt(value.toInt());
                return Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                );
              },
              reservedSize: 28,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: barGroups,
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
    // Sort by amount descending
    final sortedEntries = result.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sortedEntries);
  }

  Map<String, double> _calculateTimeData(List<Expense> expenses) {
    final now = DateTime.now();
    final Map<String, double> result = {};

    switch (_selectedTimeFrame) {
      case 1: // Weekly
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        for (int i = 0; i < 7; i++) {
          final day = weekStart.add(Duration(days: i));
          final dayExpenses = expenses.where((e) =>
              e.date.year == day.year &&
              e.date.month == day.month &&
              e.date.day == day.day);
          final total = dayExpenses.fold(0.0, (sum, e) => sum + e.amount);
          result[DateFormat.E().format(day)] = total;
        }
        break;
      case 2: // Monthly
        final firstDay = DateTime(now.year, now.month, 1);
        final lastDay = DateTime(now.year, now.month + 1, 0);
        for (int i = 0; i < lastDay.day; i++) {
          final day = firstDay.add(Duration(days: i));
          final dayExpenses = expenses.where((e) =>
              e.date.year == day.year &&
              e.date.month == day.month &&
              e.date.day == day.day);
          final total = dayExpenses.fold(0.0, (sum, e) => sum + e.amount);
          result['${i + 1}'] = total;
        }
        break;
      case 3: // Yearly
        for (int i = 0; i < 12; i++) {
          final month = DateTime(now.year, i + 1);
          final monthExpenses = expenses.where((e) =>
              e.date.year == month.year && e.date.month == month.month);
          final total = monthExpenses.fold(0.0, (sum, e) => sum + e.amount);
          result[DateFormat.MMM().format(month)] = total;
        }
        break;
      default: // All time
        final allExpensesByMonth = <DateTime, List<Expense>>{};
        for (var expense in expenses) {
          final monthStart = DateTime(expense.date.year, expense.date.month);
          allExpensesByMonth.putIfAbsent(monthStart, () => []).add(expense);
        }
        for (var entry in allExpensesByMonth.entries) {
          final total = entry.value.fold(0.0, (sum, e) => sum + e.amount);
          result[DateFormat.yMMM().format(entry.key)] = total;
        }
        break;
    }

    return result;
  }

  double _calculateAverageSpending(List<Expense> expenses) {
    if (expenses.isEmpty) return 0.0;

    switch (_selectedTimeFrame) {
      case 1: // Weekly average per day
        return expenses.fold(0.0, (sum, e) => sum + e.amount) / 7;
      case 2: // Monthly average per day
        final now = DateTime.now();
        final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
        return expenses.fold(0.0, (sum, e) => sum + e.amount) / daysInMonth;
      case 3: // Yearly average per month
        return expenses.fold(0.0, (sum, e) => sum + e.amount) / 12;
      default: // All time average per month
        final allExpensesByMonth = <DateTime, List<Expense>>{};
        for (var expense in expenses) {
          final monthStart = DateTime(expense.date.year, expense.date.month);
          allExpensesByMonth.putIfAbsent(monthStart, () => []).add(expense);
        }
        return allExpensesByMonth.isEmpty
            ? 0.0
            : expenses.fold(0.0, (sum, e) => sum + e.amount) / allExpensesByMonth.length;
    }
  }

  List<Expense> _filterExpensesByTimeFrame(List<Expense> expenses) {
    final now = DateTime.now();
    switch (_selectedTimeFrame) {
      case 1: // Weekly
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        return expenses.where((e) => e.date.isAfter(weekStart)).toList();
      case 2: // Monthly
        final monthStart = DateTime(now.year, now.month, 1);
        return expenses.where((e) => e.date.isAfter(monthStart)).toList();
      case 3: // Yearly
        final yearStart = DateTime(now.year, 1, 1);
        return expenses.where((e) => e.date.isAfter(yearStart)).toList();
      default: // All time
        return expenses;
    }
  }
}