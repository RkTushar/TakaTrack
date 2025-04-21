// expense_piechart.dart - Improved Pie Chart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/expense.dart';

class ExpensePieChart extends StatelessWidget {
  final List<Expense> expenses;

  const ExpensePieChart({super.key, required this.expenses});

  @override
  Widget build(BuildContext context) {
    // Calculate the total expenses for each category
    Map<String, double> categoryTotals = {};

    for (var expense in expenses) {
      String category = expense.category;
      double amount = expense.amount;

      if (categoryTotals.containsKey(category)) {
        categoryTotals[category] = categoryTotals[category]! + amount;
      } else {
        categoryTotals[category] = amount;
      }
    }

    // Create a list of PieChartSectionData
    List<PieChartSectionData> sections =
        categoryTotals.entries.map((entry) {
          return PieChartSectionData(
            value: entry.value,
            title:
                '${entry.key}\n${(entry.value / expenses.fold(0.0, (sum, expense) => sum + expense.amount) * 100).toStringAsFixed(1)}%',
            color: _getCategoryColor(entry.key),
            radius: 60,
            titleStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList();

    // Create legend items
    List<Widget> legends =
        categoryTotals.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  color: _getCategoryColor(entry.key),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(entry.key, style: TextStyle(fontSize: 14)),
                ),
                Text(
                  '৳${entry.value.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        }).toList();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Expense Distribution',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            AspectRatio(
              aspectRatio: 1.5,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            SizedBox(height: 16),
            ...legends,
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Food':
        return Colors.green;
      case 'Transport':
        return Colors.blue;
      case 'Bills':
        return Colors.orange;
      case 'Entertainment':
        return Colors.purple;
      case 'Shopping':
        return Colors.red;
      case 'Health':
        return Colors.teal;
      case 'Education':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }
}
