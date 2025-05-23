import '../models/currency.dart';

class CurrencyData {
  static final List<Currency> currencies = [
    Currency(code: 'EUR', name: 'Euro', symbol: '€'),
    Currency(code: 'USD', name: 'Dólar estadounidense', symbol: '\$'),
    Currency(code: 'GBP', name: 'Libra esterlina', symbol: '£'),
    Currency(code: 'JPY', name: 'Yen japonés', symbol: '¥'),
    Currency(code: 'CNY', name: 'Yuan chino', symbol: '¥'),
    Currency(code: 'AUD', name: 'Dólar australiano', symbol: 'A\$'),
    Currency(code: 'CAD', name: 'Dólar canadiense', symbol: 'C\$'),
    Currency(code: 'CHF', name: 'Franco suizo', symbol: 'Fr'),
    Currency(code: 'MXN', name: 'Peso mexicano', symbol: '\$'),
    Currency(code: 'BRL', name: 'Real brasileño', symbol: 'R\$'),
    Currency(code: 'ARS', name: 'Peso argentino', symbol: '\$'),
    Currency(code: 'COP', name: 'Peso colombiano', symbol: '\$'),
    Currency(code: 'PEN', name: 'Sol peruano', symbol: 'S/'),
    Currency(code: 'CLP', name: 'Peso chileno', symbol: '\$'),
    Currency(code: 'INR', name: 'Rupia india', symbol: '₹'),
    Currency(code: 'RUB', name: 'Rublo ruso', symbol: '₽'),
    Currency(code: 'TRY', name: 'Lira turca', symbol: '₺'),
    Currency(code: 'ZAR', name: 'Rand sudafricano', symbol: 'R'),
    Currency(code: 'THB', name: 'Baht tailandés', symbol: '฿'),
    Currency(code: 'SGD', name: 'Dólar de Singapur', symbol: 'S\$'),
    Currency(code: 'AED', name: 'Dirham de EAU', symbol: 'د.إ'),
    Currency(code: 'AFN', name: 'Afgani afgano', symbol: '؋'),
    Currency(code: 'ALL', name: 'Lek albanés', symbol: 'L'),
    Currency(code: 'AMD', name: 'Dram armenio', symbol: '֏'),
    Currency(code: 'AOA', name: 'Kwanza angoleño', symbol: 'Kz'),
    Currency(code: 'AWG', name: 'Florín arubeño', symbol: 'Afl.'),
    Currency(code: 'AZN', name: 'Manat azerbaiyano', symbol: '₼'),
    Currency(code: 'BAM', name: 'Marco convertible de Bosnia', symbol: 'KM'),
    Currency(code: 'BBD', name: 'Dólar de Barbados', symbol: 'Bds\$'),
    Currency(code: 'BDT', name: 'Taka bangladesí', symbol: '৳'),
    Currency(code: 'BGN', name: 'Lev búlgaro', symbol: 'лв'),
    Currency(code: 'BHD', name: 'Dinar bahreiní', symbol: '.د.ب'),
    Currency(code: 'BIF', name: 'Franco burundés', symbol: 'FBu'),
    Currency(code: 'BMD', name: 'Dólar bermudeño', symbol: 'BD\$'),
    Currency(code: 'BND', name: 'Dólar de Brunéi', symbol: 'B\$'),
    Currency(code: 'BOB', name: 'Boliviano', symbol: 'Bs'),
    Currency(code: 'BTN', name: 'Ngultrum butanés', symbol: 'Nu.'),
    Currency(code: 'BWP', name: 'Pula botsuanesa', symbol: 'P'),
    Currency(code: 'BYN', name: 'Rublo bielorruso', symbol: 'Br'),
    Currency(code: 'BZD', name: 'Dólar beliceño', symbol: 'BZ\$'),
    Currency(code: 'CRC', name: 'Colón costarricense', symbol: '₡'),
    Currency(code: 'CUP', name: 'Peso cubano', symbol: '\$'),
    Currency(code: 'CVE', name: 'Escudo caboverdiano', symbol: '\$'),
    Currency(code: 'CZK', name: 'Corona checa', symbol: 'Kč'),
    Currency(code: 'DJF', name: 'Franco yibutiano', symbol: 'Fdj'),
    Currency(code: 'DKK', name: 'Corona danesa', symbol: 'kr'),
    Currency(code: 'DOP', name: 'Peso dominicano', symbol: 'RD\$'),
    Currency(code: 'DZD', name: 'Dinar argelino', symbol: 'دج'),
    Currency(code: 'EGP', name: 'Libra egipcia', symbol: 'E£'),
    Currency(code: 'ERN', name: 'Nakfa eritreo', symbol: 'Nfk'),
    Currency(code: 'ETB', name: 'Birr etíope', symbol: 'Br'),
    Currency(code: 'FJD', name: 'Dólar fiyiano', symbol: 'FJ\$'),
    Currency(code: 'GEL', name: 'Lari georgiano', symbol: '₾'),
    Currency(code: 'GHS', name: 'Cedi ghanés', symbol: '₵'),
    Currency(code: 'GMD', name: 'Dalasi gambiano', symbol: 'D'),
    Currency(code: 'GTQ', name: 'Quetzal guatemalteco', symbol: 'Q'),
    Currency(code: 'HKD', name: 'Dólar de Hong Kong', symbol: 'HK\$'),
    Currency(code: 'HNL', name: 'Lempira hondureño', symbol: 'L'),
    Currency(code: 'HRK', name: 'Kuna croata', symbol: 'kn'),
    Currency(code: 'HTG', name: 'Gourde haitiano', symbol: 'G'),
    Currency(code: 'HUF', name: 'Forinto húngaro', symbol: 'Ft'),
    Currency(code: 'IDR', name: 'Rupia indonesia', symbol: 'Rp'),
    Currency(code: 'ILS', name: 'Nuevo séquel israelí', symbol: '₪'),
    Currency(code: 'IQD', name: 'Dinar iraquí', symbol: 'ع.د'),
    Currency(code: 'IRR', name: 'Rial iraní', symbol: '﷼'),
    Currency(code: 'ISK', name: 'Corona islandesa', symbol: 'kr'),
    Currency(code: 'JMD', name: 'Dólar jamaiquino', symbol: 'J\$'),
    Currency(code: 'JOD', name: 'Dinar jordano', symbol: 'JD'),
    Currency(code: 'KES', name: 'Chelín keniano', symbol: 'KSh'),
    Currency(code: 'KGS', name: 'Som kirguís', symbol: 'сом'),
    Currency(code: 'KHR', name: 'Riel camboyano', symbol: '៛'),
    Currency(code: 'KRW', name: 'Won surcoreano', symbol: '₩'),
    Currency(code: 'KWD', name: 'Dinar kuwaití', symbol: 'د.ك'),
    Currency(code: 'KZT', name: 'Tenge kazajo', symbol: '₸'),
    Currency(code: 'LAK', name: 'Kip laosiano', symbol: '₭'),
    Currency(code: 'LBP', name: 'Libra libanesa', symbol: 'ل.ل'),
    Currency(code: 'LKR', name: 'Rupia de Sri Lanka', symbol: 'Rs'),
    Currency(code: 'MAD', name: 'Dírham marroquí', symbol: 'د.م.'),
    Currency(code: 'MDL', name: 'Leu moldavo', symbol: 'L'),
    Currency(code: 'MKD', name: 'Denar macedonio', symbol: 'ден'),
    Currency(code: 'MMK', name: 'Kyat birmano', symbol: 'K'),
    Currency(code: 'MNT', name: 'Tugrik mongol', symbol: '₮'),
    Currency(code: 'MUR', name: 'Rupia mauriciana', symbol: '₨'),
    Currency(code: 'MVR', name: 'Rufiyaa maldiva', symbol: 'Rf'),
    Currency(code: 'MWK', name: 'Kwacha malauí', symbol: 'MK'),
    Currency(code: 'MYR', name: 'Ringgit malasio', symbol: 'RM'),
    Currency(code: 'NAD', name: 'Dólar namibio', symbol: 'N\$'),
    Currency(code: 'NGN', name: 'Naira nigeriano', symbol: '₦'),
    Currency(code: 'NIO', name: 'Córdoba nicaragüense', symbol: 'C\$'),
    Currency(code: 'NOK', name: 'Corona noruega', symbol: 'kr'),
    Currency(code: 'NPR', name: 'Rupia nepalí', symbol: 'रू'),
    Currency(code: 'NZD', name: 'Dólar neozelandés', symbol: 'NZ\$'),
    Currency(code: 'OMR', name: 'Rial omaní', symbol: 'ر.ع.'),
    Currency(code: 'PAB', name: 'Balboa panameño', symbol: 'B/.'),
    Currency(code: 'PHP', name: 'Peso filipino', symbol: '₱'),
    Currency(code: 'PKR', name: 'Rupia pakistaní', symbol: '₨'),
    Currency(code: 'PLN', name: 'Złoty polaco', symbol: 'zł'),
    Currency(code: 'PYG', name: 'Guaraní paraguayo', symbol: '₲'),
    Currency(code: 'QAR', name: 'Riyal catarí', symbol: 'ر.ق'),
    Currency(code: 'RON', name: 'Leu rumano', symbol: 'lei'),
    Currency(code: 'RSD', name: 'Dinar serbio', symbol: 'дин'),
    Currency(code: 'SAR', name: 'Riyal saudí', symbol: 'ر.س'),
    Currency(code: 'SCR', name: 'Rupia seychelense', symbol: 'SR'),
    Currency(code: 'SDG', name: 'Libra sudanesa', symbol: 'ج.س.'),
    Currency(code: 'SEK', name: 'Corona sueca', symbol: 'kr'),
    Currency(code: 'SYP', name: 'Libra siria', symbol: 'LS'),
    Currency(code: 'SZL', name: 'Lilangeni suazi', symbol: 'L'),
    Currency(code: 'TND', name: 'Dinar tunecino', symbol: 'د.ت'),
    Currency(code: 'TOP', name: 'Paʻanga tongano', symbol: 'T\$'),
    Currency(code: 'TTD', name: 'Dólar de Trinidad y Tobago', symbol: 'TT\$'),
    Currency(code: 'TWD', name: 'Nuevo dólar taiwanés', symbol: 'NT\$'),
    Currency(code: 'TZS', name: 'Chelín tanzano', symbol: 'TSh'),
    Currency(code: 'UAH', name: 'Grivna ucraniana', symbol: '₴'),
    Currency(code: 'UGX', name: 'Chelín ugandés', symbol: 'USh'),
    Currency(code: 'UYU', name: 'Peso uruguayo', symbol: '\$U'),
    Currency(code: 'UZS', name: 'Som uzbeko', symbol: 'лв'),
    Currency(code: 'VES', name: 'Bolívar soberano venezolano', symbol: 'Bs.S'),
    Currency(code: 'VND', name: 'Đồng vietnamita', symbol: '₫'),
    Currency(code: 'XAF', name: 'Franco CFA de África Central', symbol: 'FCFA'),
    Currency(code: 'XOF', name: 'Franco CFA de África Occidental', symbol: 'CFA'),
    Currency(code: 'XPF', name: 'Franco CFP', symbol: '₣'),
    Currency(code: 'YER', name: 'Rial yemení', symbol: '﷼'),
    Currency(code: 'ZMW', name: 'Kwacha zambiano', symbol: 'ZK'),
  ];

  static Currency? findByCode(String code) {
    try {
      return currencies.firstWhere((currency) => currency.code == code);
    } catch (e) {
      return null;
    }
  }

  static String getSymbol(String code) {
    final currency = findByCode(code);
    return currency?.symbol ?? code;
  }
}