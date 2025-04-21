class Currency {
  final String code;
  final String name;
  final String symbol;

  Currency({
    required this.code,
    required this.name,
    required this.symbol,
  });
  
  // Lista predefinida de monedas comunes
  static List<Currency> commonCurrencies = [
    Currency(code: 'EUR', name: 'Euro', symbol: '€'),
    Currency(code: 'USD', name: 'Dólar estadounidense', symbol: '\$'),
    Currency(code: 'GBP', name: 'Libra esterlina', symbol: '£'),
    Currency(code: 'JPY', name: 'Yen japonés', symbol: '¥'),
    Currency(code: 'MXN', name: 'Peso mexicano', symbol: '\$'),
    Currency(code: 'CAD', name: 'Dólar canadiense', symbol: '\$'),
    Currency(code: 'AUD', name: 'Dólar australiano', symbol: '\$'),
    Currency(code: 'CHF', name: 'Franco suizo', symbol: 'Fr'),
  ];
}