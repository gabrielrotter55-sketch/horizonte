import '../../../database/app_database.dart';
import '../../../database/database_service.dart';
import '../../../repositories/categoria_repository.dart';

class CategoriaViewModel {
  final CategoriaRepository repository;

  CategoriaViewModel()
      : repository = CategoriaRepository(
          DatabaseService.instance.database,
        );

  Future<void> salvar({
    required String nome,
    required String icone,
    required int cor,
    required bool receita,
  }) async {
    await repository.salvar(
      CategoriasCompanion.insert(
        nome: nome,
        icone: icone,
        cor: cor,
        receita: receita,
      ),
    );
  }

  Future<void> editar({
    required int id,
    required String nome,
    required String icone,
    required int cor,
    required bool receita,
  }) async {
    await repository.atualizar(
      id: id,
      nome: nome,
      icone: icone,
      cor: cor,
      receita: receita,
    );
  }
}