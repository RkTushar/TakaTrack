import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/expense_controller.dart';

class TotalExpenseCard extends StatelessWidget {
  final VoidCallback? onChartTap;
  final ExpenseController controller = Get.find();

  TotalExpenseCard({super.key, this.onChartTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onChartTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total Expenses",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  if (onChartTap != null)
                    Icon(Icons.arrow_forward, color: Colors.grey),
                ],
              ),
              SizedBox(height: 16),
              Obx(() {
                final today = _getTodayExpenses();
                final week = _getWeeklyExpenses();
                final month = _getMonthlyExpenses();
                final year = _getYearlyExpenses();

                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStat("Today", today),
                        _buildStat("Last 7 Days", week),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStat("Monthly", month),
                        _buildStat("Yearly", year),
                      ],
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String label, double amount) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        SizedBox(height: 6),
        Text(
          '৳${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: amount > 0 ? Colors.red : Colors.grey[800],
          ),
        ),
      ],
    );
  }

  // Calculate expenses for today
  double _getTodayExpenses() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return controller.expenseList
        .where((e) => e.date.isAfter(today.subtract(Duration(seconds: 1))))
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  // Calculate expenses for the last 7 days
  double _getWeeklyExpenses() {
    final now = DateTime.now();
    final lastWeek = DateTime(now.year, now.month, now.day - 6);
    return controller.expenseList
        .where((e) => e.date.isAfter(lastWeek.subtract(Duration(seconds: 1))))
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  // Calculate expenses for the current month
  double _getMonthlyExpenses() {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    return controller.expenseList
        .where(
          (e) => e.date.isAfter(firstDayOfMonth.subtract(Duration(seconds: 1))),
        )
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  // Calculate expenses for the current year
  double _getYearlyExpenses() {
    final now = DateTime.now();
    final firstDayOfYear = DateTime(now.year, 1, 1);
    return controller.expenseList
        .where(
          (e) => e.date.isAfter(firstDayOfYear.subtract(Duration(seconds: 1))),
        )
        .fold(0.0, (sum, e) => sum + e.amount);
  }
}
