import 'package:expense_tracker/services/currency_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BudgetProgressCard extends StatelessWidget {
  final double spentAmount;
  final double totalBudget;
  final CurrencyService currency;

  const BudgetProgressCard({
    super.key,
    required this.spentAmount,
    required this.totalBudget,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate budget metrics
    final progress = totalBudget > 0 ? (spentAmount / totalBudget).clamp(0.0, 1.0) : 0.0;
    final remaining = (totalBudget - spentAmount).clamp(0.0, totalBudget);
    final percentage = (progress * 100).toStringAsFixed(1);
    final isOverBudget = remaining < 0;

    // Determine colors based on budget status
    final progressColor = _getProgressColor(progress);
    final remainingColor = isOverBudget ? Colors.red : Colors.green;
    final remainingText = isOverBudget 
        ? 'Over by ${currency.formatAmount(-remaining)}'
        : currency.formatAmount(remaining);

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
            // Budget title and percentage
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
            
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: LinearProgressIndicator(
                value: progress > 1 ? 1 : progress,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation(progressColor),
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 12),
            
            // Budget metrics
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Spent amount
                _buildMetricColumn(
                  label: 'Spent',
                  value: currency.formatAmount(spentAmount),
                  color: Colors.black,
                ),
                
                // Remaining/Over budget
                _buildMetricColumn(
                  label: isOverBudget ? 'Over Budget' : 'Remaining',
                  value: remainingText,
                  color: remainingColor,
                ),
                
                // Total budget
                _buildMetricColumn(
                  label: 'Total Budget',
                  value: currency.formatAmount(totalBudget),
                  color: Colors.black,
                ),
              ],
            ),
            
            // Warning message if over budget
            if (isOverBudget) ...[
              const SizedBox(height: 12),
              Text(
                'You have exceeded your budget!',
                style: GoogleFonts.inter(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricColumn({
    required String label,
    required String value,
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
        const SizedBox(height: 4),
        Text(
          value,
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
    if (progress >= 1.0) return Colors.red;
    if (progress >= 0.8) return Colors.orange;
    if (progress >= 0.5) return Colors.blue;
    return Colors.green;
  }
}