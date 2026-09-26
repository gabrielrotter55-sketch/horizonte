import 'package:drift/drift.dart';

import '../database/app_database.dart';

class CartaoRepository {
  final AppDatabase db;

  CartaoRepository(this.db);

  Future<List<Cartoe>> buscarTodas() {
    return db.select(db.cartoes).get();
  }

  Stream<List<Cartoe>> observar() {
    return db.select(db.cartoes).watch();
  }

  Future<Cartoe?> buscarPorId(int id) async {
    final resultado = await (db.select(db.cartoes)
          ..where((t) => t.id.equals(id)))
        .get();
    return resultado.isEmpty ? null : resultado.first;
  }

  Future<int> salvar(CartoesCompanion cartao) {
    return db.into(db.cartoes).insert(cartao);
  }

  Future<int> atualizar({
    required int id,
    required String nome,
    required double limite,
    required int fechamento,
    required int vencimento,
  }) {
    return (db.update(db.cartoes)
          ..where((t) => t.id.equals(id)))
        .write(
      CartoesCompanion(
        nome: Value(nome),
        limite: Value(limite),
        fechamento: Value(fechamento),
        vencimento: Value(vencimento),
      ),
    );
  }

  Future<int> excluir(int id) {
    return (db.delete(db.cartoes)
          ..where((t) => t.id.equals(id)))
        .go();
  }

  Future<double> valorUtilizado(int cartaoId) async {
    final lancamentos = await (db.select(db.lancamentos)
          ..where(
            (t) =>
                t.cartaoId.equals(cartaoId) &
                t.receita.equals(false),
          ))
        .get();

    final faturas = await (db.select(db.faturas)
          ..where((t) => t.cartaoId.equals(cartaoId)))
        .get();

    final faturaIds = faturas.map((fatura) => fatura.id).toSet();
    final pagamentos = faturaIds.isEmpty
        ? <PagamentosFatura>[]
        : await (db.select(db.pagamentosFaturas)
              ..where((t) => t.faturaId.isIn(faturaIds)))
            .get();

    final totalCompras = lancamentos.fold<double>(
      0,
      (total, lancamento) => total + lancamento.valor,
    );
    final totalPago = pagamentos.fold<double>(
      0,
      (total, pagamento) => total + pagamento.valor,
    );

    return (totalCompras - totalPago).clamp(0, double.infinity).toDouble();
  }

  Future<double> limiteDisponivel(int cartaoId) async {
    final cartao = await (db.select(db.cartoes)
          ..where((t) => t.id.equals(cartaoId)))
        .getSingle();

    final utilizado = await valorUtilizado(cartaoId);

    return cartao.limite - utilizado;
  }
}