// lib/services/analytics_service.dart
import 'package:flutter/material.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:intl/intl.dart';

class AnalyticsService {
  // Calculate category totals with percentages
  Map<String, Map<String, dynamic>> calculateCategoryTotals(List<Expense> expenses) {
    final Map<String, double> categoryAmounts = {};
    double totalSpent = 0.0;

    // Calculate total amounts per category and overall total
    for (var expense in expenses) {
      categoryAmounts.update(
        expense.category,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
      totalSpent += expense.amount;
    }

    // Convert to map with percentage and color
    final result = <String, Map<String, dynamic>>{};
    categoryAmounts.forEach((category, amount) {
      result[category] = {
        'amount': amount,
        'percentage': totalSpent > 0 ? (amount / totalSpent) * 100 : 0.0,
        'color': _getCategoryColor(category),
      };
    });

    // Sort by amount descending
    final sortedEntries = result.entries.toList()
      ..sort((a, b) => b.value['amount'].compareTo(a.value['amount']));
    
    return Map.fromEntries(sortedEntries);
  }

  // Calculate time-based data for different periods
  Map<String, double> calculateTimeData(List<Expense> expenses, int timeFrame) {
    final now = DateTime.now();
    final Map<String, double> result = {};

    switch (timeFrame) {
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
    }

    return result;
  }

  // Calculate average spending based on time frame
  double calculateAverageSpending(List<Expense> expenses, int timeFrame) {
    if (expenses.isEmpty) return 0.0;

    switch (timeFrame) {
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

  // Filter expenses by time frame
  List<Expense> filterExpensesByTimeFrame(List<Expense> expenses, int timeFrame) {
    final now = DateTime.now();
    switch (timeFrame) {
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

  // Consistent color generator for categories
  Color _getCategoryColor(String category) {
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
}