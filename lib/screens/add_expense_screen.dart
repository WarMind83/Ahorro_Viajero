import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/budget.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';
import '../utils/formatters.dart';

class AddExpenseScreen extends StatefulWidget {
  final Budget budget;

  const AddExpenseScreen({
    Key? key,
    required this.budget,
  }) : super(key: key);

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  
  ExpenseCategory _selectedCategory = ExpenseCategory.food;
  bool _isLocalCurrency = true;
  DateTime _date = DateTime.now();
  String _currencyCode = '';
  XFile? _imageFile;
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();
  bool _isSaving = false;
  late Expense _currentExpense;

  @override
  void initState() {
    super.initState();
    _currencyCode = _isLocalCurrency 
        ? widget.budget.destinationCurrencyCode 
        : widget.budget.originCurrencyCode;
    
    // Inicializar el gasto actual
    _currentExpense = Expense(
      budgetId: widget.budget.id ?? 0,
      description: '',
      amount: 0,
      currencyCode: _currencyCode,
      isLocalCurrency: _isLocalCurrency,
      conversionRate: widget.budget.exchangeRate,
      category: _selectedCategory,
      date: _date,
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date.isAfter(widget.budget.startDate) && 
                  (widget.budget.endDate == null || _date.isBefore(widget.budget.endDate!)) 
          ? _date 
          : widget.budget.startDate,
      firstDate: widget.budget.startDate,
      lastDate: widget.budget.endDate ?? DateTime(2030),
      locale: const Locale('es', 'ES'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      // Validar que la fecha esté dentro del rango del presupuesto
      if (picked.isBefore(widget.budget.startDate)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('La fecha debe ser posterior al ${DateFormat('dd/MM/yyyy').format(widget.budget.startDate)}'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
      
      if (widget.budget.endDate != null && picked.isAfter(widget.budget.endDate!)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('La fecha debe ser anterior al ${DateFormat('dd/MM/yyyy').format(widget.budget.endDate!)}'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
      
      setState(() {
        _date = picked;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (!mounted) return;
      
      if (pickedFile != null) {
        // Obtener el directorio de documentos de la aplicación
        final appDir = await getApplicationDocumentsDirectory();
        final receiptsDir = Directory('${appDir.path}/receipts');
        
        // Crear el directorio si no existe
        if (!await receiptsDir.exists()) {
          await receiptsDir.create(recursive: true);
        }

        // Generar un nombre único para la imagen
        final fileName = 'receipt_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final savedImage = File('${receiptsDir.path}/$fileName');

        // Copiar la imagen desde el archivo temporal al directorio permanente
        await File(pickedFile.path).copy(savedImage.path);

        if (!mounted) return;
        
        setState(() {
          _imageFile = XFile(savedImage.path);
        });

        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comprobante guardado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error al guardar el comprobante: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar el comprobante: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onCurrencyTypeChanged(bool value) {
    setState(() {
      _isLocalCurrency = value;
      _currencyCode = _isLocalCurrency 
          ? widget.budget.destinationCurrencyCode 
          : widget.budget.originCurrencyCode;
    });
  }

  void _saveExpense() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Prevenir múltiples guardados
      if (_isSaving) return;
      setState(() => _isSaving = true);

      try {
        final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
        
        // Crear el objeto Expense con los datos del formulario
        final expense = Expense(
          budgetId: widget.budget.id ?? 0,
          description: _descriptionController.text,
          amount: Formatters.parseNumber(_amountController.text),
          currencyCode: _currencyCode,
          isLocalCurrency: _isLocalCurrency,
          conversionRate: widget.budget.exchangeRate,
          category: _selectedCategory,
          date: _date,
          imagePath: _imageFile?.path,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
        );
        
        await expenseProvider.addExpense(expense);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gasto añadido correctamente')),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        // Manejar error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al guardar: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isSaving = false);
        }
      }
    }
  }

  // Método para desplazarse al campo de notas cuando se enfoca
  void _scrollToFieldWhenFocused() {
    // Esperar a que el teclado aparezca antes de desplazarse
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Añadir Gasto'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                top: 16.0,
                bottom: 80.0, // Padding aumentado para evitar superposición con la barra de navegación
              ),
              controller: _scrollController,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Descripción del gasto
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                        hintText: 'Ej: Cena en restaurante',
                        prefixIcon: Icon(Icons.description),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, ingresa una descripción';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Tipo de moneda (switch entre moneda local y moneda origen)
                    Row(
                      children: [
                        const Text('Moneda:'),
                        const Spacer(),
                        const Text('Origen'),
                        Switch(
                          value: _isLocalCurrency,
                          onChanged: _onCurrencyTypeChanged,
                        ),
                        const Text('Destino'),
                      ],
                    ),
                    
                    // Monto
                    TextFormField(
                      controller: _amountController,
                      decoration: InputDecoration(
                        labelText: 'Monto',
                        hintText: 'Ej: 25,50',
                        prefixIcon: const Icon(Icons.attach_money),
                        suffixText: _currencyCode,
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
                    
                    // Categoría del gasto
                    DropdownButtonFormField<ExpenseCategory>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Categoría',
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: ExpenseCategory.values.map((ExpenseCategory category) {
                        return DropdownMenuItem<ExpenseCategory>(
                          value: category,
                          child: Text(category.displayName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Fecha del gasto
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_today),
                      title: const Text('Fecha del gasto'),
                      subtitle: Text(DateFormat('dd/MM/yyyy').format(_date)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _selectDate(context),
                    ),
                    
                    // Foto del comprobante (opcional)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.photo_camera),
                      title: const Text('Comprobante (opcional)'),
                      subtitle: _imageFile != null
                          ? Text('Imagen capturada')
                          : const Text('Capturar foto del comprobante'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: _pickImage,
                    ),
                    if (_imageFile != null)
                      Container(
                        height: 200,
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(_imageFile!.path),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    
                    // Notas adicionales (opcional)
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notas (opcional)',
                        hintText: 'Información adicional sobre el gasto',
                        prefixIcon: Icon(Icons.note),
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 5,
                      onTap: _scrollToFieldWhenFocused,
                    ),
                    const SizedBox(height: 32),
                    
                    // Botón guardar
                    ElevatedButton(
                      onPressed: _saveExpense,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'GUARDAR GASTO',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}