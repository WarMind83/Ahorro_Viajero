import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../models/expense.dart';
import '../models/budget.dart';
import '../utils/formatters.dart';
import '../providers/expense_provider.dart';
import '../screens/expense_detail_screen.dart';

class ExpenseListItem extends StatelessWidget {
  final Expense expense;
  final Budget budget;
  final VoidCallback? onDelete;

  const ExpenseListItem({
    Key? key,
    required this.expense,
    required this.budget,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor(expense.category);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: () => _navigateToDetail(context),
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Icono de categoría
              CircleAvatar(
                radius: 22,
                backgroundColor: categoryColor.withAlpha(25),
                child: Icon(
                  expense.category.icon,
                  color: categoryColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              
              // Contenido central (descripción, categoría, etc.)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Fila superior: descripción y monto
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            expense.description,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          Formatters.formatCurrency(
                            expense.amount,
                            expense.currencyCode,
                          ),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Fila inferior: categoría y monto en moneda local
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: categoryColor.withAlpha(25),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            expense.category.displayName,
                            style: TextStyle(
                              color: categoryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        // Mostrar siempre el equivalente en la otra moneda
                        Text(
                          expense.isLocalCurrency
                            ? '${Formatters.formatCurrency(expense.amountInBaseCurrency, budget.originCurrencyCode)}'
                            : '${Formatters.formatCurrency(expense.amountInLocalCurrency, budget.destinationCurrencyCode)}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Icono de comprobante si existe
              if (expense.imagePath != null)
                FutureBuilder<bool>(
                  future: _doesImageExist(expense.imagePath),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      );
                    }
                    
                    if (snapshot.data == true) {
                      return const Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Icon(Icons.receipt_long, color: Colors.blue, size: 24),
                      );
                    } else {
                      // Si no existe, corregimos la referencia en segundo plano
                      Future.microtask(() => _getFixedImagePath(expense.imagePath));
                      return const SizedBox.shrink();
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  Future<bool> _doesImageExist(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) return false;
    
    try {
      final file = File(imagePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }
  
  Future<String?> _getFixedImagePath(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) return null;
    
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        return imagePath;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Color _getCategoryColor(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.transportation:
        return Colors.blue;
      case ExpenseCategory.accommodation:
        return Colors.green;
      case ExpenseCategory.food:
        return Colors.orange;
      case ExpenseCategory.breakfast:
        return Colors.amber;
      case ExpenseCategory.lunch:
        return Colors.deepOrange;
      case ExpenseCategory.dinner:
        return Colors.brown;
      case ExpenseCategory.snacks:
        return Colors.orangeAccent;
      case ExpenseCategory.tickets:
        return Colors.indigo;
      case ExpenseCategory.nightlife:
        return Colors.deepPurple;
      case ExpenseCategory.activities:
        return Colors.purple;
      case ExpenseCategory.shopping:
        return Colors.red;
      case ExpenseCategory.health:
        return Colors.teal;
      case ExpenseCategory.gifts:
        return Colors.pink;
      case ExpenseCategory.other:
        return Colors.grey;
    }
  }

  // Método para manejar el tap en el gasto
  void _navigateToDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExpenseDetailScreen(
          expense: expense,
          budget: budget,
        ),
      ),
    ).then((_) {
      // Forzar actualización
      if (onDelete != null) {
        onDelete!();
      }
    });
  }
}