import '../../../database/database_service.dart';
import '../../../repositories/conta_repository.dart';
import '../../../repositories/transferencia_repository.dart';

class TransferenciaViewModel {
  final TransferenciaRepository repository;
  final ContaRepository contaRepository;

  TransferenciaViewModel()
      : repository = TransferenciaRepository(
          DatabaseService.instance.database,
        ),
        contaRepository = ContaRepository(
          DatabaseService.instance.database,
        );

  Future<void> salvar({
    required int contaOrigemId,
    required int contaDestinoId,
    required double valor,
    required DateTime data,
    required String descricao,
  }) async {
    if (contaOrigemId == contaDestinoId) {
      throw Exception(
        'A conta de origem e a conta de destino devem ser diferentes.',
      );
    }

    if (valor <= 0) {
      throw Exception(
        'O valor da transferência deve ser maior que zero.',
      );
    }

    await repository.salvar(
      contaOrigemId: contaOrigemId,
      contaDestinoId: contaDestinoId,
      valor: valor,
      data: data,
      descricao: descricao,
    );
  }

  Future<void> editar({
    required int id,
    required int contaOrigemId,
    required int contaDestinoId,
    required double valor,
    required DateTime data,
    required String descricao,
  }) async {
    if (contaOrigemId == contaDestinoId) {
      throw Exception(
        'A conta de origem e a conta de destino devem ser diferentes.',
      );
    }

    if (valor <= 0) {
      throw Exception(
        'O valor da transferência deve ser maior que zero.',
      );
    }

    await repository.atualizar(
      id: id,
      contaOrigemId: contaOrigemId,
      contaDestinoId: contaDestinoId,
      valor: valor,
      data: data,
      descricao: descricao,
    );
  }

  Future<void> excluir(int id) async {
    await repository.excluir(id);
  }
}