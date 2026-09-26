import '../../../database/app_database.dart';
import '../../../database/database_service.dart';
import '../../../repositories/cartao_repository.dart';

class CartaoViewModel {
  final CartaoRepository repository;

  CartaoViewModel()
      : repository = CartaoRepository(
          DatabaseService.instance.database,
        );

  Future<void> salvar({
    required String nome,
    required double limite,
    required int fechamento,
    required int vencimento,
  }) async {
    await repository.salvar(
      CartoesCompanion.insert(
        nome: nome,
        limite: limite,
        fechamento: fechamento,
        vencimento: vencimento,
      ),
    );
  }

  Future<void> editar({
    required int id,
    required String nome,
    required double limite,
    required int fechamento,
    required int vencimento,
  }) async {
    await repository.atualizar(
      id: id,
      nome: nome,
      limite: limite,
      fechamento: fechamento,
      vencimento: vencimento,
    );
  }
}