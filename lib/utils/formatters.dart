import 'package:intl/intl.dart';

class Formatters {
  static String formatCurrency(double amount, String currencyCode) {
    final formatter = NumberFormat.currency(
      symbol: _getCurrencySymbol(currencyCode),
      decimalDigits: 2,
      locale: 'es_ES',
    );
    return formatter.format(amount);
  }

  static String _getCurrencySymbol(String currencyCode) {
    switch (currencyCode) {
      case 'EUR':
        return '€';
      case 'USD':
        return '\$';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      case 'CNY':
        return '¥';
      case 'KRW':
        return '₩';
      case 'RUB':
        return '₽';
      case 'INR':
        return '₹';
      case 'BRL':
        return 'R\$';
      case 'MXN':
        return '\$';
      case 'AUD':
        return 'A\$';
      case 'CAD':
        return 'C\$';
      case 'CHF':
        return 'Fr';
      case 'NZD':
        return 'NZ\$';
      case 'SGD':
        return 'S\$';
      case 'HKD':
        return 'HK\$';
      case 'SEK':
        return 'kr';
      case 'NOK':
        return 'kr';
      case 'DKK':
        return 'kr';
      case 'PLN':
        return 'zł';
      case 'TRY':
        return '₺';
      case 'THB':
        return '฿';
      case 'IDR':
        return 'Rp';
      case 'MYR':
        return 'RM';
      case 'PHP':
        return '₱';
      case 'TWD':
        return 'NT\$';
      case 'HUF':
        return 'Ft';
      case 'CZK':
        return 'Kč';
      case 'ILS':
        return '₪';
      case 'CLP':
        return '\$';
      case 'PKR':
        return '₨';
      case 'EGP':
        return '£';
      case 'KWD':
        return 'د.ك';
      case 'QAR':
        return 'ر.ق';
      case 'SAR':
        return 'ر.س';
      case 'AED':
        return 'د.إ';
      case 'ZAR':
        return 'R';
      default:
        return currencyCode;
    }
  }

  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String formatDateTime(DateTime dateTime) {
    final formatter = DateFormat('dd/MM/yyyy HH:mm', 'es_ES');
    return formatter.format(dateTime);
  }

  static String formatDateRange(DateTime startDate, DateTime? endDate) {
    final formatter = DateFormat('dd/MM/yyyy', 'es_ES');
    final start = formatter.format(startDate);
    final end = endDate != null ? formatter.format(endDate) : 'Presente';
    return '$start - $end';
  }

  static String formatPercentage(double value) {
    final formatter = NumberFormat.percentPattern();
    return formatter.format(value);
  }

  static double parseNumber(String value) {
    if (value.isEmpty) return 0;
    
    // Si el número contiene una coma, reemplazarla por punto
    if (value.contains(',')) {
      // Si hay más de una coma, solo reemplazar la última
      final parts = value.split(',');
      if (parts.length > 1) {
        final lastPart = parts.last;
        final mainPart = parts.sublist(0, parts.length - 1).join('');
        value = '$mainPart.$lastPart';
      } else {
        value = value.replaceAll(',', '.');
      }
    }
    
    try {
      return double.parse(value);
    } catch (e) {
      throw FormatException('Número inválido: $value');
    }
  }

  static String formatNumber(double value) {
    final formatter = NumberFormat('#,##0.00', 'es_ES');
    return formatter.format(value);
  }
}