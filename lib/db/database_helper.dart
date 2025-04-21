import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/expense.dart';
import '../models/budget.dart';
import '../models/trip.dart';

class DatabaseHelper {
  static const _databaseName = "ahorro_viajero.db";
  static const _databaseVersion = 1;

  // Tablas
  static const String tableExpenses = 'expenses';
  static const String tableBudgets = 'budgets';
  static const String tableTrips = 'trips';

  // Columnas comunes
  static const String columnId = 'id';
  static const String columnCreatedAt = 'created_at';
  static const String columnUpdatedAt = 'updated_at';

  // Columnas de Gastos
  static const String columnAmount = 'amount';
  static const String columnDescription = 'description';
  static const String columnBudgetId = 'budget_id';
  static const String columnCategory = 'category';
  static const String columnDate = 'date';

  // Columnas de Presupuestos
  static const String columnName = 'name';
  static const String columnTripId = 'trip_id';
  static const String columnTotalAmount = 'total_amount';

  // Columnas de Viajes
  static const String columnDestination = 'destination';
  static const String columnStartDate = 'start_date';
  static const String columnEndDate = 'end_date';

  // Singleton pattern
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Inicializa la base de datos
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // Crea las tablas
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableTrips (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnName TEXT NOT NULL,
        $columnDestination TEXT NOT NULL,
        $columnStartDate TEXT NOT NULL,
        $columnEndDate TEXT,
        $columnCreatedAt TEXT NOT NULL,
        $columnUpdatedAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableBudgets (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnName TEXT NOT NULL,
        $columnTripId INTEGER NOT NULL,
        $columnTotalAmount REAL NOT NULL,
        $columnCreatedAt TEXT NOT NULL,
        $columnUpdatedAt TEXT NOT NULL,
        FOREIGN KEY ($columnTripId) REFERENCES $tableTrips ($columnId) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableExpenses (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnAmount REAL NOT NULL,
        $columnDescription TEXT NOT NULL,
        $columnBudgetId INTEGER NOT NULL,
        $columnCategory TEXT NOT NULL,
        $columnDate TEXT NOT NULL,
        $columnCreatedAt TEXT NOT NULL,
        $columnUpdatedAt TEXT NOT NULL,
        FOREIGN KEY ($columnBudgetId) REFERENCES $tableBudgets ($columnId) ON DELETE CASCADE
      )
    ''');
  }

  // Métodos para Gastos
  Future<int> insertExpense(Expense expense) async {
    Database db = await database;
    return await db.insert(tableExpenses, expense.toMap());
  }

  Future<int> updateExpense(Expense expense) async {
    Database db = await database;
    return await db.update(tableExpenses, expense.toMap(),
        where: '$columnId = ?', whereArgs: [expense.id]);
  }

  Future<int> deleteExpense(int id) async {
    Database db = await database;
    return await db.delete(tableExpenses, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<Expense?> getExpense(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(tableExpenses,
        where: '$columnId = ?', whereArgs: [id]);
    if (maps.length > 0) {
      return Expense.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Expense>> getAllExpenses() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(tableExpenses, orderBy: '$columnDate DESC');
    return List.generate(maps.length, (i) {
      return Expense.fromMap(maps[i]);
    });
  }

  Future<List<Expense>> getExpensesForBudget(int budgetId) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(tableExpenses,
        where: '$columnBudgetId = ?', whereArgs: [budgetId], orderBy: '$columnDate DESC');
    return List.generate(maps.length, (i) {
      return Expense.fromMap(maps[i]);
    });
  }

  Future<double> getTotalExpensesForBudget(int budgetId) async {
    Database db = await database;
    var result = await db.rawQuery(
        'SELECT SUM($columnAmount) as total FROM $tableExpenses WHERE $columnBudgetId = ?',
        [budgetId]);
    return result.first['total'] == null ? 0.0 : result.first['total'] as double;
  }

  // Métodos para Presupuestos
  Future<int> insertBudget(Budget budget) async {
    Database db = await database;
    return await db.insert(tableBudgets, budget.toMap());
  }

  Future<int> updateBudget(Budget budget) async {
    Database db = await database;
    return await db.update(tableBudgets, budget.toMap(),
        where: '$columnId = ?', whereArgs: [budget.id]);
  }

  Future<int> deleteBudget(int id) async {
    Database db = await database;
    return await db.delete(tableBudgets, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<Budget?> getBudget(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(tableBudgets,
        where: '$columnId = ?', whereArgs: [id]);
    if (maps.length > 0) {
      return Budget.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Budget>> getAllBudgets() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(tableBudgets, orderBy: '$columnName ASC');
    return List.generate(maps.length, (i) {
      return Budget.fromMap(maps[i]);
    });
  }

  Future<List<Budget>> getBudgetsForTrip(int tripId) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(tableBudgets,
        where: '$columnTripId = ?', whereArgs: [tripId], orderBy: '$columnName ASC');
    return List.generate(maps.length, (i) {
      return Budget.fromMap(maps[i]);
    });
  }

  // Métodos para Viajes
  Future<int> insertTrip(Trip trip) async {
    Database db = await database;
    return await db.insert(tableTrips, trip.toMap());
  }

  Future<int> updateTrip(Trip trip) async {
    Database db = await database;
    return await db.update(tableTrips, trip.toMap(),
        where: '$columnId = ?', whereArgs: [trip.id]);
  }

  Future<int> deleteTrip(int id) async {
    Database db = await database;
    return await db.delete(tableTrips, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<Trip?> getTrip(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(tableTrips,
        where: '$columnId = ?', whereArgs: [id]);
    if (maps.length > 0) {
      return Trip.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Trip>> getAllTrips() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(tableTrips, orderBy: '$columnStartDate DESC');
    return List.generate(maps.length, (i) {
      return Trip.fromMap(maps[i]);
    });
  }
}