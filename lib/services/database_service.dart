import 'package:expense_tracker/models/budget_history_entry.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/services/currency_service.dart';
import 'package:expense_tracker/services/notification_service.dart';
import 'package:expense_tracker/services/sound_service.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class DatabaseService extends ChangeNotifier {
  late final Box<Expense> _expenseBox;
  late final Box<List<Expense>> _archiveBox;
  late final Box<double> _budgetBox;
  late final Box<BudgetHistoryEntry> _budgetHistoryBox;
  final List<BudgetHistoryEntry> _budgetHistory = [];
  bool _isInitialized = false;
  final NotificationService _notificationService;
  final CurrencyService _currencyService;
  final SoundService _soundService;

  DatabaseService({
    required Box<Expense> expenseBox,
    required Box<List<Expense>> archiveBox,
    required Box<double> budgetBox,
    required Box<BudgetHistoryEntry> budgetHistoryBox,
    required NotificationService notificationService,
    required CurrencyService currencyService,
    required SoundService soundService,
  })  : _expenseBox = expenseBox,
        _archiveBox = archiveBox,
        _budgetBox = budgetBox,
        _budgetHistoryBox = budgetHistoryBox,
        _notificationService = notificationService,
        _currencyService = currencyService,
        _soundService = soundService {
    _isInitialized = true;
    _initializeServices();
    _loadBudgetHistory();
  }

  Future<void> init() async {
    if (!_isInitialized) {
      _expenseBox = await Hive.openBox<Expense>('expenses');
      _archiveBox = await Hive.openBox<List<Expense>>('expenses_archive');
      _budgetBox = await Hive.openBox<double>('monthly_budget');
      _budgetHistoryBox = await Hive.openBox<BudgetHistoryEntry>('budget_history');
      _isInitialized = true;
      await _initializeServices();
      _loadBudgetHistory();
    }
  }

  Future<void> _initializeServices() async {
    await _notificationService.initialize();
    await _soundService.initialize();
  }

  void _loadBudgetHistory() {
    _budgetHistory.addAll(_budgetHistoryBox.values);
  }

  // Budget Management
  double get monthlyBudget => _budgetBox.get('current_budget', defaultValue: 1000.0) ?? 1000.0;

  List<BudgetHistoryEntry> get budgetHistory => _budgetHistory;

  Future<void> setMonthlyBudget(double amount, [String note = '']) async {
    await _budgetBox.put('current_budget', amount);
    final entry = BudgetHistoryEntry(amount, DateTime.now(), note);
    _budgetHistory.add(entry);
    await _budgetHistoryBox.add(entry);
    notifyListeners();
  }

  Future<void> addToBudget(double amount, [String note = '']) async {
    final currentBudget = monthlyBudget;
    final newAmount = currentBudget + amount;
    await _budgetBox.put('current_budget', newAmount);
    final entry = BudgetHistoryEntry(amount, DateTime.now(), note);
    _budgetHistory.add(entry);
    await _budgetHistoryBox.add(entry);
    await _soundService.playCoinSound();
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
    if (context != null && context.mounted) {
      await _checkBudgetAndNotify(context);
    }
  }

  Future<void> updateExpense(String id, Expense newExpense, {BuildContext? context}) async {
    _checkInitialization();
    final index = _expenseBox.values.toList().indexWhere((e) => e.id == id);
    if (index != -1) {
      await _expenseBox.putAt(index, newExpense);
      notifyListeners();
      if (context != null && context.mounted) {
        await _checkBudgetAndNotify(context);
      }
    }
  }

  Future<void> deleteExpense(String id, {BuildContext? context}) async {
    _checkInitialization();
    final index = _expenseBox.values.toList().indexWhere((e) => e.id == id);
    if (index != -1) {
      await _expenseBox.deleteAt(index);
      notifyListeners();
      if (context != null && context.mounted) {
        await _checkBudgetAndNotify(context);
      }
    }
  }

  // Monthly Reset
  Future<void> resetForNewMonth() async {
    _checkInitialization();
    await _archiveCurrentMonthExpenses();
    await _expenseBox.clear();
    await _budgetBox.put('current_budget', 0.0);
    await _budgetHistoryBox.clear();
    _budgetHistory.clear();
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

  get currencyService => null;

  // Notifications
  Future<void> _checkBudgetAndNotify(BuildContext context) async {
    _checkInitialization();
    
    if (isBudgetExceeded) {
      final overspendAmount = totalSpent - monthlyBudget;
      await _notificationService.showInstantNotification(
        title: 'Budget Exceeded!',
        body: 'You exceeded budget by ${_currencyService.formatAmount(overspendAmount)}',
      );
      
      if (context.mounted) {
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
    await _budgetHistoryBox.close();
    _soundService.dispose();
  }
}