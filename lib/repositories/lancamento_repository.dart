import 'package:drift/drift.dart';

import '../database/app_database.dart';

class LancamentoRepository {
  final AppDatabase db;

  LancamentoRepository(this.db);

  Future<List<Lancamento>> buscarTodas() {
    return db.select(db.lancamentos).get();
  }

  Stream<List<Lancamento>> observar() {
    return db.select(db.lancamentos).watch();
  }

  Future<int> salvar(LancamentosCompanion lancamento) {
    return db.into(db.lancamentos).insert(lancamento);
  }

  Future<int> atualizar({
    required int id,
    required String descricao,
    required double valor,
    required bool receita,
    required DateTime data,
    required int categoriaId,
    required int contaId,
    int? cartaoId,
  }) {
    return (db.update(db.lancamentos)
          ..where((t) => t.id.equals(id)))
        .write(
      LancamentosCompanion(
        descricao: Value(descricao),
        valor: Value(valor),
        receita: Value(receita),
        data: Value(data),
        categoriaId: Value(categoriaId),
        contaId: Value(contaId),
        cartaoId: Value(cartaoId),
      ),
    );
  }

  Future<int> excluir(int id) {
    return (db.delete(db.lancamentos)
          ..where((t) => t.id.equals(id)))
        .go();
  }

  /// Retorna os totais de receitas, despesas e resultado
  /// para o mês informado.
  Future<ResumoMensal> resumoMensal({
    required int mes,
    required int ano,
  }) async {
    final inicio = DateTime(ano, mes, 1);

    final fim = mes == 12
        ? DateTime(ano + 1, 1, 1)
        : DateTime(ano, mes + 1, 1);

    final lancamentos = await (db.select(db.lancamentos)
          ..where(
            (t) =>
                t.data.isBiggerOrEqualValue(inicio) &
                t.data.isSmallerThanValue(fim),
          ))
        .get();

    double receitas = 0;
    double despesas = 0;

    for (final lancamento in lancamentos) {
      if (lancamento.receita) {
        receitas += lancamento.valor;
      } else {
        despesas += lancamento.valor;
      }
    }

    final resultado = receitas - despesas;

    final taxaEconomia = receitas > 0
        ? resultado / receitas
        : 0.0;

    return ResumoMensal(
      receitas: receitas,
      despesas: despesas,
      resultado: resultado,
      taxaEconomia: taxaEconomia,
    );
  }

  /// Retorna o histórico financeiro dos últimos meses.
  ///
  /// O mês atual é o primeiro da lista.
  ///
  /// Por padrão, retorna os últimos 6 meses.
  Future<List<HistoricoMensal>> historicoMensal({
    int quantidade = 6,
    DateTime? referencia,
  }) async {
    final dataReferencia =
        referencia ?? DateTime.now();

    final historico = <HistoricoMensal>[];

    for (int i = 0; i < quantidade; i++) {
      final data = DateTime(
        dataReferencia.year,
        dataReferencia.month - i,
        1,
      );

      final resumo = await resumoMensal(
        mes: data.month,
        ano: data.year,
      );

      historico.add(
        HistoricoMensal(
          mes: data.month,
          ano: data.year,
          resumo: resumo,
        ),
      );
    }

    return historico;
  }

  /// Retorna os gastos agrupados por categoria
  /// para o mês informado.
  ///
  /// Apenas lançamentos de despesa são considerados.
  Future<List<GastoPorCategoria>> gastosPorCategoria({
    required int mes,
    required int ano,
  }) async {
    final inicio = DateTime(ano, mes, 1);

    final fim = mes == 12
        ? DateTime(ano + 1, 1, 1)
        : DateTime(ano, mes + 1, 1);

    final lancamentos = await (db.select(db.lancamentos)
          ..where(
            (t) =>
                t.receita.equals(false) &
                t.data.isBiggerOrEqualValue(inicio) &
                t.data.isSmallerThanValue(fim),
          ))
        .get();

    if (lancamentos.isEmpty) {
      return [];
    }

    final categorias = await db.select(db.categorias).get();

    final categoriasPorId = {
      for (final categoria in categorias)
        categoria.id: categoria,
    };

    final totais = <int, double>{};

    for (final lancamento in lancamentos) {
      totais.update(
        lancamento.categoriaId,
        (valorAtual) => valorAtual + lancamento.valor,
        ifAbsent: () => lancamento.valor,
      );
    }

    final resultado = <GastoPorCategoria>[];

    for (final entrada in totais.entries) {
      final categoria = categoriasPorId[entrada.key];

      if (categoria == null) {
        continue;
      }

      resultado.add(
        GastoPorCategoria(
          categoriaId: categoria.id,
          categoria: categoria.nome,
          icone: categoria.icone,
          cor: categoria.cor,
          valor: entrada.value,
        ),
      );
    }

    resultado.sort(
      (a, b) => b.valor.compareTo(a.valor),
    );

    final total = resultado.fold<double>(
      0,
      (soma, item) => soma + item.valor,
    );

    return [
      for (final item in resultado)
        item.comPercentual(
          total == 0 ? 0 : item.valor / total,
        ),
    ];
  }
}

class ResumoMensal {
  final double receitas;
  final double despesas;
  final double resultado;
  final double taxaEconomia;

  const ResumoMensal({
    required this.receitas,
    required this.despesas,
    required this.resultado,
    required this.taxaEconomia,
  });
}

class HistoricoMensal {
  final int mes;
  final int ano;
  final ResumoMensal resumo;

  const HistoricoMensal({
    required this.mes,
    required this.ano,
    required this.resumo,
  });
}

class GastoPorCategoria {
  final int categoriaId;
  final String categoria;
  final String icone;
  final int cor;
  final double valor;
  final double percentual;

  const GastoPorCategoria({
    required this.categoriaId,
    required this.categoria,
    required this.icone,
    required this.cor,
    required this.valor,
    this.percentual = 0,
  });

  GastoPorCategoria comPercentual(
    double novoPercentual,
  ) {
    return GastoPorCategoria(
      categoriaId: categoriaId,
      categoria: categoria,
      icone: icone,
      cor: cor,
      valor: valor,
      percentual: novoPercentual,
    );
  }
}