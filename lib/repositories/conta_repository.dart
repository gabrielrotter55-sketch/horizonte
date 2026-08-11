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

    return saldo;
  }
}