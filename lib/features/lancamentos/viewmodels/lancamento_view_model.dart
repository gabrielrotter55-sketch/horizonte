import 'package:drift/drift.dart';

import '../../../database/app_database.dart';
import '../../../database/database_service.dart';
import '../../../repositories/cartao_repository.dart';
import '../../../repositories/categoria_repository.dart';
import '../../../repositories/conta_repository.dart';
import '../../../repositories/lancamento_repository.dart';

class LancamentoViewModel {
  final LancamentoRepository repository;
  final ContaRepository contaRepository;
  final CategoriaRepository categoriaRepository;
  final CartaoRepository cartaoRepository;

  LancamentoViewModel()
      : repository = LancamentoRepository(
          DatabaseService.instance.database,
        ),
        contaRepository = ContaRepository(
          DatabaseService.instance.database,
        ),
        categoriaRepository = CategoriaRepository(
          DatabaseService.instance.database,
        ),
        cartaoRepository = CartaoRepository(
          DatabaseService.instance.database,
        );

  Future<void> salvar({
    required String descricao,
    required double valor,
    required bool receita,
    required DateTime data,
    required int categoriaId,
    required int contaId,
    int? cartaoId,
  }) async {
    await repository.salvar(
      LancamentosCompanion.insert(
        descricao: descricao,
        valor: valor,
        receita: receita,
        data: data,
        categoriaId: categoriaId,
        contaId: Value(contaId),
        cartaoId: Value(cartaoId),
      ),
    );
  }

  Future<void> editar({
    required int id,
    required String descricao,
    required double valor,
    required bool receita,
    required DateTime data,
    required int categoriaId,
    required int contaId,
    int? cartaoId,
  }) async {
    await repository.atualizar(
      id: id,
      descricao: descricao,
      valor: valor,
      receita: receita,
      data: data,
      categoriaId: categoriaId,
      contaId: contaId,
      cartaoId: cartaoId,
    );
  }
}