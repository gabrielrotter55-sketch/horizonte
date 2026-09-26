import 'package:drift/drift.dart';

import '../../../database/app_database.dart';
import '../../../database/database_service.dart';
import '../../../repositories/cartao_repository.dart';
import '../../../repositories/categoria_repository.dart';
import '../../../repositories/conta_repository.dart';
import '../../../repositories/lancamento_repository.dart';
import '../../../repositories/fatura_repository.dart';

class LancamentoViewModel {
  final LancamentoRepository repository;
  final ContaRepository contaRepository;
  final CategoriaRepository categoriaRepository;
  final CartaoRepository cartaoRepository;
  final FaturaRepository faturaRepository;

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
        ),
        faturaRepository = FaturaRepository(
          DatabaseService.instance.database,
        );

  Future<void> salvar({
    required String descricao,
    required double valor,
    required bool receita,
    required DateTime data,
    required int categoriaId,
    required int? contaId,
    int? cartaoId,
    String origem = 'manual',
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
        origem: Value(origem),
      ),
    );

    if (!receita && cartaoId != null) {
      await _garantirFaturaDaCompra(cartaoId, data);
    }
  }

  Future<void> editar({
    required int id,
    required String descricao,
    required double valor,
    required bool receita,
    required DateTime data,
    required int categoriaId,
    required int? contaId,
    int? cartaoId,
    String origem = 'manual',
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
      origem: origem,
    );

    if (!receita && cartaoId != null) {
      await _garantirFaturaDaCompra(cartaoId, data);
    }
  }

  Future<void> _garantirFaturaDaCompra(int cartaoId, DateTime data) async {
    final cartao = await cartaoRepository.buscarPorId(cartaoId);
    if (cartao == null) return;

    final mes = data.day <= cartao.fechamento
        ? data.month
        : (data.month == 12 ? 1 : data.month + 1);
    final ano = data.day <= cartao.fechamento
        ? data.year
        : (data.month == 12 ? data.year + 1 : data.year);

    final existente = await faturaRepository.buscarPorCartaoEReferencia(
      cartaoId: cartaoId,
      mes: mes,
      ano: ano,
    );

    if (existente == null) {
      await faturaRepository.criar(
        cartaoId: cartaoId,
        mes: mes,
        ano: ano,
      );
    }
  }
}