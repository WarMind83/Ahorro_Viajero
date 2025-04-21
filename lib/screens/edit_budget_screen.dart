import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/budget.dart';
import '../models/currency.dart';
import '../providers/budget_provider.dart';
import '../utils/currency_data.dart';
import '../utils/formatters.dart';

class EditBudgetScreen extends StatefulWidget {
  final Budget budget;

  const EditBudgetScreen({
    Key? key,
    required this.budget,
  }) : super(key: key);

  @override
  State<EditBudgetScreen> createState() => _EditBudgetScreenState();
}

class _EditBudgetScreenState extends State<EditBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _exchangeRateController;
  late TextEditingController _notesController;
  
  late String _originCurrencyCode;
  late String _destinationCurrencyCode;
  late DateTime _startDate;
  DateTime? _endDate;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.budget.title);
    _amountController = TextEditingController(text: widget.budget.totalAmount.toString());
    _exchangeRateController = TextEditingController(text: widget.budget.exchangeRate.toString());
    _notesController = TextEditingController(text: widget.budget.notes ?? '');
    
    _originCurrencyCode = widget.budget.originCurrencyCode;
    _destinationCurrencyCode = widget.budget.destinationCurrencyCode;
    _startDate = widget.budget.startDate;
    _endDate = widget.budget.endDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _exchangeRateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
        // Si la fecha de fin es anterior a la fecha de inicio, la resetea
        if (_endDate != null && _endDate!.isBefore(_startDate)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate.add(const Duration(days: 7)),
      firstDate: _startDate,
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Future<void> _updateBudget() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final updatedBudget = Budget(
          id: widget.budget.id,
          title: _titleController.text,
          totalAmount: Formatters.parseNumber(_amountController.text),
          originCurrencyCode: _originCurrencyCode,
          destinationCurrencyCode: _destinationCurrencyCode,
          exchangeRate: Formatters.parseNumber(_exchangeRateController.text),
          startDate: _startDate,
          endDate: _endDate,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
        );

        await context.read<BudgetProvider>().updateBudget(updatedBudget);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Presupuesto actualizado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, updatedBudget);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar el presupuesto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Presupuesto'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _updateBudget,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Título del presupuesto
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Título del viaje',
                        hintText: 'Ej: Vacaciones en París',
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, ingresa un título';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Presupuesto total
                    TextFormField(
                      controller: _amountController,
                      decoration: InputDecoration(
                        labelText: 'Presupuesto total',
                        hintText: 'Ej: 1500,50',
                        prefixIcon: const Icon(Icons.account_balance_wallet),
                        suffixText: _originCurrencyCode,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, ingresa el monto';
                        }
                        try {
                          final amount = Formatters.parseNumber(value);
                          if (amount <= 0) {
                            return 'El monto debe ser mayor que cero';
                          }
                        } catch (e) {
                          return 'Por favor, ingresa un número válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Moneda de origen
                    DropdownButtonFormField<String>(
                      value: _originCurrencyCode,
                      decoration: const InputDecoration(
                        labelText: 'Moneda de origen',
                        prefixIcon: Icon(Icons.money),
                      ),
                      items: CurrencyData.currencies.map((Currency currency) {
                        return DropdownMenuItem<String>(
                          value: currency.code,
                          child: Text('${currency.code} - ${currency.name}'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _originCurrencyCode = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Moneda de destino
                    DropdownButtonFormField<String>(
                      value: _destinationCurrencyCode,
                      decoration: const InputDecoration(
                        labelText: 'Moneda de destino',
                        prefixIcon: Icon(Icons.currency_exchange),
                      ),
                      items: CurrencyData.currencies.map((Currency currency) {
                        return DropdownMenuItem<String>(
                          value: currency.code,
                          child: Text('${currency.code} - ${currency.name}'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _destinationCurrencyCode = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Tasa de cambio manual
                    TextFormField(
                      controller: _exchangeRateController,
                      decoration: InputDecoration(
                        labelText: 'Tasa de cambio',
                        hintText: 'Ej: 1,08',
                        prefixIcon: const Icon(Icons.sync_alt),
                        suffixText: '$_destinationCurrencyCode/$_originCurrencyCode',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, ingresa la tasa de cambio';
                        }
                        try {
                          final rate = Formatters.parseNumber(value);
                          if (rate <= 0) {
                            return 'La tasa debe ser mayor que cero';
                          }
                        } catch (e) {
                          return 'Por favor, ingresa un número válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Fechas
                    const Text(
                      'Fechas del viaje',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Fecha de inicio
                    ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: const Text('Fecha de inicio'),
                      subtitle: Text(DateFormat('dd/MM/yyyy').format(_startDate)),
                      onTap: () => _selectStartDate(context),
                    ),
                    
                    // Fecha de fin (opcional)
                    ListTile(
                      leading: const Icon(Icons.event),
                      title: const Text('Fecha de fin (opcional)'),
                      subtitle: _endDate != null
                          ? Text(DateFormat('dd/MM/yyyy').format(_endDate!))
                          : const Text('No seleccionada'),
                      onTap: () => _selectEndDate(context),
                      trailing: _endDate != null
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _endDate = null;
                                });
                              },
                            )
                          : null,
                    ),
                    const SizedBox(height: 16),
                    
                    // Notas
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notas (opcional)',
                        hintText: 'Información adicional',
                        prefixIcon: Icon(Icons.note),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32),
                    
                    ElevatedButton(
                      onPressed: _updateBudget,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                      ),
                      child: const Text('GUARDAR CAMBIOS'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}