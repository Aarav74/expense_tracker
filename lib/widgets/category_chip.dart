import 'package:flutter/material.dart';
import 'package:expense_tracker/utils/constants.dart';
import 'package:expense_tracker/services/currency_service.dart';
import 'package:provider/provider.dart';

class CategoryChip extends StatelessWidget {
  final String category;
  final double amount;
  final Color color;
  final String percentage;
  final TextStyle? textStyle;

  const CategoryChip({
    super.key,
    required this.category,
    required this.amount,
    required this.color,
    required this.percentage,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyService = Provider.of<CurrencyService>(context, listen: false);
    final formattedAmount = currencyService.formatAmount(amount);
    
    return Chip(
      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
      label: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            category,
            style: textStyle ?? theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                formattedAmount,
                style: textStyle ?? theme.textTheme.bodySmall?.copyWith(
                  // ignore: deprecated_member_use
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                percentage,
                style: textStyle ?? theme.textTheme.bodySmall?.copyWith(
                  // ignore: deprecated_member_use
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ],
      ),
      // ignore: deprecated_member_use
      backgroundColor: color.withOpacity(0.15),
      avatar: CircleAvatar(
        // ignore: deprecated_member_use
        backgroundColor: color.withOpacity(0.3),
        radius: 12,
        child: Text(
          category.isNotEmpty ? category[0].toUpperCase() : '?',
          style: TextStyle(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      visualDensity: VisualDensity.compact,
    );
  }
}

// Helper function to get category color
Color getCategoryColor(String category, dynamic kCategoryNames) {
  // Handle empty or null category
  if (category.isEmpty) {
    return kCategoryColors.last;
  }

  // Convert to lowercase for case-insensitive comparison
  final lowerCategory = category.toLowerCase();

  // Find the color based on category
  for (int i = 0; i < kCategoryNames.length; i++) {
    // ignore: prefer_typing_uninitialized_variables
    var kCategoryNames;
    if (lowerCategory.contains(kCategoryNames[i])) {
      return kCategoryColors[i];
    }
  }

  // Default color if no match found
  return kCategoryColors.last;
}