import 'package:flutter/foundation.dart';

/// Sinaliza mudanças que afetam saldos derivados de mais de uma fonte de dados.
/// Páginas já abertas podem reagir sem depender de uma mudança no stream do Drift.
class FinanceiroNotifier {
  FinanceiroNotifier._();

  static final ValueNotifier<int> version = ValueNotifier<int>(0);

  static void bump() => version.value++;
}
