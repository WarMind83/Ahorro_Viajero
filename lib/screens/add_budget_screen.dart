import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/budget.dart';
import '../providers/budget_provider.dart';
import '../utils/currency_data.dart';
import '../widgets/currency_selector.dart';

class AddBudgetScreen extends StatefulWidget {
  final Budget? budget;

  const AddBudgetScreen({Key? key, this.budget}) : super(key: key);

  @override
  State<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends State<AddBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _destinationController = TextEditingController();
  final _notesController = TextEditingController();
  
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));
  String _selectedCurrency = 'USD';
  bool _isEditing = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.budget != null;
    
    if (_isEditing) {
      final budget = widget.budget!;
      _titleController.text = budget.title;
      _amountController.text = budget.amount.toString();
      _destinationController.text = budget.destination;
      _notesController.text = budget.notes ?? '';
      _startDate = budget.startDate;
      _endDate = budget.endDate;
      _selectedCurrency = budget.currencyCode;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _destinationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // Selector de fecha
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final initialDate = isStartDate ? _startDate : _endDate;
    final firstDate = isStartDate ? DateTime.now().subtract(const Duration(days: 365)) : _startDate;
    final lastDate = isStartDate 
        ? _endDate.isBefore(DateTime.now().add(const Duration(days: 365 * 2)))
            ? _endDate
            : DateTime.now().add(const Duration(days: 365 * 2))
        : DateTime.now().add(const Duration(days: 365 * 2));

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = pickedDate;
          // Si la fecha de inicio es posterior a la de fin, actualizar la fecha de fin
          if (_startDate.isAfter(_endDate)) {
            _endDate = _startDate.add(const Duration(days: 1));
          }
        } else {
          _endDate = pickedDate;
        }
      });
    }
  }

  // Guardar el presupuesto
  Future<void> _saveBudget() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);
      
      final budget = Budget(
        id: _isEditing ? widget.budget!.id : null,
        title: _titleController.text.trim(),
        destination: _destinationController.text.trim(),
        amount: double.parse(_amountController.text.replaceAll(',', '.')),
        currencyCode: _selectedCurrency,
        startDate: _startDate,
        endDate: _endDate,
        notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
        createdAt: _isEditing ? widget.budget!.createdAt : DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (_isEditing) {
        await budgetProvider.updateBudget(budget);
      } else {
        await budgetProvider.addBudget(budget);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar presupuesto' : 'Nuevo presupuesto'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Título
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título del viaje',
                  prefixIcon: Icon(Icons.title),
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, introduce un título';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Destino
              TextFormField(
                controller: _destinationController,
                decoration: const InputDecoration(
                  labelText: 'Destino',
                  prefixIcon: Icon(Icons.location_on),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, introduce un destino';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Fechas (en fila en pantallas grandes, en columna en pequeñas)
              isLargeScreen
                  ? Row(
                      children: [
                        Expanded(child: _buildDateField(context, true)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildDateField(context, false)),
                      ],
                    )
                  : Column(
                      children: [
                        _buildDateField(context, true),
                        const SizedBox(height: 16),
                        _buildDateField(context, false),
                      ],
                    ),
              const SizedBox(height: 16),
              
              // Presupuesto y moneda (en fila en pantallas grandes, en columna en pequeñas)
              isLargeScreen
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildAmountField(),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 1,
                          child: _buildCurrencySelector(),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        _buildAmountField(),
                        const SizedBox(height: 16),
                        _buildCurrencySelector(),
                      ],
                    ),
              const SizedBox(height: 16),
              
              // Notas
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notas (opcional)',
                  prefixIcon: Icon(Icons.note),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 24),
              
              // Botón de guardar
              ElevatedButton(
                onPressed: _isSubmitting ? null : _saveBudget,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_isEditing ? 'Actualizar presupuesto' : 'Guardar presupuesto'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget para el campo de fecha
  Widget _buildDateField(BuildContext context, bool isStartDate) {
    final date = isStartDate ? _startDate : _endDate;
    final formattedDate = DateFormat('dd/MM/yyyy').format(date);
    
    return InkWell(
      onTap: () => _selectDate(context, isStartDate),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: isStartDate ? 'Fecha de inicio' : 'Fecha de fin',
          prefixIcon: Icon(isStartDate ? Icons.calendar_today : Icons.calendar_month),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(formattedDate),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  // Widget para el campo de cantidad
  Widget _buildAmountField() {
    return TextFormField(
      controller: _amountController,
      decoration: const InputDecoration(
        labelText: 'Presupuesto total',
        prefixIcon: Icon(Icons.attach_money),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Por favor, introduce un presupuesto';
        }
        final amount = double.tryParse(value.replaceAll(',', '.'));
        if (amount == null || amount <= 0) {
          return 'Por favor, introduce un presupuesto válido';
        }
        return null;
      },
    );
  }

  // Widget para el selector de moneda
  Widget _buildCurrencySelector() {
    return CurrencySelector(
      selectedCurrency: _selectedCurrency,
      onChanged: (currency) {
        setState(() {
          _selectedCurrency = currency;
        });
      },
    );
  }
}