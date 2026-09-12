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

  /// Calcula o saldo atual de uma conta.
  ///
  /// Saldo atual =
  /// saldo inicial
  /// + receitas
  /// - despesas
  /// - pagamentos de fatura
  /// - transferências enviadas
  /// + transferências recebidas.
  ///
  /// Lançamentos realizados no cartão de crédito não
  /// movimentam diretamente o saldo da conta.
  Future<double> saldoAtual(int contaId) async {
    final conta = await (db.select(db.contas)
          ..where((t) => t.id.equals(contaId)))
        .getSingle();

    final lancamentos = await (db.select(db.lancamentos)
          ..where(
            (t) =>
                t.contaId.equals(contaId) &
                t.cartaoId.isNull(),
          ))
        .get();

    final pagamentos = await (db.select(
      db.pagamentosFaturas,
    )..where(
        (t) => t.contaId.equals(contaId),
      ))
        .get();

    final transferenciasEnviadas = await (db.select(
      db.transferencias,
    )..where(
        (t) => t.contaOrigemId.equals(contaId),
      ))
        .get();

    final transferenciasRecebidas = await (db.select(
      db.transferencias,
    )..where(
        (t) => t.contaDestinoId.equals(contaId),
      ))
        .get();

    double saldo = conta.saldoInicial;

    for (final lancamento in lancamentos) {
      if (lancamento.receita) {
        saldo += lancamento.valor;
      } else {
        saldo -= lancamento.valor;
      }
    }

    for (final pagamento in pagamentos) {
      saldo -= pagamento.valor;
    }

    for (final transferencia in transferenciasEnviadas) {
      saldo -= transferencia.valor;
    }

    for (final transferencia in transferenciasRecebidas) {
      saldo += transferencia.valor;
    }

    return saldo;
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