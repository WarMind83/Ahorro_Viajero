import '../db/database_helper.dart';
import '../models/expense.dart';

class DatabaseService {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<List<Expense>> getExpenses() async {
    return _databaseHelper.getAllExpenses();
  }

  Future<int> insertExpense(Expense expense) async {
    return _databaseHelper.insertExpense(expense);
  }

  Future<int> updateExpense(Expense expense) async {
    return _databaseHelper.updateExpense(expense);
  }

  Future<int> deleteExpense(int id) async {
    return _databaseHelper.deleteExpense(id);
  }

  Future<Expense?> getExpense(int id) async {
    return _databaseHelper.getExpense(id);
  }

  Future<List<Expense>> getExpensesForBudget(int budgetId) async {
    return _databaseHelper.getExpensesForBudget(budgetId);
  }

  Future<double> getTotalExpensesForBudget(int budgetId) async {
    return _databaseHelper.getTotalExpensesForBudget(budgetId);
  }
}