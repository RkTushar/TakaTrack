import 'package:get/get.dart';
import '../models/expense.dart';
import '../services/storage_service.dart';
import 'package:flutter/material.dart';

class ExpenseController extends GetxController {
  var expenseList = <Expense>[].obs;
  var isLoading = false.obs;
  var selectedPeriod = 'monthly'.obs;
  var categories =
      [
        'Food',
        'Transport',
        'Bills',
        'Entertainment',
        'Shopping',
        'Health',
        'Education',
        'Other',
      ].obs;

  // For statistics
  var totalExpense = 0.0.obs;
  var categoryExpenses = <String, double>{}.obs;

  // Theme mode
  var isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadExpenses();
  }

  // Load expenses from storage
  Future<void> loadExpenses() async {
    isLoading.value = true;
    try {
      final expenses = await StorageService.getExpenses();
      expenseList.assignAll(expenses);
      updateStatistics();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load expenses: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Add an expense and save to storage
  Future<void> addExpense(Expense expense) async {
    try {
      await StorageService.saveExpense(expense);
      expenseList.add(expense);
      updateStatistics(); // Call once here after any change
      Get.back();
      Get.snackbar(
        'Success',
        'Expense added successfully',
        backgroundColor: Colors.green.withOpacity(0.7),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to add expense: $e');
    }
  }

  // Update an existing expense
  Future<void> updateExpense(Expense updatedExpense) async {
    try {
      final index = expenseList.indexWhere((e) => e.id == updatedExpense.id);
      if (index >= 0) {
        await StorageService.updateExpense(updatedExpense);
        expenseList[index] = updatedExpense;
        expenseList.refresh(); // Refresh after the update
        updateStatistics();
        Get.back();
        Get.snackbar(
          'Success',
          'Expense updated successfully',
          backgroundColor: Colors.green.withOpacity(0.7),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update expense: $e');
    }
  }

  // Remove an expense by ID
  Future<void> removeExpense(String id) async {
    try {
      await StorageService.deleteExpense(id);
      expenseList.removeWhere((e) => e.id == id);
      updateStatistics();
      Get.snackbar(
        'Success',
        'Expense deleted successfully',
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete expense: $e');
    }
  }

  // Filter expenses based on selected period
  List<Expense> getFilteredExpenses() {
    DateTime now = DateTime.now();
    DateTime startDate;

    switch (selectedPeriod.value) {
      case 'daily':
        startDate = DateTime(now.year, now.month, now.day); // Today
        break;
      case 'weekly':
        startDate = now.subtract(Duration(days: now.weekday - 1));
        break;
      case 'monthly':
        startDate = DateTime(now.year, now.month, 1); // Start of this month
        break;
      case 'yearly':
        startDate = DateTime(now.year, 1, 1); // Start of this year
        break;
      case 'all':
        return expenseList;
      default:
        startDate = DateTime(now.year, now.month, 1); // Default to monthly
    }

    return expenseList
        .where(
          (expense) =>
              expense.date.isAfter(startDate) ||
              expense.date.isAtSameMomentAs(startDate),
        )
        .toList();
  }

  // Search expenses by title or category
  List<Expense> searchExpenses(String query) {
    if (query.isEmpty) return getFilteredExpenses();

    return getFilteredExpenses()
        .where(
          (expense) =>
              expense.title.toLowerCase().contains(query.toLowerCase()) ||
              expense.category.toLowerCase().contains(query.toLowerCase()) ||
              (expense.note != null &&
                  expense.note!.toLowerCase().contains(query.toLowerCase())),
        )
        .toList();
  }

  // Update statistics for dashboard
  void updateStatistics() {
    // Calculate total expenses
    totalExpense.value = expenseList.fold(0.0, (sum, e) => sum + e.amount);

    // Calculate category expenses
    Map<String, double> catExpenses = {};
    for (var expense in expenseList) {
      catExpenses[expense.category] =
          (catExpenses[expense.category] ?? 0.0) + expense.amount;
    }
    categoryExpenses.assignAll(catExpenses); // Ensures reactivity
  }

  // Toggle theme mode
  void toggleThemeMode() {
    isDarkMode.value = !isDarkMode.value;
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    StorageService.saveThemeMode(isDarkMode.value);
  }

  // Add new category
  void addCategory(String category) {
    if (!categories.contains(category)) {
      categories.add(category);
      StorageService.saveCategories(categories);
    }
  }
}
