import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/expense_controller.dart';
import '../widgets/expense_piechart.dart';
import '../models/expense.dart';
import '../views/daily_expense_chart.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  final ExpenseController controller = Get.find();
  late TabController _tabController;

  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime.now().subtract(Duration(days: 30)),
    end: DateTime.now(),
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: _dateRange,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Theme.of(context).colorScheme.onPrimary,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _dateRange) {
      setState(() => _dateRange = picked);
    }
  }

  List<Expense> getExpensesInRange() {
    return controller.expenseList
        .where(
          (e) =>
              !e.date.isBefore(_dateRange.start) &&
              !e.date.isAfter(_dateRange.end.add(Duration(days: 1))),
        )
        .toList();
  }

  double getTotalInRange() =>
      getExpensesInRange().fold(0.0, (sum, e) => sum + e.amount);

  Map<String, double> getCategoryTotals() {
    final totals = <String, double>{};
    for (var e in getExpensesInRange()) {
      totals[e.category] = (totals[e.category] ?? 0) + e.amount;
    }
    return totals;
  }

  Map<DateTime, double> getDailyExpenses() {
    final totals = <DateTime, double>{};
    for (var e in getExpensesInRange()) {
      final date = DateTime(e.date.year, e.date.month, e.date.day);
      totals[date] = (totals[date] ?? 0) + e.amount;
    }
    return totals;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormatter = DateFormat('MMM d, yyyy');
    final expenses = getExpensesInRange();
    final total = getTotalInRange();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Statistics',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary),
          onPressed: () => Get.back(),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48),
          child: TabBar(
            controller: _tabController,
            indicatorSize: TabBarIndicatorSize.label,
            indicatorWeight: 3,
            indicatorColor: theme.colorScheme.primary,
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.7),
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            tabs: const [
              Tab(text: 'OVERVIEW'),
              Tab(text: 'CATEGORIES'),
              Tab(text: 'TRENDS'),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Date range selector
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: InkWell(
              onTap: _selectDateRange,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: theme.colorScheme.surface,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.date_range,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                        SizedBox(width: 10),
                        Text(
                          '${dateFormatter.format(_dateRange.start)} - ${dateFormatter.format(_dateRange.end)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Overview Tab
                _buildOverviewTab(expenses, total, theme),

                // Categories Tab
                _buildCategoriesTab(total, theme),

                // Trends Tab
                _buildTrendsTab(theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(
    List<Expense> expenses,
    double total,
    ThemeData theme,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary section title
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),

          // Stats grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _buildStatCard(
                title: 'Total Expenses',
                value: '৳${total.toStringAsFixed(2)}',
                icon: Icons.account_balance_wallet,
                color: theme.colorScheme.error,
                theme: theme,
              ),

              _buildStatCard(
                title: 'Number of Expenses',
                value: '${expenses.length}',
                icon: Icons.receipt_long,
                color: theme.colorScheme.primary,
                theme: theme,
              ),

              if (expenses.isNotEmpty) ...[
                _buildStatCard(
                  title: 'Average Expense',
                  value: '৳${(total / expenses.length).toStringAsFixed(2)}',
                  icon: Icons.calculate,
                  color: theme.colorScheme.tertiary,
                  theme: theme,
                ),

                _buildStatCard(
                  title: 'Highest Expense',
                  value:
                      '৳${expenses.map((e) => e.amount).reduce((a, b) => a > b ? a : b).toStringAsFixed(2)}',
                  icon: Icons.arrow_upward,
                  color: Colors.orange,
                  theme: theme,
                ),
              ],
            ],
          ),

          // Pie chart section
          if (expenses.isNotEmpty) ...[
            SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                'Expense Distribution',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),

            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ExpensePieChart(expenses: expenses),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoriesTab(double total, ThemeData theme) {
    final categoryTotals = getCategoryTotals();
    // Sort categories by amount (highest first)
    final sortedCategories =
        categoryTotals.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 16),
            child: Text(
              'Expense by Category',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),

          // Category summary cards
          ...sortedCategories.map((entry) {
            final percent = (entry.value / total * 100).toStringAsFixed(1);
            final categoryColor = _getCategoryColor(entry.key);

            return Container(
              margin: EdgeInsets.only(bottom: 16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: categoryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          entry.key,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Text(
                        '৳${entry.value.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: entry.value / total,
                            minHeight: 8,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              categoryColor,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: categoryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$percent%',
                          style: TextStyle(
                            color: categoryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTrendsTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 16),
            child: Text(
              'Daily Expense Trend',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),

          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 300,
                  child: DailyExpenseChart(expenses: getDailyExpenses()),
                ),
                SizedBox(height: 16),
                _buildTrendSummary(theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendSummary(ThemeData theme) {
    final expenses = getExpensesInRange();
    if (expenses.isEmpty) return SizedBox.shrink();

    // Calculate some trend stats
    final dailyExpenses = getDailyExpenses();
    final values = dailyExpenses.values.toList();
    values.sort();

    final avgDaily =
        values.isNotEmpty
            ? values.reduce((a, b) => a + b) / values.length
            : 0.0;

    final median =
        values.isNotEmpty
            ? values.length.isOdd
                ? values[values.length ~/ 2]
                : (values[values.length ~/ 2 - 1] +
                        values[values.length ~/ 2]) /
                    2
            : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(),
        SizedBox(height: 8),
        Text(
          'Trend Analysis',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTrendStatItem(
                label: 'Avg. Daily',
                value: '৳${avgDaily.toStringAsFixed(2)}',
                icon: Icons.calendar_today,
                color: theme.colorScheme.primary,
                theme: theme,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildTrendStatItem(
                label: 'Median',
                value: '৳${median.toStringAsFixed(2)}',
                icon: Icons.trending_flat,
                color: Colors.amber,
                theme: theme,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTrendStatItem(
                label: 'Highest Day',
                value:
                    '৳${values.isNotEmpty ? values.last.toStringAsFixed(2) : "0.00"}',
                icon: Icons.arrow_circle_up,
                color: Colors.red,
                theme: theme,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildTrendStatItem(
                label: 'Lowest Day',
                value:
                    '৳${values.isNotEmpty ? values.first.toStringAsFixed(2) : "0.00"}',
                icon: Icons.arrow_circle_down,
                color: Colors.green,
                theme: theme,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTrendStatItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required ThemeData theme,
  }) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required ThemeData theme,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Colors.green;
      case 'transport':
        return Colors.blue;
      case 'bills':
        return Colors.orange;
      case 'entertainment':
        return Colors.purple;
      case 'shopping':
        return Colors.pink;
      case 'health':
        return Colors.teal;
      case 'education':
        return Colors.indigo;
      case 'housing':
        return Colors.brown;
      case 'travel':
        return Colors.cyan;
      case 'personal':
        return Colors.deepOrange;
      default:
        return Colors.blueGrey;
    }
  }
}
