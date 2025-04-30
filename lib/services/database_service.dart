import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/services/notification_service.dart';

class DatabaseService extends ChangeNotifier {
  late final Box<Expense> _expenseBox;
  late final Box<List<Expense>> _archiveBox; // For archiving
  double _monthlyLimit = 1000.0;
  bool _isInitialized = false;
  final NotificationService _notificationService = NotificationService();

  /// Initialize with required Hive boxes
  DatabaseService({
    required Box<Expense> expenseBox,
    required Box<List<Expense>> archiveBox,
  }) {
    _expenseBox = expenseBox;
    _archiveBox = archiveBox;
    _isInitialized = true;
    _initializeNotificationService();
  }

  /// Async initialization alternative
  Future<void> init() async {
    if (!_isInitialized) {
      _expenseBox = await Hive.openBox<Expense>('expenses');
      _archiveBox = await Hive.openBox<List<Expense>>('expenses_archive');
      _isInitialized = true;
      await _initializeNotificationService();
    }
  }

  Future<void> _initializeNotificationService() async {
    await _notificationService.initialize();
  }

  // Check initialization status
  bool get isInitialized => _isInitialized;

  // Monthly budget methods
  double get monthlyLimit => _monthlyLimit;

  set monthlyLimit(double value) {
    _monthlyLimit = value;
    notifyListeners();
  }

  // Expense methods
  List<Expense> get expenses {
    _checkInitialization();
    return _expenseBox.values.toList();
  }

  List<Expense> getRecentExpenses([int limit = 5]) {
    _checkInitialization();
    final allExpenses = _expenseBox.values.toList();
    allExpenses.sort((a, b) => b.date.compareTo(a.date));
    return allExpenses.take(limit).toList();
  }

  Future<void> addExpense(Expense expense, {BuildContext? context}) async {
    _checkInitialization();
    await _expenseBox.add(expense);
    notifyListeners();
    // ignore: use_build_context_synchronously
    await _checkBudgetAndNotify(context);
  }

  Future<void> updateExpense(String id, Expense newExpense, {BuildContext? context}) async {
    _checkInitialization();
    final index = _expenseBox.values.toList().indexWhere((e) => e.id == id);
    if (index != -1) {
      await _expenseBox.putAt(index, newExpense);
      notifyListeners();
      // ignore: use_build_context_synchronously
      await _checkBudgetAndNotify(context);
    }
  }

  Future<void> deleteExpense(String id, {BuildContext? context}) async {
    _checkInitialization();
    final index = _expenseBox.values.toList().indexWhere((e) => e.id == id);
    if (index != -1) {
      await _expenseBox.deleteAt(index);
      notifyListeners();
      // ignore: use_build_context_synchronously
      await _checkBudgetAndNotify(context);
    }
  }

  // Reset functionality
  Future<void> resetForNewMonth() async {
    _checkInitialization();
    await _archiveCurrentMonthExpenses();
    await _expenseBox.clear();
    notifyListeners();
  }

  Future<void> _archiveCurrentMonthExpenses() async {
    final now = DateTime.now();
    final currentMonthExpenses = expenses.where((expense) {
      return expense.date.month == now.month && expense.date.year == now.year;
    }).toList();

    if (currentMonthExpenses.isNotEmpty) {
      final monthYear = '${now.month}-${now.year}';
      await _archiveBox.put(monthYear, currentMonthExpenses);
    }
  }

  Future<List<Expense>> getArchivedExpenses(String monthYear) async {
    _checkInitialization();
    return _archiveBox.get(monthYear, defaultValue: []) ?? [];
  }

  Future<void> clearAll() async {
    _checkInitialization();
    await _expenseBox.clear();
    await _archiveBox.clear();
    notifyListeners();
  }

  // Analytics methods
  double get totalSpent {
    _checkInitialization();
    return _expenseBox.values.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  double get remainingBudget {
    _checkInitialization();
    return _monthlyLimit - totalSpent;
  }

  Map<String, double> get categoryWiseExpenses {
    _checkInitialization();
    final Map<String, double> result = {};
    for (var expense in _expenseBox.values) {
      result.update(
        expense.category,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }
    return result;
  }

  Map<DateTime, double> get dailyExpenses {
    _checkInitialization();
    final Map<DateTime, double> result = {};
    for (var expense in _expenseBox.values) {
      final date = DateTime(expense.date.year, expense.date.month, expense.date.day);
      result.update(
        date,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }
    return result;
  }

  double get budgetProgress {
    _checkInitialization();
    return totalSpent / _monthlyLimit;
  }

  bool get isBudgetExceeded {
    _checkInitialization();
    return totalSpent > _monthlyLimit;
  }

  bool get isApproachingBudget {
    _checkInitialization();
    return budgetProgress >= 0.8 && !isBudgetExceeded;
  }

  // Notification handling
  Future<void> _checkBudgetAndNotify(BuildContext? context) async {
    _checkInitialization();
    
    if (isBudgetExceeded) {
      await _notificationService.showInstantNotification(
        title: 'Budget Exceeded!',
        body: 'You have exceeded your monthly budget by \$${(totalSpent - _monthlyLimit).toStringAsFixed(2)}',
      );
      
      if (context != null && context.mounted) {
        _showBudgetAlert(context, 'Budget Exceeded', 
          'You have spent \$${totalSpent.toStringAsFixed(2)} this month, exceeding your \$${_monthlyLimit.toStringAsFixed(2)} budget.');
      }
    }
    else if (isApproachingBudget) {
      await _notificationService.showInstantNotification(
        title: 'Budget Warning',
        body: 'You have used ${(budgetProgress * 100).toStringAsFixed(0)}% of your monthly budget',
      );
    }
  }

  void _showBudgetAlert(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Initialization check
  void _checkInitialization() {
    if (!_isInitialized) {
      throw Exception('DatabaseService not initialized. Call init() first.');
    }
  }
}