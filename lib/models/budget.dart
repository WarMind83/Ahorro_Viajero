import 'package:intl/intl.dart';

class Budget {
  final int? id;
  final String title;
  final double totalAmount;
  final String originCurrencyCode;
  final String destinationCurrencyCode;
  final double exchangeRate;
  final DateTime startDate;
  final DateTime? endDate;
  final String? notes;

  Budget({
    this.id,
    required this.title,
    required this.totalAmount,
    required this.originCurrencyCode,
    required this.destinationCurrencyCode,
    required this.exchangeRate,
    required this.startDate,
    this.endDate,
    this.notes,
  });

  // Constructor de copia con campos opcionales para cambiar
  Budget copyWith({
    int? id,
    String? title,
    double? totalAmount,
    String? originCurrencyCode,
    String? destinationCurrencyCode,
    double? exchangeRate,
    DateTime? startDate,
    DateTime? endDate,
    String? notes,
  }) {
    return Budget(
      id: id ?? this.id,
      title: title ?? this.title,
      totalAmount: totalAmount ?? this.totalAmount,
      originCurrencyCode: originCurrencyCode ?? this.originCurrencyCode,
      destinationCurrencyCode: destinationCurrencyCode ?? this.destinationCurrencyCode,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      notes: notes ?? this.notes,
    );
  }

  // Crear un Budget desde un Map (para trabajar con la base de datos)
  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'],
      title: map['title'],
      totalAmount: map['totalAmount'],
      originCurrencyCode: map['originCurrencyCode'],
      destinationCurrencyCode: map['destinationCurrencyCode'],
      exchangeRate: map['exchangeRate'],
      startDate: DateTime.parse(map['startDate']),
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
      notes: map['notes'],
    );
  }

  // Convertir Budget a Map (para guardar en la base de datos)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'totalAmount': totalAmount,
      'originCurrencyCode': originCurrencyCode,
      'destinationCurrencyCode': destinationCurrencyCode,
      'exchangeRate': exchangeRate,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'notes': notes,
    };
  }

  // Formato para mostrar la fecha
  String get formattedDate {
    final dateFormat = DateFormat('dd/MM/yyyy');
    if (endDate != null) {
      return '${dateFormat.format(startDate)} - ${dateFormat.format(endDate!)}';
    } else {
      return dateFormat.format(startDate);
    }
  }
}