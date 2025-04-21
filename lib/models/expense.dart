import 'package:flutter/material.dart';

enum ExpenseCategory {
  transportation('Transporte'),
  accommodation('Alojamiento'),
  food('Alimentación general'),
  breakfast('Desayuno'),
  lunch('Comida'),
  dinner('Cena'),
  snacks('Snacks'),
  tickets('Entradas'),
  nightlife('Vida nocturna'),
  activities('Actividades'),
  shopping('Compras'),
  health('Salud'),
  gifts('Regalos'),
  other('Otros');

  final String displayName;
  const ExpenseCategory(this.displayName);

  IconData get icon {
    switch (this) {
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
        return Icons.cookie;
      case ExpenseCategory.tickets:
        return Icons.confirmation_number;
      case ExpenseCategory.nightlife:
        return Icons.nightlife;
      case ExpenseCategory.transportation:
        return Icons.directions_car;
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

  static ExpenseCategory fromString(String value) {
    return ExpenseCategory.values.firstWhere(
      (category) => category.toString() == value,
      orElse: () => ExpenseCategory.other,
    );
  }
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

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      budgetId: map['budget_id'],
      description: map['description'],
      amount: map['amount'],
      currencyCode: map['currency_code'] ?? '',
      isLocalCurrency: map['is_local_currency'] == 1,
      conversionRate: map['conversion_rate'] ?? 1.0,
      category: ExpenseCategory.fromString(map['category']),
      date: DateTime.parse(map['date']),
      imagePath: map['image_path'],
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'budget_id': budgetId,
      'description': description,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category.toString(),
      'image_path': imagePath,
      'notes': notes,
      'is_local_currency': isLocalCurrency ? 1 : 0,
      'currency_code': currencyCode,
      'conversion_rate': conversionRate,
    };
  }

  // Calcular el valor en la moneda base (origen)
  double get amountInBaseCurrency {
    if (isLocalCurrency) {
      return amount / conversionRate;
    } else {
      return amount;
    }
  }

  // Calcular el valor en la moneda local (destino)
  double get amountInLocalCurrency {
    if (isLocalCurrency) {
      return amount;
    } else {
      return amount * conversionRate;
    }
  }

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
}