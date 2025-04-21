import '../models/expense.dart';

class ExpenseService {
  // This would typically use a database, API, or local storage
  // For now, we'll use an in-memory list
  final List<Expense> _expenses = [];

  Future<List<Expense>> getExpenses() async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 500));
    return _expenses;
  }

  Future<void> addExpense(Expense expense) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 300));
    _expenses.add(expense);
  }

  Future<void> removeExpense(String id) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 300));
    _expenses.removeWhere((expense) => expense.id == id);
  }

  // Add update method
  Future<void> updateExpense(Expense updatedExpense) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 300));
    final index = _expenses.indexWhere((e) => e.id == updatedExpense.id);
    if (index != -1) {
      _expenses[index] = updatedExpense;
    }
  }
}
