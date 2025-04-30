import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/services/notification_service.dart';
import 'package:expense_tracker/services/currency_service.dart';

class DatabaseService extends ChangeNotifier {
  late final Box<Expense> _expenseBox;
  late final Box<List<Expense>> _archiveBox;
  late final Box<double> _budgetBox; // New box for budget storage
  bool _isInitialized = false;
  final NotificationService _notificationService;
  final CurrencyService _currencyService;

  DatabaseService({
    required Box<Expense> expenseBox,
    required Box<List<Expense>> archiveBox,
    required Box<double> budgetBox,
    required NotificationService notificationService,
    required CurrencyService currencyService,
  }) : 
    _expenseBox = expenseBox,
    _archiveBox = archiveBox,
    _budgetBox = budgetBox,
    _notificationService = notificationService,
    _currencyService = currencyService {
    _isInitialized = true;
    _initializeServices();
  }

  Future<void> init() async {
    if (!_isInitialized) {
      _expenseBox = await Hive.openBox<Expense>('expenses');
      _archiveBox = await Hive.openBox<List<Expense>>('expenses_archive');
      _budgetBox = await Hive.openBox<double>('monthly_budget');
      _isInitialized = true;
      await _initializeServices();
    }
  }

  Future<void> _initializeServices() async {
    await _notificationService.initialize();
  }

  // Budget Management
  double get monthlyBudget => _budgetBox.get('current_budget', defaultValue: 1000.0) ?? 1000.0;

  Future<void> setMonthlyBudget(double amount) async {
    await _budgetBox.put('current_budget', amount);
    notifyListeners();
  }

  Future<void> addToBudget(double amount) async {
    final currentBudget = monthlyBudget;
    await _budgetBox.put('current_budget', currentBudget + amount);
    notifyListeners();
  }

  // Expense Management
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

  // Monthly Reset
  Future<void> resetForNewMonth() async {
    _checkInitialization();
    await _archiveCurrentMonthExpenses();
    await _expenseBox.clear();
    await _budgetBox.put('current_budget', 0.0); // Reset budget to 0
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

  // Analytics
  double get totalSpent {
    _checkInitialization();
    return _expenseBox.values.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  double get remainingBudget {
    _checkInitialization();
    return monthlyBudget - totalSpent;
  }

  double get budgetProgress {
    _checkInitialization();
    return monthlyBudget > 0 ? totalSpent / monthlyBudget : 0;
  }

  bool get isBudgetExceeded {
    _checkInitialization();
    return totalSpent > monthlyBudget;
  }

  bool get isApproachingBudget {
    _checkInitialization();
    return budgetProgress >= 0.8 && !isBudgetExceeded;
  }

  // Notifications
  Future<void> _checkBudgetAndNotify(BuildContext? context) async {
    _checkInitialization();
    
    if (isBudgetExceeded) {
      final overspendAmount = totalSpent - monthlyBudget;
      await _notificationService.showInstantNotification(
        title: 'Budget Exceeded!',
        body: 'You exceeded budget by ${_currencyService.formatAmount(overspendAmount)}',
      );
      
      if (context != null && context.mounted) {
        _showBudgetAlert(
          context, 
          'Budget Exceeded', 
          'You spent ${_currencyService.formatAmount(totalSpent)} of '
          '${_currencyService.formatAmount(monthlyBudget)} budget.'
        );
      }
    }
    else if (isApproachingBudget) {
      await _notificationService.showInstantNotification(
        title: 'Budget Warning',
        body: 'You used ${(budgetProgress * 100).toStringAsFixed(0)}% of your budget',
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

  // Helper Methods
  void _checkInitialization() {
    if (!_isInitialized) {
      throw Exception('DatabaseService not initialized. Call init() first.');
    }
  }

  // Cleanup
  @override
  Future<void> dispose() async {
    super.dispose();
    await _expenseBox.close();
    await _archiveBox.close();
    await _budgetBox.close();
  }
}