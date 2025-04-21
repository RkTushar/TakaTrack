import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DailyExpenseChart extends StatelessWidget {
  final Map<DateTime, double> expenses;

  const DailyExpenseChart({super.key, required this.expenses});

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return const Center(
        child: Text('No data available for the selected period'),
      );
    }

    // Sort dates
    List<DateTime> dates =
        expenses.keys.toList()..sort((a, b) => a.compareTo(b));

    // Create spots for the line chart
    List<FlSpot> spots = [];
    for (int i = 0; i < dates.length; i++) {
      spots.add(FlSpot(i.toDouble(), expenses[dates[i]]!));
    }

    // Find max value for Y axis scale (ensure non-zero)
    double maxExpense = expenses.values.reduce((a, b) => a > b ? a : b);
    maxExpense = maxExpense > 0 ? maxExpense : 10.0;

    return SizedBox(
      height: 300, // Explicit height for the chart
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: _calculateYInterval(maxExpense),
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.withOpacity(0.3),
                strokeWidth: 1,
              );
            },
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: Colors.grey.withOpacity(0.3),
                strokeWidth: 1,
              );
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
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        DateFormat('MM/dd').format(dates[index]),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
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
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      '\৳${value.toInt()}',
                      style: const TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                  );
                },
                reservedSize: 40,
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
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
              color: Colors.green,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: Colors.green,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.green.withOpacity(0.2),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            handleBuiltInTouches: true,
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: Colors.blueAccent.withOpacity(0.8),
              getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                return touchedBarSpots.map((barSpot) {
                  final index = barSpot.x.toInt();
                  if (index >= 0 && index < dates.length) {
                    final date = dates[index];
                    final amount = barSpot.y;
                    return LineTooltipItem(
                      '${DateFormat('MM/dd/yyyy').format(date)}\n\$${amount.toStringAsFixed(2)}',
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
}

// Example usage:
class ExpenseChartExample extends StatelessWidget {
  const ExpenseChartExample({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample data
    final Map<DateTime, double> sampleExpenses = {
      DateTime(2025, 4, 1): 45.0,
      DateTime(2025, 4, 2): 28.5,
      DateTime(2025, 4, 3): 67.8,
      DateTime(2025, 4, 4): 35.2,
      DateTime(2025, 4, 5): 52.1,
      DateTime(2025, 4, 6): 40.9,
      DateTime(2025, 4, 7): 76.3,
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Daily Expenses')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily Expense Trend',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            DailyExpenseChart(expenses: sampleExpenses),
          ],
        ),
      ),
    );
  }
}
