import 'package:intl/intl.dart';

enum ExpenseCategory {
  transport,
  accommodation,
  food,
  breakfast,
  lunch,
  dinner,
  snacks,
  tickets,
  nightlife,
  activities,
  shopping,
  health,
  gifts,
  other
}

class Expense {
  final int? id;
  final int budgetId;
  final String description;
  final double amount;
  final String currencyCode;
  final bool isLocalCurrency;
  final double conversionRate;
  final ExpenseCategory category;
  final DateTime date;
  final String? imagePath;
  final String? notes;

  Expense({
    this.id,
    required this.budgetId,
    required this.description,
    required this.amount,
    required this.currencyCode,
    required this.isLocalCurrency,
    required this.conversionRate,
    required this.category,
    required this.date,
    this.imagePath,
    this.notes,
  });

  // Constructor de copia
  Expense copyWith({
    int? id,
    int? budgetId,
    String? description,
    double? amount,
    String? currencyCode,
    bool? isLocalCurrency,
    double? conversionRate,
    ExpenseCategory? category,
    DateTime? date,
    String? imagePath,
    String? notes,
  }) {
    return Expense(
      id: id ?? this.id,
      budgetId: budgetId ?? this.budgetId,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      currencyCode: currencyCode ?? this.currencyCode,
      isLocalCurrency: isLocalCurrency ?? this.isLocalCurrency,
      conversionRate: conversionRate ?? this.conversionRate,
      category: category ?? this.category,
      date: date ?? this.date,
      imagePath: imagePath ?? this.imagePath,
      notes: notes ?? this.notes,
    );
  }

  // Crear un Expense desde un Map (para trabajar con la base de datos)
  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      budgetId: map['budgetId'],
      description: map['description'],
      amount: map['amount'],
      currencyCode: map['currencyCode'],
      isLocalCurrency: map['isLocalCurrency'] == 1,
      conversionRate: map['conversionRate'],
      category: ExpenseCategory.values[map['category']],
      date: DateTime.parse(map['date']),
      imagePath: map['imagePath'],
      notes: map['notes'],
    );
  }

  // Convertir Expense a Map (para guardar en la base de datos)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'budgetId': budgetId,
      'description': description,
      'amount': amount,
      'currencyCode': currencyCode,
      'isLocalCurrency': isLocalCurrency ? 1 : 0,
      'conversionRate': conversionRate,
      'category': category.index,
      'date': date.toIso8601String(),
      'imagePath': imagePath,
      'notes': notes,
    };
  }

  // Obtener el monto convertido
  double get convertedAmount {
    if (isLocalCurrency) {
      // Si es moneda local, convertir a moneda de origen
      return amount / conversionRate;
    } else {
      // Si es moneda de origen, convertir a moneda local
      return amount * conversionRate;
    }
  }

  // Formato para mostrar la fecha
  String get formattedDate {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // Obtener el nombre de la categoría en español
  String get categoryName {
    switch (category) {
      case ExpenseCategory.transport:
        return 'Transporte';
      case ExpenseCategory.accommodation:
        return 'Alojamiento';
      case ExpenseCategory.food:
        return 'Alimentación';
      case ExpenseCategory.breakfast:
        return 'Desayuno';
      case ExpenseCategory.lunch:
        return 'Comida';
      case ExpenseCategory.dinner:
        return 'Cena';
      case ExpenseCategory.snacks:
        return 'Snacks';
      case ExpenseCategory.tickets:
        return 'Entradas';
      case ExpenseCategory.nightlife:
        return 'Vida nocturna';
      case ExpenseCategory.activities:
        return 'Actividades';
      case ExpenseCategory.shopping:
        return 'Compras';
      case ExpenseCategory.health:
        return 'Salud';
      case ExpenseCategory.gifts:
        return 'Regalos';
      case ExpenseCategory.other:
        return 'Otros';
    }
  }

  // Obtener el icono asociado a la categoría
  static IconData getCategoryIcon(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.transport:
        return Icons.directions_car;
      case ExpenseCategory.accommodation:
        return Icons.hotel;
      case ExpenseCategory.food:
        return Icons.restaurant;
      case ExpenseCategory.breakfast:
        return Icons.free_breakfast;
      case ExpenseCategory.lunch:
        return Icons.lunch_dining;
      case ExpenseCategory.dinner:
        return Icons.dinner_dining;
      case ExpenseCategory.snacks:
        return Icons.fastfood;
      case ExpenseCategory.tickets:
        return Icons.confirmation_number;
      case ExpenseCategory.nightlife:
        return Icons.nightlife;
      case ExpenseCategory.activities:
        return Icons.attractions;
      case ExpenseCategory.shopping:
        return Icons.shopping_bag;
      case ExpenseCategory.health:
        return Icons.medical_services;
      case ExpenseCategory.gifts:
        return Icons.card_giftcard;
      case ExpenseCategory.other:
        return Icons.more_horiz;
    }
  }
}