import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/budget.dart';
import '../models/expense.dart';
import '../providers/budget_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/ad_manager.dart';
import '../utils/formatters.dart';
import '../widgets/expense_list.dart';
import '../widgets/summary_tab.dart';
import '../widgets/currency_calculator.dart';
import '../widgets/receipt_gallery.dart';
import '../widgets/ad_banner_widget.dart';
import 'add_expense_screen.dart';
import 'edit_budget_screen.dart';

class BudgetDetailScreen extends StatefulWidget {
  final Budget budget;

  const BudgetDetailScreen({
    Key? key,
    required this.budget,
  }) : super(key: key);

  @override
  State<BudgetDetailScreen> createState() => _BudgetDetailScreenState();
}

class _BudgetDetailScreenState extends State<BudgetDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  List<Expense> expenses = [];
  List<Expense> filteredExpenses = [];
  String _searchQuery = '';
  bool _isFirstBuild = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Asegurarse de establecer el presupuesto actual en el provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Cargar los gastos específicamente para este presupuesto
      final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
      expenseProvider.loadExpenses(widget.budget.id ?? 0);
      _refreshExpenses();
    });
    
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void didUpdateWidget(BudgetDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si el presupuesto cambia (especialmente el tipo de cambio), actualizamos los gastos
    if (oldWidget.budget.exchangeRate != widget.budget.exchangeRate ||
        oldWidget.budget.totalAmount != widget.budget.totalAmount) {
      // Recalcular gastos con el nuevo tipo de cambio
      _refreshExpenses();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshExpenses() async {
    setState(() {
      _isLoading = true;
    });
    
    // Limpiar los gastos anteriores
    setState(() {
      expenses = [];
      filteredExpenses = [];
    });
    
    // Obtener los gastos específicamente para este presupuesto
    final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
    
    // Actualizar la lista de gastos directamente desde la base de datos
    final budgetExpenses = await expenseProvider.getExpensesForBudget(widget.budget.id ?? 0);
    
    setState(() {
      _isLoading = false;
      expenses = budgetExpenses;
      _filterExpenses();
    });
  }

  void _navigateToAddExpense() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddExpenseScreen(budget: widget.budget),
      ),
    ).then((_) => _refreshExpenses());
  }

  void _showDeleteBudgetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Presupuesto'),
        content: const Text('¿Estás seguro de que deseas eliminar este presupuesto? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<BudgetProvider>().deleteBudget(widget.budget.id!);
              Navigator.pop(context);
              Navigator.pop(context); // Volver a la pantalla principal
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showEditBudgetDialog(BuildContext context) {
    final amountController = TextEditingController(text: widget.budget.totalAmount.toString());
    final exchangeRateController = TextEditingController(text: widget.budget.exchangeRate.toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modificar Presupuesto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Presupuesto',
                prefixText: '${widget.budget.originCurrencyCode}',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: exchangeRateController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Tasa de cambio',
                suffixText: '${widget.budget.destinationCurrencyCode}/${widget.budget.originCurrencyCode}',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final newAmount = Formatters.parseNumber(amountController.text);
                final newExchangeRate = Formatters.parseNumber(exchangeRateController.text);
                
                if (newAmount > 0 && newExchangeRate > 0) {
                  // Actualizar presupuesto en el provider
                  await context.read<BudgetProvider>().updateBudgetAmountAndExchangeRate(
                    widget.budget.id!, 
                    newAmount, 
                    newExchangeRate
                  );

                  // Obtener el presupuesto actualizado de la base de datos
                  final updatedBudget = await context.read<BudgetProvider>().getBudgetById(widget.budget.id!);
                  
                  // Cerrar el diálogo
                  Navigator.pop(context);
                  
                  if (updatedBudget != null) {
                    // Actualizar la instancia del presupuesto en esta pantalla
                    // y refrescar el estado para que se reflejen los cambios
                    setState(() {
                      // No podemos modificar widget.budget directamente, pero podemos forzar
                      // una reconstrucción de la pantalla
                    });
                    
                    // Refrescar listas de gastos para actualizar conversiones
                    await _refreshExpenses();
                    
                    // Mostrar mensaje de éxito
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Presupuesto actualizado correctamente'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    
                    // Recrear la pantalla con el presupuesto actualizado
                    if (mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BudgetDetailScreen(budget: updatedBudget),
                        ),
                      );
                    }
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Ambos valores deben ser mayores que cero'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error al actualizar: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _navigateToEditBudgetScreen() async {
    final updatedBudget = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditBudgetScreen(budget: widget.budget),
      ),
    );

    if (updatedBudget != null) {
      // Refrescar pantalla con el nuevo presupuesto
      await _refreshExpenses();

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BudgetDetailScreen(budget: updatedBudget),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizedBudget = widget.budget;
    final adManager = Provider.of<AdManager>(context);
    
    // Mostrar anuncio intersticial ocasionalmente al abrir una pantalla de detalle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!adManager.isAdFree && _isFirstBuild) {
        _isFirstBuild = false;
        // Mostrar el anuncio solo el 20% de las veces
        if (DateTime.now().millisecond % 5 == 0) {
          adManager.showInterstitialAd();
        }
      }
    });
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          localizedBudget.title,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'editQuick':
                  _showEditBudgetDialog(context);
                  break;
                case 'editFull':
                  _navigateToEditBudgetScreen();
                  break;
                case 'delete':
                  _showDeleteBudgetDialog(context);
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'editQuick',
                child: Row(
                  children: [
                    Icon(Icons.money),
                    SizedBox(width: 8),
                    Text('Modificar monto y tasa'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'editFull',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text('Editar presupuesto completo'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Eliminar', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          indicatorWeight: 3,
          labelPadding: const EdgeInsets.symmetric(horizontal: 12),
          tabs: const [
            Tab(
              icon: Icon(Icons.money),
              text: 'GASTOS',
            ),
            Tab(
              icon: Icon(Icons.photo_library),
              text: 'GALERÍA',
            ),
            Tab(
              icon: Icon(Icons.pie_chart),
              text: 'RESUMEN',
            ),
            Tab(
              icon: Icon(Icons.calculate),
              text: 'CALCULADORA',
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Banner de anuncios (ahora en la parte superior)
          if (!adManager.isAdFree) const AdBannerWidget(location: 'budget_detail'),
          
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      // Pestaña de lista de gastos
                      _buildExpensesTab(context),
                  
                      // Pestaña de galería de recibos
                      ReceiptGallery(
                        expenses: expenses.where((e) => e.imagePath != null).toList(),
                        budget: localizedBudget,
                        onExpenseUpdated: _refreshExpenses,
                      ),
                  
                      // Pestaña de resumen
                      SummaryTab(
                        budget: localizedBudget,
                      ),
                  
                      // Pestaña de calculadora de conversión
                      CurrencyCalculator(
                        originCurrencyCode: localizedBudget.originCurrencyCode,
                        destinationCurrencyCode: localizedBudget.destinationCurrencyCode,
                        exchangeRate: localizedBudget.exchangeRate,
                      ),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: _navigateToAddExpense,
              tooltip: 'Añadir nuevo gasto',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildExpensesTab(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'Buscar gastos',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
                _filterExpenses();
              });
            },
          ),
        ),
        Expanded(
          child: ExpenseList(
            expenses: filteredExpenses.isEmpty ? expenses : filteredExpenses,
            budget: widget.budget,
            onExpenseDeleted: () async {
              // Forzar actualización de la lista de gastos
              await _refreshExpenses();
              
              // Forzar actualización del presupuesto principal
              final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);
              await budgetProvider.refreshBudgets();
            },
            onExpenseUpdated: _refreshExpenses,
          ),
        ),
      ],
    );
  }

  void _filterExpenses() {
    if (_searchQuery.isEmpty) {
      filteredExpenses = List.from(expenses);
    } else {
      filteredExpenses = expenses
          .where((expense) =>
              expense.description.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
    setState(() {});
  }
}