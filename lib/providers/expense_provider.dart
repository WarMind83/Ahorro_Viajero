import 'package:flutter/foundation.dart';
import '../models/expense.dart';
import '../providers/budget_provider.dart';
import '../db/database_helper.dart';

class ExpenseProvider with ChangeNotifier {
  List<Expense> _expenses = [];
  Map<int, List<Expense>> _expensesByBudget = {};
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  late BudgetProvider _budgetProvider;
  bool _isLoading = false;
  String _errorMessage = '';

  // Getters
  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Constructor
  ExpenseProvider();

  // Establecer la referencia al BudgetProvider
  void setBudgetProvider(BudgetProvider budgetProvider) {
    _budgetProvider = budgetProvider;
  }

  // Cargar gastos para un presupuesto específico
  Future<List<Expense>> getExpensesForBudget(int budgetId) async {
    _setLoading(true);
    
    try {
      // Si ya están cargados, devolver desde la memoria
      if (_expensesByBudget.containsKey(budgetId)) {
        return _expensesByBudget[budgetId]!;
      }
      
      // Sino, cargar desde la base de datos
      final expenses = await _databaseHelper.getExpensesForBudget(budgetId);
      
      // Ordenar por fecha (más reciente primero)
      expenses.sort((a, b) => b.date.compareTo(a.date));
      
      // Actualizar la caché en memoria
      _expensesByBudget[budgetId] = expenses;
      
      _setError('');
      return expenses;
    } catch (e) {
      _setError('Error al cargar los gastos: ${e.toString()}');
      debugPrint('Error en getExpensesForBudget: ${e.toString()}');
      return [];
    } finally {
      _setLoading(false);
    }
  }

  // Buscar un gasto por ID
  Future<Expense?> getExpenseById(int id) async {
    try {
      // Buscar en la lista cacheada
      for (var budgetExpenses in _expensesByBudget.values) {
        try {
          return budgetExpenses.firstWhere((expense) => expense.id == id);
        } catch (e) {
          // Continuar con el siguiente conjunto de gastos
        }
      }
      
      // Si no se encuentra en la caché, buscar en la base de datos
      return await _databaseHelper.getExpenseById(id);
    } catch (e) {
      debugPrint('Error al buscar gasto con ID $id: ${e.toString()}');
      return null;
    }
  }

  // Añadir un nuevo gasto
  Future<bool> addExpense(Expense expense) async {
    _setLoading(true);
    
    try {
      // Guardar en la base de datos
      final id = await _databaseHelper.insertExpense(expense);
      
      // Crear una copia con el ID asignado
      final newExpense = expense.copyWith(id: id);
      
      // Actualizar la caché en memoria
      if (_expensesByBudget.containsKey(expense.budgetId)) {
        _expensesByBudget[expense.budgetId]!.add(newExpense);
        // Ordenar por fecha (más reciente primero)
        _expensesByBudget[expense.budgetId]!.sort((a, b) => b.date.compareTo(a.date));
      } else {
        _expensesByBudget[expense.budgetId] = [newExpense];
      }
      
      _setError('');
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Error al guardar el gasto: ${e.toString()}');
      debugPrint('Error en addExpense: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Actualizar un gasto existente
  Future<bool> updateExpense(Expense expense) async {
    _setLoading(true);
    
    try {
      // Actualizar en la base de datos
      await _databaseHelper.updateExpense(expense);
      
      // Actualizar en la caché en memoria
      if (_expensesByBudget.containsKey(expense.budgetId)) {
        final index = _expensesByBudget[expense.budgetId]!.indexWhere((e) => e.id == expense.id);
        if (index != -1) {
          _expensesByBudget[expense.budgetId]![index] = expense;
        }
        // Ordenar por fecha (más reciente primero)
        _expensesByBudget[expense.budgetId]!.sort((a, b) => b.date.compareTo(a.date));
      }
      
      _setError('');
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Error al actualizar el gasto: ${e.toString()}');
      debugPrint('Error en updateExpense: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Eliminar un gasto
  Future<bool> deleteExpense(int id, int budgetId) async {
    _setLoading(true);
    
    try {
      // Eliminar de la base de datos
      await _databaseHelper.deleteExpense(id);
      
      // Eliminar de la caché en memoria
      if (_expensesByBudget.containsKey(budgetId)) {
        _expensesByBudget[budgetId]!.removeWhere((expense) => expense.id == id);
      }
      
      _setError('');
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Error al eliminar el gasto: ${e.toString()}');
      debugPrint('Error en deleteExpense: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Calcular el total gastado en un presupuesto (en moneda de origen)
  Future<double> getTotalSpentForBudget(int budgetId) async {
    try {
      final expenses = await getExpensesForBudget(budgetId);
      return expenses.fold(0, (sum, expense) => sum + expense.amountInBaseCurrency);
    } catch (e) {
      debugPrint('Error al calcular el total gastado: ${e.toString()}');
      return 0;
    }
  }

  // Métodos auxiliares para gestionar estados
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }
}