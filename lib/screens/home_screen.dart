import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/services/database_service.dart';
import 'package:expense_tracker/services/currency_service.dart';
import 'package:expense_tracker/services/sound_service.dart';
import 'package:expense_tracker/widgets/budget_progress_card.dart';
import 'package:expense_tracker/widgets/transaction_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize sound service when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final soundService = Provider.of<SoundService>(context, listen: false);
      await soundService.initialize();
      debugPrint('Sound service initialized');
    });
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<DatabaseService>(context);
    final currency = Provider.of<CurrencyService>(context);
    final soundService = Provider.of<SoundService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.attach_money),
            tooltip: 'Add to Budget',
            onPressed: () => _showAddToBudgetDialog(context, db, currency, soundService),
          ),
          IconButton(
            icon: const Icon(Icons.currency_exchange),
            tooltip: 'Change Currency',
            onPressed: () => _showCurrencyDialog(context, currency),
          ),
          IconButton(
            icon: const Icon(Icons.restart_alt),
            tooltip: 'Reset for new month',
            onPressed: () => _showResetConfirmationDialog(context, db),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return RefreshIndicator(
            onRefresh: () async {
              final _ = db.expenses;
              await Future.delayed(const Duration(milliseconds: 300));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    BudgetProgressCard(
                      spentAmount: db.totalSpent,
                      totalBudget: db.monthlyBudget,
                      currency: currency,
                    ),
                    const SizedBox(height: 16),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Recent Transactions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    TransactionList(
                      expenses: db.getRecentExpenses(),
                      currency: currency,
                      onRemove: (expense) async {
                        try {
                          await db.deleteExpense(expense.id);
                        } catch (e) {
                          if (!mounted) return;
                          // ignore: use_build_context_synchronously
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to delete: ${e.toString()}'),
                            ),
                          );
                        }
                      },
                    ),
                    SizedBox(height: MediaQuery.of(context).padding.bottom + 80),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.pushNamed(context, '/add-expense'),
      ),
    );
  }

  Future<void> _showAddToBudgetDialog(
    BuildContext context,
    DatabaseService db,
    CurrencyService currency,
    SoundService soundService,
  ) async {
    final amountController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add to Monthly Budget'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount to Add',
                prefixText: currency.currencySymbol,
                hintText: 'Enter amount',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text) ?? 0;
              if (amount > 0) {
                try {
                  await db.addToBudget(amount);
                  await soundService.playCoinSound();
                  if (!mounted) return;
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${currency.formatAmount(amount)} added to monthly budget!',
                      ),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to add to budget: ${e.toString()}'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } else {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid positive amount'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _showCurrencyDialog(
    BuildContext context,
    CurrencyService currency,
  ) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Currency'),
        content: SizedBox(
          width: double.minPositive,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: currency.availableCurrencies.length,
            itemBuilder: (context, index) {
              final code = currency.availableCurrencies[index];
              return ListTile(
                title: Text(code),
                trailing: currency.currentCurrency == code
                    ? const Icon(Icons.check)
                    : null,
                onTap: () {
                  currency.setCurrency(code);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _showResetConfirmationDialog(
    BuildContext context,
    DatabaseService db,
  ) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reset Expenses'),
          content: const Text(
              'Are you sure you want to reset all expenses and budget for the new month? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Reset', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                try {
                  await db.resetForNewMonth();
                  if (!mounted) return;
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop();
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Expenses and budget reset for new month'),
                      duration: Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop();
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to reset: ${e.toString()}'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}