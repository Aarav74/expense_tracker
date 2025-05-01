import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/services/database_service.dart';

class BudgetHistoryScreen extends StatelessWidget {
  const BudgetHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // You'll need to implement budget addition history in your DatabaseService
    final db = Provider.of<DatabaseService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Additions History'),
      ),
      body: ListView.builder(
        itemCount: db.budgetHistory.length,
        itemBuilder: (context, index) {
          final entry = db.budgetHistory[index];
          return ListTile(
            title: Text('\$${entry.amount.toStringAsFixed(2)}'),
            subtitle: Text(entry.date.toString()),
          );
        },
      ),
    );
  }
}
