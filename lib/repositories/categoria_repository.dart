import 'package:drift/drift.dart';

import '../database/app_database.dart';

class CategoriaRepository {
  final AppDatabase db;

  CategoriaRepository(this.db);

  Future<List<Categoria>> buscarTodas() {
    return db.select(db.categorias).get();
  }

  Stream<List<Categoria>> observar() {
    return db.select(db.categorias).watch();
  }

  Future<int> salvar(CategoriasCompanion categoria) {
    return db.into(db.categorias).insert(categoria);
  }

  Future<int> atualizar({
    required int id,
    required String nome,
    required String icone,
    required int cor,
    required bool receita,
  }) {
    return (db.update(db.categorias)
          ..where((t) => t.id.equals(id)))
        .write(
      CategoriasCompanion(
        nome: Value(nome),
        icone: Value(icone),
        cor: Value(cor),
        receita: Value(receita),
      ),
    );
  }

  Future<int> excluir(int id) {
    return (db.delete(db.categorias)
          ..where((t) => t.id.equals(id)))
        .go();
  }
}