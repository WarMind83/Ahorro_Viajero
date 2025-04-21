import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/expense.dart';
import '../db/database_helper.dart';
import 'package:provider/provider.dart';
import 'budget_provider.dart';
import 'package:sqflite/sqflite.dart';

class ExpenseProvider with ChangeNotifier {
  List<Expense> _expenses = [];
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  int? _currentBudgetId;
  BudgetProvider? _budgetProvider;

  ExpenseProvider() {
    // No cargar gastos automáticamente, esperar a que se seleccione un presupuesto
    // evitamos refreshExpenses() aquí
  }

  List<Expense> get expenses => _expenses;
  int? get currentBudgetId => _currentBudgetId;

  // Método para inicializar el budgetProvider
  void setBudgetProvider(BudgetProvider provider) {
    _budgetProvider = provider;
  }

  Future<void> loadExpenses(int budgetId) async {
    _currentBudgetId = budgetId;
    _expenses = await _databaseHelper.getAllExpenses(budgetId);
    notifyListeners();
  }

  Future<void> addExpense(Expense expense) async {
    try {
      final id = await _databaseHelper.insertExpense(expense);
      
      final newExpense = expense.copyWith(id: id);
      _expenses.add(newExpense);
      notifyListeners();
      
      // Actualizar el presupuesto relacionado
      if (_budgetProvider != null) {
        await _budgetProvider!.updateBudgetSpentAmount(expense.budgetId);
      }
    } catch (e) {
      throw Exception('Error al añadir gasto: $e');
    }
  }

  Future<void> updateExpense(Expense expense) async {
    try {
      if (expense.id == null) {
        throw Exception("No se puede actualizar un gasto sin ID");
      }
      
      await _databaseHelper.updateExpense(expense);
      
      final index = _expenses.indexWhere((e) => e.id == expense.id);
      if (index >= 0) {
        _expenses[index] = expense;
        notifyListeners();
      }
      
      // Actualizar el presupuesto relacionado
      if (_budgetProvider != null) {
        await _budgetProvider!.updateBudgetSpentAmount(expense.budgetId);
      }
    } catch (e) {
      throw Exception('Error al actualizar gasto: $e');
    }
  }

  Future<void> deleteExpense(int expenseId) async {
    try {
      final expense = await getExpense(expenseId);
      
      // Si el gasto tiene una imagen, eliminar el archivo
      if (expense != null && expense.imagePath != null && expense.imagePath!.isNotEmpty) {
        try {
          final file = File(expense.imagePath!);
          if (await file.exists()) {
            await file.delete();
          }
        } catch (e) {
          // Error al eliminar el archivo, continuamos con la eliminación del gasto
        }
      }
      
      await _databaseHelper.deleteExpense(expenseId);
      _expenses.removeWhere((expense) => expense.id == expenseId);
      notifyListeners();
    } catch (e) {
      // Error silenciado
    }
  }

  Future<Expense?> getExpense(int expenseId) async {
    try {
      return await _databaseHelper.getExpense(expenseId);
    } catch (e) {
      // Error silenciado
      return null;
    }
  }

  Future<List<Expense>> getExpensesByCategory(ExpenseCategory category) async {
    if (_currentBudgetId == null) return [];
    return await _databaseHelper.getExpensesByCategory(_currentBudgetId!, category);
  }

  Future<Map<ExpenseCategory, double>> getExpenseSummaryByCategory([int? budgetId]) async {
    final targetBudgetId = budgetId ?? _currentBudgetId;
    
    // Si no hay presupuesto específico, devolver un mapa vacío
    if (targetBudgetId == null) return {};
    
    // Obtener los gastos específicamente para este presupuesto
    final expenses = await _databaseHelper.getAllExpenses(targetBudgetId);
    
    final summary = <ExpenseCategory, double>{};
    for (var expense in expenses) {
      // Usar el valor convertido a moneda base
      summary[expense.category] = (summary[expense.category] ?? 0) + expense.amountInBaseCurrency;
    }
    
    return summary;
  }

  Future<Map<String, double>> getExpenseSummaryCategorized([int? budgetId]) async {
    final targetBudgetId = budgetId ?? _currentBudgetId;
    
    // Si no hay presupuesto especificado, devolver un mapa vacío
    if (targetBudgetId == null) return {};
    
    // Obtener los gastos específicamente para este presupuesto
    final expenses = await _databaseHelper.getAllExpenses(targetBudgetId);
    
    final summary = <String, double>{};
    for (var expense in expenses) {
      final categoryName = expense.category.displayName;
      summary[categoryName] = (summary[categoryName] ?? 0) + expense.amountInBaseCurrency;
    }
    
    return summary;
  }

  Future<double> getTotalExpenses([int? budgetId]) async {
    final targetBudgetId = budgetId ?? _currentBudgetId;
    if (targetBudgetId == null) return 0.0;
    return await _databaseHelper.getTotalExpenses(targetBudgetId);
  }

  Future<void> refreshExpenses() async {
    try {
      if (_currentBudgetId == null) return;
      
      loadExpenses(_currentBudgetId!);
    } catch (e) {
      // Error silenciado
    }
  }

  void clearExpenses() {
    _expenses = [];
    _currentBudgetId = null;
    notifyListeners();
  }

  Future<List<Expense>> getExpensesForBudget(int budgetId) async {
    // Obtener directamente de la base de datos en lugar de filtrar en memoria
    return await _databaseHelper.getAllExpenses(budgetId);
  }
}