import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BudgetProgressCard extends StatelessWidget {
  final double spentAmount;
  final double totalBudget;

  const BudgetProgressCard({
    super.key,
    required this.spentAmount,
    required this.totalBudget,
  });

  @override
  Widget build(BuildContext context) {
    // Handle division by zero and negative values
    final progress = totalBudget > 0 ? (spentAmount / totalBudget).clamp(0.0, 1.0) : 0.0;
    final remaining = (totalBudget - spentAmount).clamp(0.0, totalBudget);
    final percentage = (progress * 100).toStringAsFixed(1);

    // Determine colors based on budget usage
    final progressColor = _getProgressColor(progress);
    final remainingColor = remaining < 0 ? Colors.red : Colors.green;

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Monthly Budget',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$percentage% spent',
                  style: GoogleFonts.inter(
                    color: progressColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation(progressColor),
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildAmountColumn(
                  label: 'Spent',
                  amount: spentAmount,
                  color: Colors.black,
                ),
                _buildAmountColumn(
                  label: 'Remaining',
                  amount: remaining,
                  color: remainingColor,
                ),
                _buildAmountColumn(
                  label: 'Total',
                  amount: totalBudget,
                  color: Colors.black,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountColumn({
    required String label,
    required double amount,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Color _getProgressColor(double progress) {
    if (progress >= 0.9) return Colors.red;
    if (progress >= 0.7) return Colors.orange;
    return Colors.blueAccent;
  }
}