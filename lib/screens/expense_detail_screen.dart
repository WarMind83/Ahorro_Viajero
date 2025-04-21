import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/expense.dart';
import '../models/budget.dart';
import '../providers/expense_provider.dart';
import '../utils/formatters.dart';
import 'receipt_view_screen.dart';

class ExpenseDetailScreen extends StatefulWidget {
  final Expense expense;
  final Budget budget;

  const ExpenseDetailScreen({
    Key? key,
    required this.expense,
    required this.budget,
  }) : super(key: key);

  @override
  State<ExpenseDetailScreen> createState() => _ExpenseDetailScreenState();
}

class _ExpenseDetailScreenState extends State<ExpenseDetailScreen> {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;
  late TextEditingController _notesController;
  late ExpenseCategory _selectedCategory;
  late bool _isLocalCurrency;
  late DateTime _date;
  String? _currentImagePath;
  bool _hasUnsavedChanges = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _descriptionController = TextEditingController(text: widget.expense.description);
    _amountController = TextEditingController(text: widget.expense.amount.toString());
    _notesController = TextEditingController(text: widget.expense.notes ?? '');
    _selectedCategory = widget.expense.category;
    _isLocalCurrency = widget.expense.isLocalCurrency;
    _date = widget.expense.date;
    _currentImagePath = widget.expense.imagePath;
    _hasUnsavedChanges = false;
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
      initialDate: _date,
      firstDate: widget.budget.startDate,
      lastDate: widget.budget.endDate ?? DateTime(2030),
      locale: const Locale('es', 'ES'),
    );
    if (picked != null && picked != _date) {
      setState(() {
        _date = picked;
      });
    }
  }

  void _toggleEdit() {
    if (_isEditing && _currentImagePath != widget.expense.imagePath) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Guardar cambios'),
          content: const Text('¿Quieres guardar los cambios realizados?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _initializeControllers();
                  _isEditing = false;
                });
              },
              child: const Text('Descartar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _saveChanges();
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      );
    } else {
      setState(() {
        if (_isEditing) {
          _initializeControllers();
        }
        _isEditing = !_isEditing;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final appDir = await getApplicationDocumentsDirectory();
        final receiptsDir = Directory('${appDir.path}/receipts');
        
        if (!await receiptsDir.exists()) {
          await receiptsDir.create(recursive: true);
        }

        final fileName = 'receipt_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final savedImage = File('${receiptsDir.path}/$fileName');

        await File(pickedFile.path).copy(savedImage.path);

        if (_currentImagePath != null && _currentImagePath != widget.expense.imagePath) {
          final oldFile = File(_currentImagePath!);
          if (await oldFile.exists()) {
            await oldFile.delete();
          }
        }

        setState(() {
          _currentImagePath = savedImage.path;
          _hasUnsavedChanges = true;
        });

        final updatedExpense = widget.expense.copyWith(
          imagePath: savedImage.path,
        );

        await context.read<ExpenseProvider>().updateExpense(updatedExpense);
        
        if (mounted) {
          await context.read<ExpenseProvider>().refreshExpenses();
          setState(() {
            _hasUnsavedChanges = false;
          });
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Comprobante actualizado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar el comprobante: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteImage() async {
    try {
      final file = File(widget.expense.imagePath!);
      if (await file.exists()) {
        await file.delete();
      }
      
      // Actualizar el gasto sin la imagen
      final updatedExpense = widget.expense.copyWith(imagePath: null);
      await context.read<ExpenseProvider>().updateExpense(updatedExpense);
      
      // Mostrar mensaje y actualizar UI
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Imagen eliminada')),
        );
        setState(() {
          _currentImagePath = null;
          _hasUnsavedChanges = true;
        });
      }
    } catch (e) {
      // Error al eliminar la imagen
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al eliminar la imagen'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      final updatedExpense = widget.expense.copyWith(
        description: _descriptionController.text,
        amount: Formatters.parseNumber(_amountController.text),
        category: _selectedCategory,
        date: _date,
        isLocalCurrency: _isLocalCurrency,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        imagePath: _currentImagePath,
      );

      context.read<ExpenseProvider>().updateExpense(updatedExpense).then((_) {
        return context.read<ExpenseProvider>().refreshExpenses();
      }).then((_) {
        setState(() {
          _isEditing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gasto actualizado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      });
    }
  }

  void _deleteExpense() {
    if (_currentImagePath != widget.expense.imagePath) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Guardar cambios'),
          content: const Text('Has añadido una imagen. ¿Quieres guardar los cambios antes de eliminar el gasto?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showDeleteConfirmationDialog();
              },
              child: const Text('No guardar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                
                final updatedExpense = widget.expense.copyWith(
                  imagePath: _currentImagePath,
                );
                await context.read<ExpenseProvider>().updateExpense(updatedExpense);
                
                _showDeleteConfirmationDialog();
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      );
    } else {
      _showDeleteConfirmationDialog();
    }
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Gasto'),
        content: const Text('¿Estás seguro de que deseas eliminar este gasto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              // Cerrar el diálogo de confirmación
              Navigator.pop(context);
              
              _deleteExpenseWithIndicator();
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  
  Future<void> _deleteExpenseWithIndicator() async {
    if (!mounted) return;
    
    // Mostrar indicador de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              const Text("Eliminando gasto..."),
            ],
          ),
        );
      },
    );
    
    try {
      // Eliminar el gasto
      await context.read<ExpenseProvider>().deleteExpense(widget.expense.id!);
      
      // Cerrar el diálogo de carga
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      
      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gasto eliminado correctamente'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Volver a la pantalla anterior
      Navigator.of(context).pop();
    } catch (e) {
      print('Error al eliminar el gasto: $e');
      
      // Cerrar el diálogo de carga si está abierto
      if (mounted) {
        try {
          Navigator.of(context, rootNavigator: true).pop();
        } catch (_) {
          // Ignorar errores si el diálogo ya estaba cerrado
        }
        
        // Mostrar mensaje de error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar el gasto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Método para desplazarse al campo de notas cuando se enfoca
  void _scrollToNotesField() {
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
    return WillPopScope(
      onWillPop: () async {
        if (_hasUnsavedChanges) {
          bool? shouldPop = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Guardar cambios'),
              content: const Text('¿Quieres guardar los cambios antes de salir?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Descartar'),
                ),
                TextButton(
                  onPressed: () async {
                    final updatedExpense = widget.expense.copyWith(
                      imagePath: _currentImagePath,
                    );
                    await context.read<ExpenseProvider>().updateExpense(updatedExpense);
                    await context.read<ExpenseProvider>().refreshExpenses();
                    Navigator.pop(context, true);
                  },
                  child: const Text('Guardar'),
                ),
              ],
            ),
          );
          return shouldPop ?? false;
        }
        
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: const Text('Detalles del Gasto'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (!_hasUnsavedChanges) {
                Navigator.of(context).pop();
                return;
              }
              
              showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Guardar cambios'),
                  content: const Text('¿Quieres guardar los cambios antes de salir?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.of(context).pop();
                      },
                      child: const Text('Descartar'),
                    ),
                    TextButton(
                      onPressed: () async {
                        final updatedExpense = widget.expense.copyWith(
                          imagePath: _currentImagePath,
                        );
                        await context.read<ExpenseProvider>().updateExpense(updatedExpense);
                        await context.read<ExpenseProvider>().refreshExpenses();
                        
                        Navigator.of(context).pop();
                      },
                      child: const Text('Guardar'),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            IconButton(
              icon: Icon(_isEditing ? Icons.close : Icons.edit),
              onPressed: _toggleEdit,
            ),
            if (_isEditing)
              IconButton(
                icon: const Icon(Icons.check),
                onPressed: _saveChanges,
              )
            else
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: _deleteExpense,
              ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: 16.0, 
            right: 16.0,
            top: 16.0,
            bottom: 80.0, // Padding fijo para evitar superposición con la barra de navegación
          ),
          controller: _scrollController,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    prefixIcon: Icon(Icons.description),
                  ),
                  enabled: _isEditing,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingresa una descripción';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _amountController,
                        decoration: InputDecoration(
                          labelText: 'Monto',
                          prefixIcon: const Icon(Icons.attach_money),
                          suffixText: _isLocalCurrency 
                              ? widget.budget.destinationCurrencyCode 
                              : widget.budget.originCurrencyCode,
                        ),
                        enabled: _isEditing,
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
                    ),
                    if (_isEditing) ...[
                      const SizedBox(width: 16),
                      DropdownButton<bool>(
                        value: _isLocalCurrency,
                        items: [
                          DropdownMenuItem(
                            value: true,
                            child: Text(widget.budget.destinationCurrencyCode),
                          ),
                          DropdownMenuItem(
                            value: false,
                            child: Text(widget.budget.originCurrencyCode),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _isLocalCurrency = value;
                            });
                          }
                        },
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                
                // Mostrar el equivalente en la otra moneda
                if (!_isEditing) 
                  Padding(
                    padding: const EdgeInsets.only(left: 40.0),
                    child: Text(
                      _isLocalCurrency
                        ? 'Equivalente: ${Formatters.formatCurrency(
                            widget.expense.amountInBaseCurrency,
                            widget.budget.originCurrencyCode
                          )}'
                        : 'Equivalente: ${Formatters.formatCurrency(
                            widget.expense.amountInLocalCurrency,
                            widget.budget.destinationCurrencyCode
                          )}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ),
                const SizedBox(height: 12),

                if (_isEditing)
                  DropdownButtonFormField<ExpenseCategory>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Categoría',
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: ExpenseCategory.values.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category.displayName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      }
                    },
                  )
                else
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      _selectedCategory.icon,
                      color: Theme.of(context).primaryColor,
                    ),
                    title: const Text('Categoría'),
                    subtitle: Text(_selectedCategory.displayName),
                  ),
                const SizedBox(height: 16),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Fecha'),
                  subtitle: Text(DateFormat('dd/MM/yyyy').format(_date)),
                  trailing: _isEditing ? const Icon(Icons.arrow_forward_ios, size: 16) : null,
                  onTap: _isEditing ? () => _selectDate(context) : null,
                ),
                const SizedBox(height: 16),

                if (_currentImagePath != null || _isEditing) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Comprobante',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_isEditing)
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.camera_alt),
                              onPressed: _pickImage,
                              tooltip: 'Tomar nueva foto',
                            ),
                            if (_currentImagePath != null)
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: _deleteImage,
                                tooltip: 'Eliminar foto',
                              ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_currentImagePath != null)
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReceiptViewScreen(
                              expense: widget.expense.copyWith(imagePath: _currentImagePath),
                              imagePath: _currentImagePath!,
                            ),
                          ),
                        );
                      },
                      child: Hero(
                        tag: 'receipt_${widget.expense.id}',
                        child: Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(_currentImagePath!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    )
                  else if (_isEditing)
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey,
                          width: 2,
                          style: BorderStyle.solid,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Stack(
                        children: [
                          CustomPaint(
                            size: const Size(double.infinity, 200),
                            painter: DashedBorderPainter(color: Colors.grey),
                          ),
                          InkWell(
                            onTap: _pickImage,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.camera_alt, size: 48, color: Colors.grey),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Toca para tomar una foto',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                ],

                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notas',
                    prefixIcon: Icon(Icons.note),
                    border: OutlineInputBorder(),
                  ),
                  enabled: _isEditing,
                  maxLines: 5,
                  onTap: _isEditing ? _scrollToNotesField : null,
                ),
                // Espacio adicional al final para evitar que la barra de navegación virtual bloquee el contenido
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;

  DashedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const double dashWidth = 5;
    const double dashSpace = 5;
    double startX = 0;
    final double endX = size.width;
    double startY = 0;
    final double endY = size.height;

    while (startX < endX) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      canvas.drawLine(
        Offset(startX, size.height),
        Offset(startX + dashWidth, size.height),
        paint,
      );
      startX += dashWidth + dashSpace;
    }

    while (startY < endY) {
      canvas.drawLine(
        Offset(0, startY),
        Offset(0, startY + dashWidth),
        paint,
      );
      canvas.drawLine(
        Offset(size.width, startY),
        Offset(size.width, startY + dashWidth),
        paint,
      );
      startY += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}