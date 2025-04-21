import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/formatters.dart';

class ExpensePieChart extends StatefulWidget {
  final Map<String, double> expensesByCategory;
  final double totalExpenses;
  final double totalBudget;
  final String currencyCode;

  const ExpensePieChart({
    Key? key,
    required this.expensesByCategory,
    required this.totalExpenses,
    required this.totalBudget,
    required this.currencyCode,
  }) : super(key: key);

  @override
  State<ExpensePieChart> createState() => _ExpensePieChartState();
}

class _ExpensePieChartState extends State<ExpensePieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final remainingBudget = widget.totalBudget - widget.totalExpenses;
    final isOverBudget = remainingBudget < 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Distribución del presupuesto',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 5,
            children: [
              Text(
                'Presupuesto: ${Formatters.formatCurrency(widget.totalBudget, widget.currencyCode)}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                'Gastado: ${Formatters.formatCurrency(widget.totalExpenses, widget.currencyCode)}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                'Disponible: ${Formatters.formatCurrency(remainingBudget, widget.currencyCode)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isOverBudget ? Colors.red : Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: widget.expensesByCategory.isEmpty && remainingBudget <= 0
                ? Center(
                    child: Text(
                      'No hay datos para mostrar',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  )
                : PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              touchedIndex = -1;
                              return;
                            }
                            touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 0,
                      centerSpaceRadius: 35,
                      sections: _showingSections(remainingBudget),
                    ),
                  ),
          ),
          const SizedBox(height: 8),
          _buildLegend(remainingBudget),
        ],
      ),
    );
  }

  List<PieChartSectionData> _showingSections(double remainingBudget) {
    final entries = widget.expensesByCategory.entries.toList();
    final sections = <PieChartSectionData>[];
    
    // Añadir las secciones para cada categoría de gasto
    for (var i = 0; i < entries.length; i++) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 20.0 : 14.0;
      final radius = isTouched ? 55.0 : 45.0;
      
      final entry = entries[i];
      final categoryName = entry.key;
      final value = entry.value;
      final percentage = widget.totalBudget > 0 
          ? (value / widget.totalBudget * 100).toStringAsFixed(1) + '%'
          : '0%';
      
      sections.add(
        PieChartSectionData(
          color: _getCategoryColor(categoryName),
          value: value,
          title: percentage,
          radius: radius,
          titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: const [Shadow(color: Colors.black, blurRadius: 2)],
          ),
        )
      );
    }
    
    // Añadir la sección para el presupuesto restante (si es positivo)
    if (remainingBudget > 0) {
      final isTouched = entries.length == touchedIndex;
      final fontSize = isTouched ? 20.0 : 14.0;
      final radius = isTouched ? 55.0 : 45.0;
      
      final percentage = widget.totalBudget > 0 
          ? (remainingBudget / widget.totalBudget * 100).toStringAsFixed(1) + '%'
          : '0%';
      
      sections.add(
        PieChartSectionData(
          color: Colors.lightBlue.shade100,
          value: remainingBudget,
          title: percentage,
          radius: radius,
          titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            shadows: const [Shadow(color: Colors.white, blurRadius: 2)],
          ),
        )
      );
    }
    
    return sections;
  }

  Widget _buildLegend(double remainingBudget) {
    final items = widget.expensesByCategory.entries.toList();
    final allItems = <Widget>[];
    
    // Crear elementos de leyenda para cada categoría
    for (var entry in items) {
      final categoryName = entry.key;
      final value = entry.value;
      final percentage = widget.totalBudget > 0
          ? (value / widget.totalBudget * 100).toStringAsFixed(1)
          : '0';
      
      allItems.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getCategoryColor(categoryName),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: Text(
                  categoryName,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  '${Formatters.formatCurrency(value, widget.currencyCode)} ($percentage%)',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        )
      );
    }
    
    // Añadir elemento de leyenda para el presupuesto disponible
    if (remainingBudget > 0) {
      final percentage = widget.totalBudget > 0
          ? (remainingBudget / widget.totalBudget * 100).toStringAsFixed(1)
          : '0';
      
      allItems.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.lightBlue.shade100,
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                flex: 2,
                child: Text(
                  'Disponible',
                  style: TextStyle(fontSize: 13),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  '${Formatters.formatCurrency(remainingBudget, widget.currencyCode)} ($percentage%)',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        )
      );
    }
    
    // Añadir espacio extra al final
    allItems.add(const SizedBox(height: 16));
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: allItems
    );
  }

  Color _getCategoryColor(String categoryName) {
    switch (categoryName) {
      case 'Transporte':
        return Colors.blue;
      case 'Alojamiento':
        return Colors.green;
      case 'Alimentación general':
        return Colors.orange;
      case 'Desayuno':
        return Colors.amber;
      case 'Comida':
        return Colors.deepOrange;
      case 'Cena':
        return Colors.brown;
      case 'Snacks':
        return Colors.orangeAccent;
      case 'Entradas':
        return Colors.indigo;
      case 'Vida nocturna':
        return Colors.deepPurple;
      case 'Actividades':
        return Colors.purple;
      case 'Compras':
        return Colors.red;
      case 'Salud':
        return Colors.teal;
      case 'Regalos':
        return Colors.pink;
      case 'Otros':
        return Colors.grey;
      default:
        return Colors.blueGrey;
    }
  }
}