import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ExpenseChart extends StatelessWidget {
  final Map<String, double> categoryData;
  final bool showTitles;
  final double titlePositionPercentageOffset;
  final double chartRadius;

  const ExpenseChart({
    super.key,
    required this.categoryData,
    this.showTitles = true,
    this.titlePositionPercentageOffset = 0.6,
    this.chartRadius = 100,
  });

  @override
  Widget build(BuildContext context) {
    final total = categoryData.values.fold(0.0, (sum, amount) => sum + amount);
    final theme = Theme.of(context);

    return AspectRatio(
      aspectRatio: 1.7,
      child: PieChart(
        PieChartData(
          pieTouchData: PieTouchData(
            touchCallback: (FlTouchEvent event, pieTouchResponse) {
              // Handle touch interactions
            },
          ),
          borderData: FlBorderData(show: false),
          sectionsSpace: 2,
          centerSpaceRadius: chartRadius,
          sections: _buildSections(total, theme),
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildSections(double total, ThemeData theme) {
    return categoryData.entries.map((entry) {
      final percentage = (entry.value / total * 100).toStringAsFixed(1);
      final color = _getCategoryColor(entry.key);

      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: showTitles ? '${entry.key}\n$percentage%' : '',
        radius: 20,
        titleStyle: theme.textTheme.bodySmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        titlePositionPercentageOffset: titlePositionPercentageOffset,
        badgeWidget: _Badge(
          entry.key,
          color: color,
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.white),
        ),
        badgePositionPercentageOffset: .98,
      );
    }).toList();
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Food':
        return Colors.green;
      case 'Transport':
        return Colors.blue;
      case 'Entertainment':
        return Colors.purple;
      case 'Bills':
        return Colors.orange;
      case 'Shopping':
        return Colors.pink;
      case 'Healthcare':
        return Colors.red;
      case 'Education':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }
}

class _Badge extends StatelessWidget {
  final String category;
  final Color color;
  final TextStyle? style;

  const _Badge(
    this.category, {
    required this.color,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
      child: Text(
        category[0],
        style: style?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}