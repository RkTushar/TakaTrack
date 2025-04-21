import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/expense_controller.dart';
import '../models/expense.dart';
import './add_expense.dart';
import 'package:fl_chart/fl_chart.dart';

class ExpenseDetailScreen extends StatelessWidget {
  final Expense expense;
  final ExpenseController controller = Get.find();

  ExpenseDetailScreen({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String formattedDate = DateFormat(
      'EEEE, MMMM d, yyyy',
    ).format(expense.date);

    // Get expenses for the same category in the last 30 days
    final Map<DateTime, double> categoryExpenses =
        _getCategoryExpensesForLast30Days();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Expense Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: theme.colorScheme.primary),
            onPressed: () => _editExpense(context),
            tooltip: 'Edit Expense',
          ),
          IconButton(
            icon: Icon(Icons.delete, color: theme.colorScheme.error),
            onPressed: () => _confirmDelete(context),
            tooltip: 'Delete Expense',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Expense Card
            _buildExpenseCard(theme, formattedDate),

            SizedBox(height: 24),

            // Category Spending Chart
            _buildCategoryChart(theme, categoryExpenses),

            SizedBox(height: 24),

            // Expense Notes
            if (expense.note != null && expense.note!.isNotEmpty)
              _buildNotesSection(theme),

            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseCard(ThemeData theme, String formattedDate) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: _getCategoryColor(
                    expense.category,
                  ).withOpacity(0.2),
                  child: Icon(
                    _getCategoryIcon(expense.category),
                    color: _getCategoryColor(expense.category),
                    size: 28,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.title,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 16,
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Divider(),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Amount',
                      style: TextStyle(
                        fontSize: 16,
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '৳${expense.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(
                      expense.category,
                    ).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getCategoryColor(
                        expense.category,
                      ).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    expense.category,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _getCategoryColor(expense.category),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChart(
    ThemeData theme,
    Map<DateTime, double> categoryExpenses,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${expense.category} Spending (Last 30 Days)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 250,
              child:
                  categoryExpenses.isEmpty
                      ? Center(
                        child: Text(
                          'No data available for ${expense.category} category',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      )
                      : _buildDailyExpenseChart(categoryExpenses),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                expense.note!,
                style: TextStyle(
                  fontSize: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyExpenseChart(Map<DateTime, double> expenses) {
    if (expenses.isEmpty) {
      return Center(child: Text('No data available for the selected period'));
    }

    // Sort dates
    List<DateTime> dates =
        expenses.keys.toList()..sort((a, b) => a.compareTo(b));

    // Create spots for the line chart
    List<FlSpot> spots = [];
    for (int i = 0; i < dates.length; i++) {
      spots.add(FlSpot(i.toDouble(), expenses[dates[i]]!));
    }

    // Find max value for Y axis scale
    double maxExpense = expenses.values.reduce((a, b) => a > b ? a : b);

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: _calculateYInterval(maxExpense),
          getDrawingHorizontalLine: (value) {
            return FlLine(color: Colors.grey.withOpacity(0.3), strokeWidth: 1);
          },
          getDrawingVerticalLine: (value) {
            return FlLine(color: Colors.grey.withOpacity(0.3), strokeWidth: 1);
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: _calculateXInterval(dates.length),
              getTitlesWidget: (value, meta) {
                final int index = value.toInt();
                if (index >= 0 && index < dates.length) {
                  return Text(
                    DateFormat('MM/dd').format(dates[index]),
                    style: const TextStyle(color: Colors.grey, fontSize: 10),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: _calculateYInterval(maxExpense),
              getTitlesWidget: (value, meta) {
                return Text(
                  '৳${value.toInt()}',
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                );
              },
              reservedSize: 40,
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.withOpacity(0.5)),
        ),
        minX: 0,
        maxX: (dates.length - 1).toDouble(),
        minY: 0,
        maxY: maxExpense * 1.2,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: _getCategoryColor(expense.category),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: _getCategoryColor(expense.category),
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  _getCategoryColor(expense.category).withOpacity(0.3),
                  _getCategoryColor(expense.category).withOpacity(0.05),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.blueAccent.withOpacity(0.8),
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                final index = barSpot.x.toInt();
                if (index >= 0 && index < dates.length) {
                  final date = dates[index];
                  final amount = barSpot.y;
                  return LineTooltipItem(
                    '${DateFormat('MM/dd/yyyy').format(date)}\n৳${amount.toStringAsFixed(2)}',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }
                return null;
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  // Calculate appropriate interval for X axis based on number of data points
  double _calculateXInterval(int dataLength) {
    if (dataLength <= 7) return 1;
    if (dataLength <= 14) return 2;
    if (dataLength <= 30) return 5;
    return (dataLength / 6).ceil().toDouble();
  }

  // Calculate appropriate interval for Y axis based on max value
  double _calculateYInterval(double maxValue) {
    if (maxValue <= 10) return 1;
    if (maxValue <= 50) return 5;
    if (maxValue <= 100) return 10;
    if (maxValue <= 500) return 50;
    if (maxValue <= 1000) return 100;
    return (maxValue / 5).ceil().toDouble();
  }

  Map<DateTime, double> _getCategoryExpensesForLast30Days() {
    final now = DateTime.now();
    final thirtyDaysAgo = DateTime(now.year, now.month, now.day - 30);

    // Get all expenses for the same category in the last 30 days
    final categoryExpenses =
        controller.expenseList
            .where(
              (exp) =>
                  exp.category == expense.category &&
                  exp.date.isAfter(thirtyDaysAgo) &&
                  exp.date.isBefore(DateTime(now.year, now.month, now.day + 1)),
            )
            .toList();

    // Group by date
    final Map<DateTime, double> result = {};
    for (var exp in categoryExpenses) {
      // Normalize to date only (no time)
      final dateOnly = DateTime(exp.date.year, exp.date.month, exp.date.day);

      if (result.containsKey(dateOnly)) {
        result[dateOnly] = result[dateOnly]! + exp.amount;
      } else {
        result[dateOnly] = exp.amount;
      }
    }

    return result;
  }

  void _editExpense(BuildContext context) {
    Get.to(
      () => AddExpenseScreen(expenseToEdit: expense),
      transition: Transition.rightToLeft,
      duration: Duration(milliseconds: 300),
    );
  }

  void _confirmDelete(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Delete Expense',
              style: TextStyle(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Are you sure you want to delete this expense?'),
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.colorScheme.onSurface.withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getCategoryIcon(expense.category),
                        color: _getCategoryColor(expense.category),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              expense.title,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${expense.category} • ৳${expense.amount.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.7,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.onSurface,
                ),
                child: Text('Cancel'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  controller.removeExpense(expense.id);
                  Navigator.pop(context);
                  Get.back(); // Go back to the home screen
                },
                icon: Icon(Icons.delete),
                label: Text('Delete'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: theme.colorScheme.onError,
                ),
              ),
            ],
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
      case 'Uncategorized':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Food':
        return Icons.restaurant;
      case 'Transport':
        return Icons.directions_car;
      case 'Bills':
        return Icons.receipt;
      case 'Entertainment':
        return Icons.movie;
      case 'Shopping':
        return Icons.shopping_bag;
      case 'Health':
        return Icons.medical_services;
      case 'Education':
        return Icons.school;
      case 'Uncategorized':
        return Icons.help_outline;
      default:
        return Icons.category;
    }
  }
}
