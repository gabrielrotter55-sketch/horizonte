import '../../../database/app_database.dart';
import '../../../database/database_service.dart';
import '../../../repositories/conta_repository.dart';

class ContaViewModel {
  final ContaRepository repository;

  ContaViewModel()
      : repository = ContaRepository(
          DatabaseService.instance.database,
        );

  Future<void> salvar({
    required String nome,
    required double saldo,
    required String tipo,
  }) async {
    await repository.salvar(
      ContasCompanion.insert(
        nome: nome,
        saldoInicial: saldo,
        tipo: tipo,
      ),
    );
  }

  Future<void> editar({
    required int id,
    required String nome,
    required double saldo,
    required String tipo,
  }) async {
    await repository.atualizar(
      id: id,
      nome: nome,
      saldoInicial: saldo,
      tipo: tipo,
    );
  }
}