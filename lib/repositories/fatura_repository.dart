import 'package:drift/drift.dart';

import '../database/app_database.dart';

class FaturaRepository {
  final AppDatabase db;

  FaturaRepository(this.db);

  Future<List<Fatura>> buscarTodas() {
    return db.select(db.faturas).get();
  }

  Stream<List<Fatura>> observar() {
    return db.select(db.faturas).watch();
  }

  Future<Fatura?> buscarPorId(int id) async {
    final resultado = await (db.select(db.faturas)
          ..where((t) => t.id.equals(id)))
        .get();

    if (resultado.isEmpty) {
      return null;
    }

    return resultado.first;
  }

  Future<Fatura?> buscarPorCartaoEReferencia({
    required int cartaoId,
    required int mes,
    required int ano,
  }) async {
    final resultado = await (db.select(db.faturas)
          ..where(
            (t) =>
                t.cartaoId.equals(cartaoId) &
                t.mesReferencia.equals(mes) &
                t.anoReferencia.equals(ano),
          ))
        .get();

    if (resultado.isEmpty) {
      return null;
    }

    return resultado.first;
  }

  Future<int> criar({
    required int cartaoId,
    required int mes,
    required int ano,
  }) {
    return db.into(db.faturas).insert(
          FaturasCompanion.insert(
            cartaoId: cartaoId,
            mesReferencia: mes,
            anoReferencia: ano,
          ),
        );
  }

  Future<double> calcularTotal(int faturaId) async {
    final fatura = await buscarPorId(faturaId);

    if (fatura == null) {
      return 0;
    }

    final cartao = await (db.select(db.cartoes)
          ..where((t) => t.id.equals(fatura.cartaoId)))
        .getSingle();

    final periodo = _calcularPeriodo(
      mes: fatura.mesReferencia,
      ano: fatura.anoReferencia,
      diaFechamento: cartao.fechamento,
    );

    final lancamentos = await (db.select(db.lancamentos)
          ..where(
            (t) =>
                t.cartaoId.equals(fatura.cartaoId) &
                t.receita.equals(false) &
                t.data.isBiggerOrEqualValue(periodo.inicio) &
                t.data.isSmallerOrEqualValue(periodo.fim),
          ))
        .get();

    double total = 0;

    for (final lancamento in lancamentos) {
      total += lancamento.valor;
    }

    return total;
  }

  Future<List<Lancamento>> buscarLancamentos(
    int faturaId,
  ) async {
    final fatura = await buscarPorId(faturaId);

    if (fatura == null) {
      return [];
    }

    final cartao = await (db.select(db.cartoes)
          ..where((t) => t.id.equals(fatura.cartaoId)))
        .getSingle();

    final periodo = _calcularPeriodo(
      mes: fatura.mesReferencia,
      ano: fatura.anoReferencia,
      diaFechamento: cartao.fechamento,
    );

    return (db.select(db.lancamentos)
          ..where(
            (t) =>
                t.cartaoId.equals(fatura.cartaoId) &
                t.receita.equals(false) &
                t.data.isBiggerOrEqualValue(periodo.inicio) &
                t.data.isSmallerOrEqualValue(periodo.fim),
          )
          ..orderBy([
            (t) => OrderingTerm.asc(t.data),
          ]))
        .get();
  }

  Future<int> marcarComoPaga({
    required int faturaId,
    required DateTime dataPagamento,
  }) {
    return (db.update(db.faturas)
          ..where((t) => t.id.equals(faturaId)))
        .write(
      FaturasCompanion(
        paga: const Value(true),
        dataPagamento: Value(dataPagamento),
      ),
    );
  }

  _PeriodoFatura _calcularPeriodo({
    required int mes,
    required int ano,
    required int diaFechamento,
  }) {
    final fechamento = DateTime(
      ano,
      mes,
      diaFechamento,
    );

    final fechamentoAnterior = DateTime(
      ano,
      mes - 1,
      diaFechamento,
    );

    final inicio = fechamentoAnterior.add(
      const Duration(days: 1),
    );

    final fim = DateTime(
      fechamento.year,
      fechamento.month,
      fechamento.day,
      23,
      59,
      59,
      999,
    );

    return _PeriodoFatura(
      inicio: inicio,
      fim: fim,
    );
  }
}

class _PeriodoFatura {
  final DateTime inicio;
  final DateTime fim;

  const _PeriodoFatura({
    required this.inicio,
    required this.fim,
  });
}