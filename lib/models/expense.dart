class Expense {
  final int? id;
  final double amount;
  final String description;
  final int budgetId;
  final String category;
  final String date;
  final String createdAt;
  final String updatedAt;

  Expense({
    this.id,
    required this.amount,
    required this.description,
    required this.budgetId,
    required this.category,
    required this.date,
    String? createdAt,
    String? updatedAt,
  }) : 
    this.createdAt = createdAt ?? DateTime.now().toIso8601String(),
    this.updatedAt = updatedAt ?? DateTime.now().toIso8601String();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'description': description,
      'budget_id': budgetId,
      'category': category,
      'date': date,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  static Expense fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      amount: map['amount'],
      description: map['description'],
      budgetId: map['budget_id'],
      category: map['category'],
      date: map['date'],
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
    );
  }

  Expense copyWith({
    int? id,
    double? amount,
    String? description,
    int? budgetId,
    String? category,
    String? date,
    String? createdAt,
    String? updatedAt,
  }) {
    return Expense(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      budgetId: budgetId ?? this.budgetId,
      category: category ?? this.category,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now().toIso8601String(),
    );
  }
}