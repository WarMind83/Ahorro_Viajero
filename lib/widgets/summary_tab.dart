import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/budget.dart';
import '../providers/expense_provider.dart';
import '../utils/formatters.dart';
import 'pie_chart_widget.dart';

class SummaryTab extends StatefulWidget {
  final Budget budget;

  const SummaryTab({
    Key? key,
    required this.budget,
  }) : super(key: key);

  @override
  State<SummaryTab> createState() => _SummaryTabState();
}

class _SummaryTabState extends State<SummaryTab> {
  late Future<Map<String, double>> _expensesFuture;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  @override
  void didUpdateWidget(SummaryTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si el presupuesto cambia (especialmente el tipo de cambio), actualizamos los datos
    if (oldWidget.budget.exchangeRate != widget.budget.exchangeRate ||
        oldWidget.budget.totalAmount != widget.budget.totalAmount ||
        oldWidget.budget.id != widget.budget.id) {
      _refreshData();
    }
  }

  void _refreshData() {
    setState(() {
      _expensesFuture = Provider.of<ExpenseProvider>(context, listen: false)
          .getExpenseSummaryCategorized(widget.budget.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Información del presupuesto',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildBudgetInfoRow(
                    'Presupuesto total:',
                    Formatters.formatCurrency(
                      widget.budget.totalAmount,
                      widget.budget.originCurrencyCode,
                    ),
                  ),
                  _buildBudgetInfoRow(
                    'Fechas:',
                    Formatters.formatDateRange(
                      widget.budget.startDate,
                      widget.budget.endDate,
                    ),
                  ),
                  _buildBudgetInfoRow(
                    'Tasa de cambio:',
                    '${widget.budget.exchangeRate.toStringAsFixed(2)} ${widget.budget.destinationCurrencyCode}/${widget.budget.originCurrencyCode}',
                  ),
                  if (widget.budget.notes != null && widget.budget.notes!.isNotEmpty)
                    _buildBudgetInfoRow('Notas:', widget.budget.notes!),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Gráfico circular de distribución de gastos por categoría
          FutureBuilder<Map<String, double>>(
            future: _expensesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Card(
                  elevation: 4,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: Text('No hay datos de gastos para mostrar'),
                    ),
                  ),
                );
              }
              
              // Calcular el total para pasar al gráfico
              final totalExpenses = snapshot.data!.values.fold(
                0.0, (sum, amount) => sum + amount);
              
              return Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ExpensePieChart(
                    expensesByCategory: snapshot.data!,
                    totalExpenses: totalExpenses,
                    totalBudget: widget.budget.totalAmount,
                    currencyCode: widget.budget.originCurrencyCode,
                  ),
                ),
              );
            },
          ),
          
          // Añadir espacio adicional al final para separarlo de la barra de navegación
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildBudgetInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}