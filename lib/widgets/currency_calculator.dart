import 'package:flutter/material.dart';
import '../utils/formatters.dart';

class CurrencyCalculator extends StatefulWidget {
  final String originCurrencyCode;
  final String destinationCurrencyCode;
  final double exchangeRate;

  const CurrencyCalculator({
    Key? key,
    required this.originCurrencyCode,
    required this.destinationCurrencyCode,
    required this.exchangeRate,
  }) : super(key: key);

  @override
  State<CurrencyCalculator> createState() => _CurrencyCalculatorState();
}

class _CurrencyCalculatorState extends State<CurrencyCalculator> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  bool _isLocalCurrency = true;
  double? _convertedAmount;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _calculateConversion() {
    if (_formKey.currentState!.validate()) {
      try {
        final amount = Formatters.parseNumber(_amountController.text);
        setState(() {
          if (_isLocalCurrency) {
            // De moneda local a moneda de origen
            _convertedAmount = amount / widget.exchangeRate;
          } else {
            // De moneda de origen a moneda local
            _convertedAmount = amount * widget.exchangeRate;
          }
        });
      } catch (e) {
        setState(() {
          _convertedAmount = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Card con la tasa de cambio actual
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Tasa de cambio actual',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '1 ${widget.originCurrencyCode} = ${widget.exchangeRate} ${widget.destinationCurrencyCode}',
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Selector de dirección de conversión
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isLocalCurrency 
                                ? widget.destinationCurrencyCode 
                                : widget.originCurrencyCode,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.swap_horiz),
                            onPressed: () {
                              setState(() {
                                _isLocalCurrency = !_isLocalCurrency;
                                if (_amountController.text.isNotEmpty) {
                                  _calculateConversion();
                                }
                              });
                            },
                            tooltip: 'Cambiar dirección',
                          ),
                          Text(
                            _isLocalCurrency 
                                ? widget.originCurrencyCode 
                                : widget.destinationCurrencyCode,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _amountController,
                        decoration: InputDecoration(
                          labelText: 'Cantidad',
                          hintText: 'Introduce un importe',
                          prefixIcon: const Icon(Icons.attach_money),
                          suffixText: _isLocalCurrency 
                              ? widget.destinationCurrencyCode 
                              : widget.originCurrencyCode,
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        onChanged: (_) => _calculateConversion(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, introduce una cantidad';
                          }
                          try {
                            final amount = Formatters.parseNumber(value);
                            if (amount <= 0) {
                              return 'La cantidad debe ser mayor que cero';
                            }
                          } catch (e) {
                            return 'Por favor, introduce un número válido';
                          }
                          return null;
                        },
                      ),
                      if (_convertedAmount != null) ...[
                        const SizedBox(height: 24),
                        const Text(
                          'Resultado',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          Formatters.formatCurrency(
                            _convertedAmount!,
                            _isLocalCurrency 
                                ? widget.originCurrencyCode 
                                : widget.destinationCurrencyCode,
                          ),
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
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