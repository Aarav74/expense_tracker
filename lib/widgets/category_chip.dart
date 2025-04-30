import 'package:flutter/material.dart';
import 'package:expense_tracker/utils/constants.dart';

class CategoryChip extends StatelessWidget {
  final String category;
  final double amount;
  final Color color;
  final TextStyle? textStyle;

  const CategoryChip({
    super.key,
    required this.category,
    required this.amount,
    required this.color,
    this.textStyle, required String percentage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final amountText = '\$${amount.toStringAsFixed(2)}';
    // ignore: deprecated_member_use
    final colorWithOpacity = color.withOpacity(0.2);

    return Chip(
      label: Text(
        '$category: $amountText',
        style: textStyle ?? theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface,
        ),
      ),
      backgroundColor: colorWithOpacity,
      avatar: CircleAvatar(
        // ignore: deprecated_member_use
        backgroundColor: color.withOpacity(0.5),
        child: Text(
          category[0],
          style: TextStyle(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}

// Helper function to get category color
Color getCategoryColor(String category) {
  switch (category.toLowerCase()) {
    case 'food':
      return kCategoryColors[0];
    case 'transport':
      return kCategoryColors[1];
    case 'entertainment':
      return kCategoryColors[2];
    case 'bills':
      return kCategoryColors[3];
    case 'shopping':
      return kCategoryColors[4];
    case 'healthcare':
      return kCategoryColors[5];
    case 'education':
      return kCategoryColors[6];
    default:
      return kCategoryColors[7];
  }
}