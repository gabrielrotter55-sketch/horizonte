import '../database/app_database.dart';

class PagamentoFaturaRepository {
  final AppDatabase db;

  PagamentoFaturaRepository(this.db);

  Future<int> registrar({
    required int faturaId,
    required int contaId,
    required double valor,
  }) {
    return db.into(db.pagamentosFaturas).insert(
          PagamentosFaturasCompanion.insert(
            faturaId: faturaId,
            contaId: contaId,
            valor: valor,
            data: DateTime.now(),
          ),
        );
  }

  Future<PagamentosFatura?> buscarPorFatura(
    int faturaId,
  ) async {
    final resultado =
        await (db.select(db.pagamentosFaturas)
              ..where(
                (t) => t.faturaId.equals(faturaId),
              ))
            .get();

    if (resultado.isEmpty) {
      return null;
    }

    return resultado.first;
  }

  Future<List<PagamentosFatura>> buscarTodos() {
    return db.select(db.pagamentosFaturas).get();
  }

  Stream<List<PagamentosFatura>> observar() {
    return db.select(db.pagamentosFaturas).watch();
  }
}