import 'package:drift/drift.dart';

import '../database/app_database.dart';

class ContaRepository {
  final AppDatabase db;

  ContaRepository(this.db);

  Future<List<Conta>> buscarTodas() {
    return db.select(db.contas).get();
  }

  Stream<List<Conta>> observar() {
    return db.select(db.contas).watch();
  }

  Future salvar(ContasCompanion conta) {
    return db.into(db.contas).insert(conta);
  }

  Future atualizar({
    required int id,
    required String nome,
    required double saldoInicial,
    required String tipo,
  }) {
    return (db.update(db.contas)
          ..where((t) => t.id.equals(id)))
        .write(
      ContasCompanion(
        nome: Value(nome),
        saldoInicial: Value(saldoInicial),
        tipo: Value(tipo),
      ),
    );
  }

  Future excluir(int id) {
    return (db.delete(db.contas)
          ..where((t) => t.id.equals(id)))
        .go();
  }

  /// Retorna o efeito líquido de todas as movimentações já registradas
  /// sobre uma conta, sem considerar o saldo inicial.
  ///
  /// Esse valor é útil para transformar um saldo atual conhecido em um
  /// saldo inicial coerente com o histórico.
  Future<double> movimentacaoLiquida(int contaId) async {
    final lancamentos = await (db.select(db.lancamentos)
          ..where(
            (t) =>
                t.contaId.equals(contaId) &
                t.cartaoId.isNull(),
          ))
        .get();

    final pagamentos = await (db.select(
      db.pagamentosFaturas,
    )..where((t) => t.contaId.equals(contaId)))
        .get();

    final transferenciasEnviadas = await (db.select(
      db.transferencias,
    )..where((t) => t.contaOrigemId.equals(contaId)))
        .get();

    final transferenciasRecebidas = await (db.select(
      db.transferencias,
    )..where((t) => t.contaDestinoId.equals(contaId)))
        .get();

    double movimento = 0;

    for (final lancamento in lancamentos) {
      movimento += lancamento.receita
          ? lancamento.valor
          : -lancamento.valor;
    }

    for (final pagamento in pagamentos) {
      movimento -= pagamento.valor;
    }

    for (final transferencia in transferenciasEnviadas) {
      movimento -= transferencia.valor;
    }

    for (final transferencia in transferenciasRecebidas) {
      movimento += transferencia.valor;
    }

    return movimento;
  }

  /// Calcula o saldo atual a partir do saldo inicial e das movimentações.
  Future<double> saldoAtual(int contaId) async {
    final conta = await (db.select(db.contas)
          ..where((t) => t.id.equals(contaId)))
        .getSingle();

    return conta.saldoInicial + await movimentacaoLiquida(contaId);
  }

  /// Ajusta o saldo inicial para que o saldo atual calculado fique
  /// exatamente igual ao saldo real informado pelo usuário.
  ///
  /// Isso evita o erro de somar todo o histórico novamente ao saldo
  /// bancário atual durante uma importação.
  Future<void> ajustarSaldoAtual({
    required int contaId,
    required double saldoAtualDesejado,
  }) async {
    final movimento = await movimentacaoLiquida(contaId);
    final novoSaldoInicial = saldoAtualDesejado - movimento;

    await (db.update(db.contas)
          ..where((t) => t.id.equals(contaId)))
        .write(
      ContasCompanion(
        saldoInicial: Value(novoSaldoInicial),
      ),
    );
  }

  /// Calcula o patrimônio total considerando todas as contas.
  ///
  /// Cartões de crédito não entram diretamente no patrimônio,
  /// pois suas compras representam uma obrigação que será paga
  /// posteriormente pela conta.
  Future<double> patrimonioTotal() async {
    final contas = await buscarTodas();

    double total = 0;

    for (final conta in contas) {
      total += await saldoAtual(conta.id);
    }

    return total;
  }

  /// Retorna os saldos atuais de todas as contas.
  Future<Map<int, double>> saldosAtuais() async {
    final contas = await buscarTodas();

    final saldos = <int, double>{};

    for (final conta in contas) {
      saldos[conta.id] = await saldoAtual(conta.id);
    }

    return saldos;
  }
}