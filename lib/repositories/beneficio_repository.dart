import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/database_service.dart';

class BeneficioResumo {
  final double saldoAtual;
  final double saldoInicial;
  final double receitas;
  final double despesas;

  const BeneficioResumo({
    required this.saldoAtual,
    required this.saldoInicial,
    required this.receitas,
    required this.despesas,
  });
}

/// VR Flash funciona como uma carteira independente.
/// Não existe crédito mensal: o usuário informa um saldo inicial e registra
/// manualmente receitas e despesas. O saldo do VR não altera contas bancárias,
/// mas compõe o patrimônio.
class BeneficioRepository {
  static const _vrSaldoKey = 'horizonte_vr_flash_saldo_v3';
  static const _vrSaldoInicialKey = 'horizonte_vr_flash_saldo_inicial_v1';

  Future<bool> temMovimentacoes() async {
    final db = DatabaseService.instance.database;
    final itens = await (db.select(db.lancamentos)
          ..where((t) => t.origem.equals('beneficio:vr_flash'))
          ..limit(1))
        .get();
    return itens.isNotEmpty;
  }

  Future<double> saldoInicial() async {
    final prefs = await SharedPreferences.getInstance();
    final salvo = prefs.getDouble(_vrSaldoInicialKey);
    if (salvo != null) return salvo;

    // Migração silenciosa da versão anterior: preserva o saldo atual já usado
    // pelo usuário como ponto de partida, sem manter a lógica de crédito mensal.
    final legado = prefs.getDouble('horizonte_vr_flash_saldo_v2') ?? 0;
    if (legado != 0) {
      await prefs.setDouble(_vrSaldoInicialKey, legado);
    }
    return legado;
  }

  Future<void> salvarSaldoInicial(double valor) async {
    final saldo = valor.clamp(0, double.infinity).toDouble();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_vrSaldoInicialKey, saldo);
    await prefs.setDouble(_vrSaldoKey, saldo);
  }

  Future<double> saldoAtual() async {
    final prefs = await SharedPreferences.getInstance();
    final saldo = prefs.getDouble(_vrSaldoKey);
    if (saldo != null) return saldo;
    final inicial = await saldoInicial();
    await prefs.setDouble(_vrSaldoKey, inicial);
    return inicial;
  }

  Future<void> registrarGasto(double valor) async {
    if (valor <= 0) return;
    final atual = await saldoAtual();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_vrSaldoKey, atual - valor);
  }

  Future<void> registrarReceita(double valor) async {
    if (valor <= 0) return;
    final atual = await saldoAtual();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_vrSaldoKey, atual + valor);
  }

  Future<void> estornarGasto(double valor) async {
    if (valor <= 0) return;
    final atual = await saldoAtual();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_vrSaldoKey, atual + valor);
  }

  Future<void> estornarReceita(double valor) async {
    if (valor <= 0) return;
    final atual = await saldoAtual();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_vrSaldoKey, atual - valor);
  }

  Future<double> receitasTotais() async {
    final db = DatabaseService.instance.database;
    final itens = await (db.select(db.lancamentos)
          ..where((t) => t.origem.equals('beneficio:vr_flash') & t.receita.equals(true)))
        .get();
    return itens.fold<double>(0, (s, item) => s + item.valor);
  }

  Future<double> despesasTotais() async {
    final db = DatabaseService.instance.database;
    final itens = await (db.select(db.lancamentos)
          ..where((t) => t.origem.equals('beneficio:vr_flash') & t.receita.equals(false)))
        .get();
    return itens.fold<double>(0, (s, item) => s + item.valor);
  }

  Future<List<dynamic>> historicoLancamentos({int limite = 200}) async {
    final db = DatabaseService.instance.database;
    return (db.select(db.lancamentos)
          ..where((t) => t.origem.equals('beneficio:vr_flash'))
          ..orderBy([(t) => OrderingTerm.desc(t.data)])
          ..limit(limite))
        .get();
  }

  Future<BeneficioResumo> resumoMes({DateTime? referencia}) async {
    return BeneficioResumo(
      saldoAtual: await saldoAtual(),
      saldoInicial: await saldoInicial(),
      receitas: await receitasTotais(),
      despesas: await despesasTotais(),
    );
  }
}
