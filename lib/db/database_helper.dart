import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/budget.dart';
import '../models/expense.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'travel_budget.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDb,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE budgets(
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

    await db.execute('''
      CREATE TABLE expenses(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        budget_id INTEGER NOT NULL,
        description TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        category INTEGER NOT NULL,
        image_path TEXT,
        notes TEXT,
        is_local_currency INTEGER NOT NULL,
        currency_code TEXT,
        conversion_rate REAL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE expenses ADD COLUMN currency_code TEXT;'
      );
      await db.execute(
        'ALTER TABLE expenses ADD COLUMN conversion_rate REAL;'
      );
    }
  }

  // Métodos para Budget
  Future<int> insertBudget(Budget budget) async {
    Database db = await database;
    return await db.insert('budgets', budget.toMap());
  }

  Future<int> updateBudget(Budget budget) async {
    Database db = await database;
    return await db.update(
      'budgets',
      budget.toMap(),
      where: 'id = ?',
      whereArgs: [budget.id],
    );
  }

  Future<int> deleteBudget(int id) async {
    Database db = await database;
    return await db.delete(
      'budgets',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Budget?> getBudget(int id) async {
    Database db = await database;
    var maps = await db.query(
      'budgets',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Budget.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Budget>> getAllBudgets() async {
    Database db = await database;
    var maps = await db.query('budgets', orderBy: 'startDate DESC');
    return List.generate(maps.length, (i) => Budget.fromMap(maps[i]));
  }

  // Métodos para Expense
  Future<int> insertExpense(Expense expense) async {
    Database db = await database;
    return await db.insert('expenses', expense.toMap());
  }

  Future<void> updateExpense(Expense expense) async {
    Database db = await database;
    await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<void> deleteExpense(int id) async {
    Database db = await database;
    await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Expense?> getExpense(int id) async {
    Database db = await database;
    var maps = await db.query(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return Expense.fromMap(maps.first);
  }

  Future<List<Expense>> getAllExpenses([int? budgetId]) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = budgetId != null
        ? await db.query('expenses', where: 'budget_id = ?', whereArgs: [budgetId])
        : await db.query('expenses');

    return List.generate(maps.length, (i) => Expense.fromMap(maps[i]));
  }

  Future<List<Expense>> getExpensesByCategory(int budgetId, ExpenseCategory category) async {
    Database db = await database;
    var maps = await db.query(
      'expenses',
      where: 'budget_id = ? AND category = ?',
      whereArgs: [budgetId, category.toString()],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => Expense.fromMap(maps[i]));
  }

  Future<Map<ExpenseCategory, double>> getExpenseSummaryByCategory(int budgetId) async {
    Database db = await database;
    
    // Obtener todos los gastos del presupuesto
    var maps = await db.query(
      'expenses',
      where: 'budget_id = ?',
      whereArgs: [budgetId],
    );
    
    // Convertir los mapas a objetos Expense
    final expenses = List.generate(maps.length, (i) => Expense.fromMap(maps[i]));
    
    // Agrupar por categoría y sumar los montos en la moneda base
    Map<ExpenseCategory, double> summary = {};
    for (var expense in expenses) {
      final category = expense.category;
      summary[category] = (summary[category] ?? 0.0) + expense.amountInBaseCurrency;
    }
    
    return summary;
  }

  Future<double> getTotalExpenses(int budgetId) async {
    final db = await database;
    
    // Obtener todos los gastos del presupuesto
    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      where: 'budget_id = ?',
      whereArgs: [budgetId],
    );
    
    // Convertir los mapas a objetos Expense
    final expenses = List.generate(maps.length, (i) => Expense.fromMap(maps[i]));
    
    // Sumar los montos en la moneda base (origen)
    double total = 0.0;
    for (var expense in expenses) {
      total += expense.amountInBaseCurrency;
    }
    
    return total;
  }
}