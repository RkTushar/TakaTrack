import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/expense_controller.dart';
import '../models/expense.dart';
import 'add_expense.dart';
import '../widgets/search.dart';
import '../widgets/expense_card.dart';
import '../widgets/total_expense.dart';
import '../widgets/expense_piechart.dart';
import 'statistics_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  final ExpenseController controller = Get.find();
  final TextEditingController searchController = TextEditingController();

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        title: Text(
          'Expense Tracker',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: theme.colorScheme.primary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Obx(
              () => Icon(
                controller.isDarkMode.value
                    ? Icons.light_mode
                    : Icons.dark_mode,
                color: theme.colorScheme.primary,
              ),
            ),
            onPressed: controller.toggleThemeMode,
          ),
          IconButton(
            icon: Icon(Icons.settings, color: theme.colorScheme.primary),
            onPressed: () => Get.to(() => SettingsScreen()),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: theme.colorScheme.primary),
          );
        }

        final filteredExpenses = controller.getFilteredExpenses();
        final query = searchController.text.toLowerCase();

        return RefreshIndicator(
          onRefresh: controller.loadExpenses,
          color: theme.colorScheme.primary,
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 100.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filter Chips
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    padding: EdgeInsets.symmetric(vertical: 12),
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
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          _buildFilterChip('Daily', 'daily', theme),
                          SizedBox(width: 12),
                          _buildFilterChip('Weekly', 'weekly', theme),
                          SizedBox(width: 12),
                          _buildFilterChip('Monthly', 'monthly', theme),
                          SizedBox(width: 12),
                          _buildFilterChip('Yearly', 'yearly', theme),
                          SizedBox(width: 12),
                          _buildFilterChip('All Time', 'all', theme),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  // Total Expense Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TotalExpenseCard(
                      onChartTap:
                          () => Get.to(
                            () => StatisticsScreen(),
                            transition: Transition.rightToLeft,
                            duration: Duration(milliseconds: 300),
                          ),
                    ),
                  ),

                  SizedBox(height: 16),

                  // Section Title
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      'Spending Breakdown',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),

                  // Expense Pie Chart
                  Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
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
                    child: ExpensePieChart(expenses: filteredExpenses),
                  ),

                  SizedBox(height: 20),

                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: SearchBarWidget(
                      controller: searchController,
                      onChanged: (query) => controller.expenseList.refresh(),
                    ),
                  ),

                  SizedBox(height: 16),

                  // Section Title
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 8.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Expenses',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          '${filteredExpenses.length} items',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Expense List
                  if (filteredExpenses.isEmpty)
                    _buildEmptyState(theme)
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: filteredExpenses.length,
                      itemBuilder: (context, index) {
                        final expense = filteredExpenses[index];
                        if (query.isEmpty ||
                            expense.title.toLowerCase().contains(query) ||
                            expense.category.toLowerCase().contains(query) ||
                            (expense.note != null &&
                                expense.note!.toLowerCase().contains(query))) {
                          return Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 4.0,
                            ),
                            child: ExpenseCard(
                              expense: expense,
                              onDelete: () => _confirmDelete(context, expense),
                            ),
                          );
                        } else {
                          return SizedBox.shrink();
                        }
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed:
            () => Get.to(
              () => AddExpenseScreen(),
              transition: Transition.fadeIn,
              duration: Duration(milliseconds: 300),
            ),
        tooltip: 'Add Expense',
        backgroundColor: theme.colorScheme.primary,
        label: Text('Add Expense'),
        icon: const Icon(Icons.add),
        elevation: 4,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildFilterChip(String label, String period, ThemeData theme) {
    return Obx(() {
      final isSelected = controller.selectedPeriod.value == period;
      return FilterChip(
        label: Text(
          label,
          style: TextStyle(
            color:
                isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        showCheckmark: false,
        backgroundColor: theme.colorScheme.surface,
        selectedColor: theme.colorScheme.primary,
        padding: EdgeInsets.symmetric(horizontal: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color:
                isSelected
                    ? Colors.transparent
                    : theme.colorScheme.onSurface.withOpacity(0.2),
            width: 1,
          ),
        ),
        onSelected: (selected) {
          if (selected) {
            controller.selectedPeriod.value = period;
          }
        },
      );
    });
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      padding: EdgeInsets.all(24),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 80,
            color: theme.colorScheme.primary.withOpacity(0.5),
          ),
          SizedBox(height: 16),
          Text(
            'No expenses found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Start tracking your expenses by adding your first record',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Get.to(() => AddExpenseScreen()),
            icon: Icon(Icons.add),
            label: Text('Add First Expense'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, Expense expense) {
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
                      Icon(Icons.receipt, color: theme.colorScheme.primary),
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
                              '${expense.category} • \$${expense.amount.toStringAsFixed(2)}',
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
                  Navigator.pop(context);
                  controller.removeExpense(expense.id);
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
}
