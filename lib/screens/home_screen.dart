import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/budget_provider.dart';
import '../providers/ad_manager.dart';
import '../models/budget.dart';
import 'add_budget_screen.dart';
import 'budget_detail_screen.dart';
import 'settings_screen.dart';
import '../widgets/budget_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadBudgets();
  }

  // Cargar presupuestos
  Future<void> _loadBudgets() async {
    setState(() => _isLoading = true);
    
    try {
      await Provider.of<BudgetProvider>(context, listen: false).refreshBudgets();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar presupuestos: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Ir a la pantalla de añadir presupuesto
  void _goToAddBudget() async {
    final result = await Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => const AddBudgetScreen(),
      ),
    );
    
    if (result == true) {
      _loadBudgets();
    }
  }

  // Ir a la pantalla de detalle de presupuesto
  void _goToBudgetDetail(Budget budget) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BudgetDetailScreen(budget: budget),
      ),
    );
    
    if (result == true) {
      _loadBudgets();
    }
  }

  // Ir a la pantalla de configuración
  void _goToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  // Eliminar un presupuesto
  Future<void> _deleteBudget(Budget budget) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar presupuesto'),
        content: Text('¿Estás seguro de que quieres eliminar "${budget.title}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    ) ?? false;
    
    if (confirm) {
      setState(() => _isLoading = true);
      
      try {
        final success = await Provider.of<BudgetProvider>(context, listen: false)
            .deleteBudget(budget.id!);
            
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Presupuesto eliminado correctamente')),
          );
          // Mostrar anuncio intersticial ocasionalmente
          final adManager = Provider.of<AdManager>(context, listen: false);
          adManager.showInterstitialAd();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al eliminar presupuesto: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ahorro Viajero'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _goToSettings,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadBudgets,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Consumer<BudgetProvider>(
                builder: (context, budgetProvider, child) {
                  final budgets = budgetProvider.budgets;
                  
                  if (budgets.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.airplane_ticket, size: 80, color: Colors.grey),
                            const SizedBox(height: 16),
                            const Text(
                              'No tienes presupuestos de viaje',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Añade tu primer presupuesto para comenzar a gestionar tus gastos de viaje',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: _goToAddBudget,
                              icon: const Icon(Icons.add),
                              label: const Text('Añadir presupuesto'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: budgets.length,
                    itemBuilder: (context, index) {
                      final budget = budgets[index];
                      return BudgetCard(
                        budget: budget,
                        onTap: () => _goToBudgetDetail(budget),
                        onDelete: () => _deleteBudget(budget),
                      );
                    },
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToAddBudget,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: Consumer<AdManager>(
        builder: (context, adManager, child) {
          if (adManager.isAdFree || adManager.bannerAd == null) {
            return const SizedBox.shrink();
          }
          
          return Container(
            height: 50,
            alignment: Alignment.center,
            child: AdWidget(ad: adManager.bannerAd!),
          );
        },
      ),
    );
  }
}