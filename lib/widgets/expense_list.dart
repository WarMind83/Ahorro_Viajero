import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/budget.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';
import 'expense_list_item.dart';

class ExpenseList extends StatelessWidget {
  final List<Expense> expenses;
  final Budget budget;
  final VoidCallback onExpenseDeleted;
  final VoidCallback onExpenseUpdated;

  const ExpenseList({
    Key? key,
    required this.expenses,
    required this.budget,
    required this.onExpenseDeleted,
    required this.onExpenseUpdated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay gastos registrados',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Toca el botón + para añadir uno nuevo',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<ExpenseProvider>().refreshExpenses();
        onExpenseUpdated();
      },
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: expenses.length,
        itemBuilder: (context, index) {
          final expense = expenses[index];
          return ExpenseListItem(
            key: ValueKey('expense_item_${expense.id}'),
            expense: expense,
            budget: budget,
            onDelete: () {
              context.read<ExpenseProvider>().refreshExpenses().then((_) {
                onExpenseUpdated();
              });
            },
          );
        },
      ),
    );
  }
}