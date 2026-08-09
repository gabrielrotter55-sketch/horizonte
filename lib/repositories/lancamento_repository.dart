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
}