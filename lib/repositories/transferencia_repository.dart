import 'package:drift/drift.dart';

import '../database/app_database.dart';

class TransferenciaRepository {
  final AppDatabase db;

  TransferenciaRepository(this.db);

  Future<List<Transferencia>> buscarTodas() {
    return (db.select(db.transferencias)
          ..orderBy([
            (t) => OrderingTerm.desc(t.data),
          ]))
        .get();
  }

  Stream<List<Transferencia>> observar() {
    return (db.select(db.transferencias)
          ..orderBy([
            (t) => OrderingTerm.desc(t.data),
          ]))
        .watch();
  }

  Future<Transferencia?> buscarPorId(int id) async {
    final resultado = await (db.select(db.transferencias)
          ..where((t) => t.id.equals(id)))
        .get();

    if (resultado.isEmpty) {
      return null;
    }

    return resultado.first;
  }

  Future<int> salvar({
    required int contaOrigemId,
    required int contaDestinoId,
    required double valor,
    required DateTime data,
    required String descricao,
  }) {
    return db.into(db.transferencias).insert(
          TransferenciasCompanion.insert(
            contaOrigemId: contaOrigemId,
            contaDestinoId: contaDestinoId,
            valor: valor,
            data: data,
            descricao: descricao,
          ),
        );
  }

  Future<int> atualizar({
    required int id,
    required int contaOrigemId,
    required int contaDestinoId,
    required double valor,
    required DateTime data,
    required String descricao,
  }) {
    return (db.update(db.transferencias)
          ..where((t) => t.id.equals(id)))
        .write(
      TransferenciasCompanion(
        contaOrigemId: Value(contaOrigemId),
        contaDestinoId: Value(contaDestinoId),
        valor: Value(valor),
        data: Value(data),
        descricao: Value(descricao),
      ),
    );
  }

  Future<int> excluir(int id) {
    return (db.delete(db.transferencias)
          ..where((t) => t.id.equals(id)))
        .go();
  }
}