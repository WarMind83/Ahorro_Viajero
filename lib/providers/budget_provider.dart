import 'package:flutter/foundation.dart';
import '../models/budget.dart';
import '../db/database_helper.dart';

class BudgetProvider with ChangeNotifier {
  List<Budget> _budgets = [];
  Budget? _currentBudget;
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  BudgetProvider() {
    _loadBudgets();
  }

  List<Budget> get budgets => _budgets;
  Budget? get currentBudget => _currentBudget;

  Future<void> _loadBudgets() async {
    _budgets = await _databaseHelper.getAllBudgets();
    notifyListeners();
  }

  Future<void> addBudget(Budget budget) async {
    final id = await _databaseHelper.insertBudget(budget);
    final newBudget = budget.copyWith(id: id);
    _budgets.add(newBudget);
    notifyListeners();
  }

  Future<void> updateBudget(Budget budget) async {
    await _databaseHelper.updateBudget(budget);
    final index = _budgets.indexWhere((b) => b.id == budget.id);
    if (index != -1) {
      _budgets[index] = budget;
      if (_currentBudget?.id == budget.id) {
        _currentBudget = budget;
      }
      notifyListeners();
    }
  }

  Future<void> deleteBudget(int budgetId) async {
    await _databaseHelper.deleteBudget(budgetId);
    _budgets.removeWhere((budget) => budget.id == budgetId);
    if (_currentBudget?.id == budgetId) {
      _currentBudget = null;
    }
    notifyListeners();
  }

  Future<void> setCurrentBudget(int budgetId) async {
    _currentBudget = await _databaseHelper.getBudget(budgetId);
    notifyListeners();
  }

  void clearCurrentBudget() {
    _currentBudget = null;
    notifyListeners();
  }

  Future<Budget?> getBudgetById(int budgetId) async {
    return await _databaseHelper.getBudget(budgetId);
  }

  Future<void> refreshBudgets() async {
    await _loadBudgets();
  }

  Future<void> updateBudgetAmount(int id, double newAmount) async {
    final budget = _budgets.firstWhere((b) => b.id == id);
    final updatedBudget = Budget(
      id: budget.id,
      title: budget.title,
      totalAmount: newAmount,
      originCurrencyCode: budget.originCurrencyCode,
      destinationCurrencyCode: budget.destinationCurrencyCode,
      exchangeRate: budget.exchangeRate,
      startDate: budget.startDate,
      endDate: budget.endDate,
      notes: budget.notes,
    );
    await updateBudget(updatedBudget);
  }

  Future<void> updateBudgetAmountAndExchangeRate(int id, double newAmount, double newExchangeRate) async {
    final budget = _budgets.firstWhere((b) => b.id == id);
    final updatedBudget = Budget(
      id: budget.id,
      title: budget.title,
      totalAmount: newAmount,
      originCurrencyCode: budget.originCurrencyCode,
      destinationCurrencyCode: budget.destinationCurrencyCode,
      exchangeRate: newExchangeRate,
      startDate: budget.startDate,
      endDate: budget.endDate,
      notes: budget.notes,
    );
    await updateBudget(updatedBudget);
  }
  
  // Método para actualizar la cantidad gastada en un presupuesto
  Future<void> updateBudgetSpentAmount(int budgetId) async {
    try {
      // Obtener el total gastado para este presupuesto
      final totalSpent = await _databaseHelper.getTotalExpenses(budgetId);
      
      // Actualizar el presupuesto si es necesario
      notifyListeners();
    } catch (e) {
      // Error silenciado
    }
  }
}