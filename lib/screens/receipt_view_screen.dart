import 'dart:io';
import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../utils/formatters.dart';

class ReceiptViewScreen extends StatefulWidget {
  final Expense expense;
  final String imagePath;

  const ReceiptViewScreen({
    Key? key,
    required this.expense,
    required this.imagePath,
  }) : super(key: key);

  @override
  State<ReceiptViewScreen> createState() => _ReceiptViewScreenState();
}

class _ReceiptViewScreenState extends State<ReceiptViewScreen> {
  // Transformación para el zoom y pan
  final TransformationController _transformationController = TransformationController();
  
  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.expense.description,
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              '${Formatters.formatCurrency(widget.expense.amount, widget.expense.currencyCode)} - ${Formatters.formatDate(widget.expense.date)}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Implementar compartir imagen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Función de compartir en desarrollo'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Hero(
          tag: 'receipt_${widget.expense.id}',
          child: InteractiveViewer(
            transformationController: _transformationController,
            minScale: 0.5,
            maxScale: 4.0,
            child: Image.file(
              File(widget.imagePath),
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.broken_image,
                      color: Colors.white,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No se pudo cargar la imagen',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                      onPressed: () {
                        setState(() {});
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
      // Botones de control en la parte inferior
      bottomNavigationBar: BottomAppBar(
        color: Colors.black,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.zoom_out, color: Colors.white),
              onPressed: () {
                // Reducir zoom
                final scale = _transformationController.value.getMaxScaleOnAxis();
                if (scale > 0.8) {
                  _transformationController.value = Matrix4.identity()..scale(scale - 0.3);
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.zoom_in, color: Colors.white),
              onPressed: () {
                // Aumentar zoom
                final scale = _transformationController.value.getMaxScaleOnAxis();
                if (scale < 4.0) {
                  _transformationController.value = Matrix4.identity()..scale(scale + 0.3);
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.fit_screen, color: Colors.white),
              onPressed: () {
                // Restablecer a tamaño original
                _transformationController.value = Matrix4.identity();
              },
            ),
            IconButton(
              icon: const Icon(Icons.rotate_90_degrees_ccw, color: Colors.white),
              onPressed: () {
                // Rotar imagen (no implementado aún)
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Función de rotación en desarrollo'),
                    backgroundColor: Colors.blue,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}