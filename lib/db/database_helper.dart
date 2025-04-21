import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/budget.dart';
import '../models/expense.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  // Nombres de tablas
  static const String tableBudgets = 'budgets';
  static const String tableExpenses = 'expenses';

  // Versión de la base de datos
  static const int _version = 1;

  // Factory constructor
  factory DatabaseHelper() {
    return _instance;
  }

  // Constructor interno privado
  DatabaseHelper._internal();

  // Obtener la instancia de la base de datos
  Future<Database> get database async {
    if (_database != null) return _database!;
    
    _database = await _initDatabase();
    return _database!;
  }

  // Inicializar la base de datos
  Future<Database> _initDatabase() async {
    final String path = join(await getDatabasesPath(), 'ahorro_viajero.db');
    
    return await openDatabase(
      path,
      version: _version,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );
  }

  // Crear tablas de la base de datos
  Future<void> _createDatabase(Database db, int version) async {
    // Crear tabla de presupuestos
    await db.execute('''
      CREATE TABLE $tableBudgets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        totalAmount REAL NOT NULL,
        originCurrencyCode TEXT NOT NULL,
        destinationCurrencyCode TEXT NOT NULL,
        exchangeRate REAL NOT NULL,
        startDate TEXT NOT NULL,
        endDate TEXT,
        notes TEXT
      )
    ''');
    
    // Crear tabla de gastos
    await db.execute('''
      CREATE TABLE $tableExpenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        budget_id INTEGER NOT NULL,
        description TEXT NOT NULL,
        amount REAL NOT NULL,
        currency_code TEXT NOT NULL,
        is_local_currency INTEGER NOT NULL,
        conversion_rate REAL NOT NULL,
        category TEXT NOT NULL,
        date TEXT NOT NULL,
        image_path TEXT,
        notes TEXT,
        FOREIGN KEY (budget_id) REFERENCES $tableBudgets (id) ON DELETE CASCADE
      )
    ''');
  }

  // Actualizar la base de datos en futuras versiones
  Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    // Código para migrar datos en futuras versiones
  }

  // ---------------- Operaciones de Presupuestos ----------------

  // Insertar un nuevo presupuesto
  Future<int> insertBudget(Budget budget) async {
    final db = await database;
    return await db.insert(tableBudgets, budget.toMap());
  }

  // Actualizar un presupuesto existente
  Future<int> updateBudget(Budget budget) async {
    final db = await database;
    return await db.update(
      tableBudgets,
      budget.toMap(),
      where: 'id = ?',
      whereArgs: [budget.id],
    );
  }

  // Eliminar un presupuesto
  Future<int> deleteBudget(int id) async {
    final db = await database;
    
    // Eliminar gastos asociados
    await db.delete(
      tableExpenses,
      where: 'budget_id = ?',
      whereArgs: [id],
    );
    
    // Eliminar presupuesto
    return await db.delete(
      tableBudgets,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Obtener todos los presupuestos
  Future<List<Budget>> getBudgets() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableBudgets);
    
    return List.generate(maps.length, (i) {
      return Budget.fromMap(maps[i]);
    });
  }

  // Obtener un presupuesto por ID
  Future<Budget> getBudgetById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableBudgets,
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isNotEmpty) {
      return Budget.fromMap(maps.first);
    } else {
      throw Exception('Presupuesto con ID $id no encontrado');
    }
  }

  // ---------------- Operaciones de Gastos ----------------

  // Insertar un nuevo gasto
  Future<int> insertExpense(Expense expense) async {
    final db = await database;
    return await db.insert(tableExpenses, expense.toMap());
  }

  // Actualizar un gasto existente
  Future<int> updateExpense(Expense expense) async {
    final db = await database;
    return await db.update(
      tableExpenses,
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  // Eliminar un gasto
  Future<int> deleteExpense(int id) async {
    final db = await database;
    return await db.delete(
      tableExpenses,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Obtener todos los gastos de un presupuesto
  Future<List<Expense>> getExpensesForBudget(int budgetId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableExpenses,
      where: 'budget_id = ?',
      whereArgs: [budgetId],
    );
    
    return List.generate(maps.length, (i) {
      return Expense.fromMap(maps[i]);
    });
  }

  // Obtener un gasto por ID
  Future<Expense> getExpenseById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableExpenses,
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isNotEmpty) {
      return Expense.fromMap(maps.first);
    } else {
      throw Exception('Gasto con ID $id no encontrado');
    }
  }

  // Obtener el total de gastos para un presupuesto
  Future<double> getTotalExpensesForBudget(int budgetId, {bool inBaseCurrency = true}) async {
    final db = await database;
    
    // Esta consulta requiere cálculos basados en el campo is_local_currency
    // Por lo que es mejor cargar todos los gastos y calcular el total en Dart
    final expenses = await getExpensesForBudget(budgetId);
    
    if (inBaseCurrency) {
      // Total en moneda de origen
      return expenses.fold(0, (sum, expense) => sum + expense.amountInBaseCurrency);
    } else {
      // Total en moneda local
      return expenses.fold(0, (sum, expense) => sum + expense.amountInLocalCurrency);
    }
  }

  // Cerrar la base de datos
  Future<void> close() async {
    final db = await database;
    db.close();
  }
}