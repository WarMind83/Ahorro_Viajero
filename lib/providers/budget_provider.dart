import 'package:flutter/foundation.dart';
import '../models/budget.dart';
import '../db/database_helper.dart';

class BudgetProvider with ChangeNotifier {
  List<Budget> _budgets = [];
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  bool _isLoading = false;
  String _errorMessage = '';

  // Getters
  List<Budget> get budgets => _budgets;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Constructor
  BudgetProvider() {
    refreshBudgets();
  }

  // Cargar todos los presupuestos
  Future<void> refreshBudgets() async {
    _setLoading(true);
    
    try {
      // Cargar desde la base de datos
      final budgets = await _databaseHelper.getBudgets();
      
      // Ordenar por fecha de inicio (más reciente primero)
      budgets.sort((a, b) => b.startDate.compareTo(a.startDate));
      
      _budgets = budgets;
      _setError('');
    } catch (e) {
      _setError('Error al cargar los presupuestos: ${e.toString()}');
      debugPrint('Error en refreshBudgets: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Buscar un presupuesto por ID
  Future<Budget?> getBudgetById(int id) async {
    try {
      // Primero buscar en la lista en memoria
      final inMemoryBudget = _budgets.firstWhere((budget) => budget.id == id);
      return inMemoryBudget;
    } catch (e) {
      // Si no se encuentra, buscar en la base de datos
      try {
        final budget = await _databaseHelper.getBudgetById(id);
        return budget;
      } catch (dbError) {
        debugPrint('Error al cargar presupuesto con ID $id: ${dbError.toString()}');
        return null;
      }
    }
  }

  // Añadir un nuevo presupuesto
  Future<bool> addBudget(Budget budget) async {
    _setLoading(true);
    
    try {
      // Guardar en la base de datos
      final id = await _databaseHelper.insertBudget(budget);
      
      // Crear una copia con el ID asignado
      final newBudget = budget.copyWith(id: id);
      
      // Añadir a la lista en memoria
      _budgets.add(newBudget);
      
      // Ordenar por fecha de inicio (más reciente primero)
      _budgets.sort((a, b) => b.startDate.compareTo(a.startDate));
      
      _setError('');
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Error al guardar el presupuesto: ${e.toString()}');
      debugPrint('Error en addBudget: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Actualizar un presupuesto existente
  Future<bool> updateBudget(Budget budget) async {
    _setLoading(true);
    
    try {
      // Actualizar en la base de datos
      await _databaseHelper.updateBudget(budget);
      
      // Actualizar en la lista en memoria
      final index = _budgets.indexWhere((b) => b.id == budget.id);
      if (index != -1) {
        _budgets[index] = budget;
      }
      
      // Ordenar por fecha de inicio (más reciente primero)
      _budgets.sort((a, b) => b.startDate.compareTo(a.startDate));
      
      _setError('');
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Error al actualizar el presupuesto: ${e.toString()}');
      debugPrint('Error en updateBudget: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Eliminar un presupuesto
  Future<bool> deleteBudget(int id) async {
    _setLoading(true);
    
    try {
      // Eliminar de la base de datos
      await _databaseHelper.deleteBudget(id);
      
      // Eliminar de la lista en memoria
      _budgets.removeWhere((budget) => budget.id == id);
      
      _setError('');
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Error al eliminar el presupuesto: ${e.toString()}');
      debugPrint('Error en deleteBudget: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
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