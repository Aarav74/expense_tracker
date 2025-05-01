import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/services/database_service.dart';
import 'package:expense_tracker/services/currency_service.dart';
import 'package:expense_tracker/widgets/transaction_list.dart';

class SpendingHistoryScreen extends StatelessWidget {
  const SpendingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<DatabaseService>(context);
    final currency = Provider.of<CurrencyService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spending History'),
      ),
      body: TransactionList(
        expenses: db.expenses,
        currency: currency,  // Pass the currency service
        onRemove: (expense) {}, showDelete: false,      // Disable delete functionality
      ),
    );
  }
}