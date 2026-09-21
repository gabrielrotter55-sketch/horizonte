import 'package:intl/intl.dart';

class Formatters {
  static final NumberFormat _moeda = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  static String moeda(double valor) {
    return _moeda.format(valor);
  }
}