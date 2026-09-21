import 'package:drift/drift.dart';
import 'package:excel_plus/excel_plus.dart';

import '../database/app_database.dart';
import '../database/database_service.dart';
import '../models/meta_financeira.dart';
import '../models/meta_deposito.dart';
import '../repositories/investimento_repository.dart';
import '../repositories/meta_repository.dart';
import '../repositories/meta_deposito_repository.dart';

class ImportacaoPlanilhaPreview {
  final int receitas;
  final int despesas;
  final int categorias;
  final int formasPagamento;
  final int linhasNegativas;
  final int linhasComDataCompleta;
  final int linhasComDiaExplicito;
  final int linhasSemDataExplicita;
  final int duplicadosNaPlanilha;
  final int investimentos;
  final int metas;
  final List<String> formas;
  final List<String> avisos;

  const ImportacaoPlanilhaPreview({
    required this.receitas,
    required this.despesas,
    required this.categorias,
    required this.formasPagamento,
    required this.linhasNegativas,
    required this.linhasComDataCompleta,
    required this.linhasComDiaExplicito,
    required this.linhasSemDataExplicita,
    required this.duplicadosNaPlanilha,
    required this.investimentos,
    required this.metas,
    required this.formas,
    required this.avisos,
  });
}

class ImportacaoPlanilhaResultado {
  final int receitas;
  final int despesas;
  final int categoriasCriadas;
  final int contasCriadas;
  final int cartoesCriados;
  final int duplicadosIgnorados;
  final int investimentosImportados;
  final int metasImportadas;

  const ImportacaoPlanilhaResultado({
    required this.receitas,
    required this.despesas,
    required this.categoriasCriadas,
    required this.contasCriadas,
    required this.cartoesCriados,
    required this.duplicadosIgnorados,
    required this.investimentosImportados,
    required this.metasImportadas,
  });
}

class LimpezaImportacaoResultado {
  final int lancamentosRemovidos;
  final int contasControleRemovidas;
  final int investimentosRemovidos;
  final int metasRemovidas;

  const LimpezaImportacaoResultado({
    required this.lancamentosRemovidos,
    required this.contasControleRemovidas,
    required this.investimentosRemovidos,
    required this.metasRemovidas,
  });
}

class PlanilhaImportService {
  PlanilhaImportService({AppDatabase? db})
      : _db = db ?? DatabaseService.instance.database;

  final AppDatabase _db;
  final _metaRepository = MetaRepository();
  final _metaDepositoRepository = MetaDepositoRepository();
  final _investimentoRepository = InvestimentoRepository();

  static const _meses = <String, int>{
    'Janeiro': 1,
    'Fevereiro': 2,
    'Março': 3,
    'Abril': 4,
    'Maio': 5,
    'Junho': 6,
    'Julho': 7,
    'Agosto': 8,
    'Setembro': 9,
    'Outubro': 10,
    'Novembro': 11,
    'Dezembro': 12,
  };

  Future<ImportacaoPlanilhaPreview> analisar(dynamic bytes) async {
    final dados = _ler(bytes);

    return ImportacaoPlanilhaPreview(
      receitas: dados.receitas.length,
      despesas: dados.despesas.length,
      categorias: dados.categorias.length,
      formasPagamento: dados.formas.length,
      linhasNegativas: dados.negativas,
      linhasComDataCompleta: dados.comDataCompleta,
      linhasComDiaExplicito: dados.comDiaExplicito,
      linhasSemDataExplicita: dados.semDataExplicita,
      duplicadosNaPlanilha: dados.duplicadosNaPlanilha,
      investimentos: 0,
      metas: dados.metas,
      formas: dados.formas.toList()..sort(),
      avisos: _avisos(dados),
    );
  }

  Future<LimpezaImportacaoResultado> limparImportacaoAnterior() async {
    var lancamentosRemovidos = 0;
    var contasControleRemovidas = 0;

    final lancamentos = await _db.select(_db.lancamentos).get();
    final idsImportados = lancamentos
        .where(
          (item) =>
              item.origem == 'planilha' ||
              item.descricao.toLowerCase().startsWith('importado'),
        )
        .map((item) => item.id)
        .toSet();

    if (idsImportados.isNotEmpty) {
      await _db.transaction(() async {
        for (final id in idsImportados) {
          await (_db.delete(_db.lancamentos)
                ..where((table) => table.id.equals(id)))
              .go();
        }
      });
      lancamentosRemovidos = idsImportados.length;
    }

    final contas = await _db.select(_db.contas).get();
    for (final conta in contas) {
      if (!conta.nome.toLowerCase().startsWith('controle -')) {
        continue;
      }

      final usos = await (_db.select(_db.lancamentos)
            ..where((table) => table.contaId.equals(conta.id)))
          .get();

      final pagamentos = await (_db.select(_db.pagamentosFaturas)
            ..where((table) => table.contaId.equals(conta.id)))
          .get();

      final transferencias = await (_db.select(_db.transferencias)
            ..where(
              (table) =>
                  table.contaOrigemId.equals(conta.id) |
                  table.contaDestinoId.equals(conta.id),
            ))
          .get();

      if (usos.isEmpty && pagamentos.isEmpty && transferencias.isEmpty) {
        await (_db.delete(_db.contas)
              ..where((table) => table.id.equals(conta.id)))
            .go();
        contasControleRemovidas++;
      }
    }

    final investimentos = await _investimentoRepository.buscarTodas();
    final investimentosImportados = investimentos
        .where((item) => item.id.startsWith('planilha-'))
        .toList();
    for (final item in investimentosImportados) {
      await _investimentoRepository.excluir(item.id);
    }

    await _metaDepositoRepository.excluirPorOrigem('planilha');

    final metas = await _metaRepository.buscarTodas();
    final metasImportadas = metas
        .where((item) => item.id.startsWith('planilha-'))
        .toList();
    for (final meta in metasImportadas) {
      await _metaRepository.excluir(meta.id);
    }

    return LimpezaImportacaoResultado(
      lancamentosRemovidos: lancamentosRemovidos,
      contasControleRemovidas: contasControleRemovidas,
      investimentosRemovidos: investimentosImportados.length,
      metasRemovidas: metasImportadas.length,
    );
  }

  Future<ImportacaoPlanilhaResultado> importar(
    dynamic bytes, {
    required int? contaPadraoReceitasId,
    Map<String, double> saldosAtuaisDesejados = const {},
  }) async {
    final dados = _ler(bytes);

    final categoriasExistentes = await _db.select(_db.categorias).get();
    final contasExistentes = await _db.select(_db.contas).get();
    final cartoesExistentes = await _db.select(_db.cartoes).get();

    final categoriasPorNome = {
      for (final categoria in categoriasExistentes)
        categoria.nome.trim().toLowerCase(): categoria.id,
    };

    final contasPorNome = {
      for (final conta in contasExistentes)
        conta.nome.trim().toLowerCase(): conta.id,
    };

    final cartoesPorNome = {
      for (final cartao in cartoesExistentes)
        cartao.nome.trim().toLowerCase(): cartao.id,
    };

    var categoriasCriadas = 0;
    var contasCriadas = 0;
    var cartoesCriados = 0;
    var duplicadosIgnorados = 0;
    var receitasImportadas = 0;
    var despesasImportadas = 0;

    final existentes = await _db.select(_db.lancamentos).get();
    final chavesExistentes = <String>{
      for (final lancamento in existentes)
        _chaveLancamento(
          descricao: lancamento.descricao,
          valor: lancamento.valor,
          receita: lancamento.receita,
          data: lancamento.data,
          contaId: lancamento.contaId,
          cartaoId: lancamento.cartaoId,
        ),
    };

    var categoriaReceitaId = categoriasPorNome['receita importada'];

    await _db.transaction(() async {
      if (categoriaReceitaId == null) {
        categoriaReceitaId = await _db.into(_db.categorias).insert(
              CategoriasCompanion.insert(
                nome: 'Receita importada',
                icone: '💰',
                cor: 0xFF2196F3,
                receita: true,
              ),
            );
        categoriasPorNome['receita importada'] = categoriaReceitaId!;
        categoriasCriadas++;
      }

      for (final despesa in dados.despesas) {
        final categoriaNome = _nomeCategoria(despesa.categoria);
        final categoriaKey = categoriaNome.toLowerCase();

        var categoriaId = categoriasPorNome[categoriaKey];
        if (categoriaId == null) {
          categoriaId = await _db.into(_db.categorias).insert(
                CategoriasCompanion.insert(
                  nome: categoriaNome,
                  icone: _iconeCategoria(despesa.categoria),
                  cor: 0xFF2196B3,
                  receita: false,
                ),
              );
          categoriasPorNome[categoriaKey] = categoriaId;
          categoriasCriadas++;
        }

        final pagamento = despesa.formaPagamento.trim();
        int? contaId;
        int? cartaoId;

        if (pagamento.startsWith('Crédito ')) {
          final nomeCartao = pagamento.substring('Crédito '.length).trim();
          final cartaoKey = nomeCartao.toLowerCase();
          cartaoId = cartoesPorNome[cartaoKey];

          if (cartaoId == null) {
            cartaoId = await _db.into(_db.cartoes).insert(
                  CartoesCompanion.insert(
                    nome: nomeCartao,
                    limite: 0,
                    fechamento: 1,
                    vencimento: 1,
                  ),
                );
            cartoesPorNome[cartaoKey] = cartaoId;
            cartoesCriados++;
          }
        }

        // A planilha registra a forma de pagamento, mas não informa
        // de qual conta bancária saiu o dinheiro.
        // Pix / Dinheiro e VR Flash não serão transformados em contas.
        // Compras no cartão também não reduzem uma conta bancária
        // até que a fatura seja efetivamente paga.
        contaId = null;

        final descricao =
            'Importado - ${_nomeCategoria(despesa.categoria)}';
        final chave = _chaveLancamento(
          descricao: descricao,
          valor: despesa.valor,
          receita: false,
          data: despesa.data,
          contaId: contaId,
          cartaoId: cartaoId,
        );

        if (chavesExistentes.contains(chave)) {
          duplicadosIgnorados++;
          continue;
        }

        await _db.into(_db.lancamentos).insert(
              LancamentosCompanion.insert(
                descricao: descricao,
                valor: despesa.valor,
                receita: false,
                data: despesa.data,
                categoriaId: categoriaId,
                contaId: Value(contaId),
                cartaoId: Value(cartaoId),
                origem: const Value('planilha'),
              ),
            );
        chavesExistentes.add(chave);
        despesasImportadas++;
      }

      for (final receita in dados.receitas) {
        final chave = _chaveLancamento(
          descricao: receita.descricao,
          valor: receita.valor,
          receita: true,
          data: receita.data,
          contaId: contaPadraoReceitasId,
          cartaoId: null,
        );

        if (chavesExistentes.contains(chave)) {
          duplicadosIgnorados++;
          continue;
        }

        await _db.into(_db.lancamentos).insert(
              LancamentosCompanion.insert(
                descricao: receita.descricao,
                valor: receita.valor,
                receita: true,
                data: receita.data,
                categoriaId: categoriaReceitaId!,
                contaId: Value(contaPadraoReceitasId),
                cartaoId: const Value(null),
                origem: const Value('planilha'),
              ),
            );
        chavesExistentes.add(chave);
        receitasImportadas++;
      }
    });

    // O histórico não deve ser confundido com o saldo bancário de hoje.
    // Quando o usuário informa o saldo real, ajustamos apenas o saldo inicial
    // necessário para que histórico + saldo inicial resultem naquele valor.
    // Contas sem saldo informado não são alteradas.
    for (final entry in saldosAtuaisDesejados.entries) {
      final nome = entry.key.trim().toLowerCase();
      final contaId = contasPorNome[nome];
      if (contaId == null) continue;

      final movimento = await (
        _db.select(_db.lancamentos)
          ..where(
            (table) =>
                table.contaId.equals(contaId) &
                table.cartaoId.isNull(),
          )
      ).get();

      final pagamentos = await (_db.select(_db.pagamentosFaturas)
            ..where((table) => table.contaId.equals(contaId)))
          .get();
      final transferenciasEnviadas = await (_db.select(_db.transferencias)
            ..where((table) => table.contaOrigemId.equals(contaId)))
          .get();
      final transferenciasRecebidas = await (_db.select(_db.transferencias)
            ..where((table) => table.contaDestinoId.equals(contaId)))
          .get();

      var liquido = 0.0;
      for (final item in movimento) {
        liquido += item.receita ? item.valor : -item.valor;
      }
      for (final item in pagamentos) {
        liquido -= item.valor;
      }
      for (final item in transferenciasEnviadas) {
        liquido -= item.valor;
      }
      for (final item in transferenciasRecebidas) {
        liquido += item.valor;
      }

      final saldoInicialNecessario = entry.value - liquido;
      await (_db.update(_db.contas)
            ..where((table) => table.id.equals(contaId)))
          .write(
        ContasCompanion(
          saldoInicial: Value(saldoInicialNecessario),
        ),
      );
    }

    await _importarMetasDaPlanilha(dados);
    await _investimentoRepository.garantirCarteiraAtual();

    return ImportacaoPlanilhaResultado(
      receitas: receitasImportadas,
      despesas: despesasImportadas,
      categoriasCriadas: categoriasCriadas,
      contasCriadas: contasCriadas,
      cartoesCriados: cartoesCriados,
      duplicadosIgnorados: duplicadosIgnorados,
      investimentosImportados: 0,
      metasImportadas: dados.metas,
    );
  }

  Future<void> _importarMetasDaPlanilha(_DadosImportacao dados) async {
    // A planilha continua sendo a fonte das metas configuradas e da reserva
    // de emergência. A carteira de investimentos é mantida separadamente
    // pelos dados do Investidor10 para evitar duplicidade.
    final apartamento = MetaFinanceira(
      id: 'planilha-meta-apartamento',
      nome: dados.nomeMeta.isEmpty ? 'Apartamento' : dados.nomeMeta,
      objetivo: dados.objetivoMeta,
      acumulado: dados.valorMetaApartamento,
      prazo: null,
      cor: 0xFF6C4AB6,
      criadoEm: DateTime.now(),
    );

    final emergencia = MetaFinanceira(
      id: 'planilha-meta-emergencia',
      nome: 'Reserva de emergência',
      objetivo: dados.objetivoEmergencia,
      acumulado: dados.valorReservaEmergencia,
      prazo: null,
      cor: 0xFF2E8B57,
      criadoEm: DateTime.now(),
    );

    await _metaRepository.salvar(apartamento);
    await _metaRepository.salvar(emergencia);

    for (final deposito in dados.depositosMetaApartamento) {
      await _metaDepositoRepository.salvar(deposito);
    }

    if (dados.depositosMetaApartamento.isNotEmpty) {
      final total = dados.depositosMetaApartamento.fold<double>(
        0,
        (soma, deposito) => soma + deposito.valor,
      );
      await _metaRepository.salvar(apartamento.copyWith(acumulado: total));
    }
  }

  _DadosImportacao _ler(dynamic bytes) {
    final excel = Excel.decodeBytes(bytes);
    final folhas = _folhasHistoricas(excel);

    final receitasPorChave = <String, _ReceitaImportacao>{};
    final despesasPorChave = <String, _DespesaImportacao>{};
    final reservasPorChave = <String, _ReservaImportacao>{};
    final formas = <String>{};
    final categorias = <String>{};

    var negativas = 0;
    var duplicadosNaPlanilha = 0;
    var comDataCompleta = 0;
    var comDiaExplicito = 0;
    var semDataExplicita = 0;

    for (final folha in folhas) {
      final partes = _parseFolha(excel, folha);
      final mesAno = _mesAno(folha)!;

      for (final entrada in partes.receitas) {
        final dataReceita = _dataDaReceita(entrada.descricao, mesAno);
        final chaveReceita = [
          entrada.descricao.trim().toLowerCase(),
          entrada.valor.toStringAsFixed(2),
          _chaveData(dataReceita),
        ].join('|');

        if (receitasPorChave.containsKey(chaveReceita)) {
          duplicadosNaPlanilha++;
          continue;
        }

        final tipoData = _tipoDataReceita(entrada.descricao);
        if (tipoData == _TipoDataReceita.completa) {
          comDataCompleta++;
        } else if (tipoData == _TipoDataReceita.dia) {
          comDiaExplicito++;
        } else {
          semDataExplicita++;
        }

        receitasPorChave[chaveReceita] = _ReceitaImportacao(
          descricao: entrada.descricao,
          valor: entrada.valor,
          data: dataReceita,
        );
      }

      for (final despesa in partes.despesas) {
        formas.add(despesa.formaPagamento);
        categorias.add(_nomeCategoria(despesa.categoria));

        final chave = [
          _nomeCategoria(despesa.categoria).trim().toLowerCase(),
          _chaveData(despesa.data),
          despesa.formaPagamento.trim().toLowerCase(),
          despesa.valor.toStringAsFixed(2),
          despesa.essencial.trim().toLowerCase(),
        ].join('|');

        if (despesasPorChave.containsKey(chave)) {
          duplicadosNaPlanilha++;
          continue;
        }

        if (despesa.valor < 0) {
          negativas++;
        }

        despesasPorChave[chave] = despesa;
      }

      for (final reserva in partes.reservas) {
        final chave = [
          reserva.nome.trim().toLowerCase(),
          reserva.tipo.trim().toLowerCase(),
          reserva.valor.toStringAsFixed(2),
          _chaveData(reserva.data),
        ].join('|');
        if (reservasPorChave.containsKey(chave)) {
          duplicadosNaPlanilha++;
          continue;
        }
        reservasPorChave[chave] = reserva;
      }
    }

    final investimentosPorTipo = <String, _InvestimentoImportacao>{};
    final depositosMetaApartamento = <MetaDeposito>[];
    var valorReservaEmergencia = 0.0;
    var valorMetaApartamento = 0.0;

    for (final reserva in reservasPorChave.values) {
      final tipo = reserva.tipo.trim();
      final valor = reserva.valor;
      final tipoNormalizado = tipo.toLowerCase();

      if (tipoNormalizado == 'reserva de emergência') {
        valorReservaEmergencia += valor;
        continue;
      }

      if (tipoNormalizado == 'meta') {
        final nomeNormalizado = reserva.nome.trim().toLowerCase();
        if (nomeNormalizado.contains('eu e mo')) {
          valorMetaApartamento += valor;
          final pessoa = nomeNormalizado.contains(' - mo') ||
                  nomeNormalizado.endsWith('- mo')
              ? 'Natália'
              : 'Gabriel';
          depositosMetaApartamento.add(
            MetaDeposito(
              id: 'planilha-deposito-${depositosMetaApartamento.length}-${reserva.data.microsecondsSinceEpoch}',
              metaId: 'planilha-meta-apartamento',
              pessoa: pessoa,
              valor: valor,
              data: reserva.data,
              descricao: 'Importado da planilha',
              origem: 'planilha',
            ),
          );
          continue;
        }

        // O FGTS permanece fora da carteira de investimentos do Investidor10.
        if (nomeNormalizado.contains('fgts')) {
          final atual = investimentosPorTipo['FGTS'];
          investimentosPorTipo['FGTS'] = _InvestimentoImportacao(
            nome: 'FGTS',
            tipo: 'FGTS',
            valor: (atual?.valor ?? 0) + valor,
            data: reserva.data,
          );
        }
        continue;
      }

      final chave = tipo.isEmpty ? 'Outros' : tipo;
      final atual = investimentosPorTipo[chave];
      investimentosPorTipo[chave] = _InvestimentoImportacao(
        nome: chave,
        tipo: chave,
        valor: (atual?.valor ?? 0) + valor,
        data: reserva.data,
      );
    }

    final importantes = _lerConfiguracaoMeta(excel);

    return _DadosImportacao(
      receitas: receitasPorChave.values.toList(),
      despesas: despesasPorChave.values.toList(),
      formas: formas,
      categorias: categorias,
      negativas: negativas,
      comDataCompleta: comDataCompleta,
      comDiaExplicito: comDiaExplicito,
      semDataExplicita: semDataExplicita,
      duplicadosNaPlanilha: duplicadosNaPlanilha,
      investimentos: investimentosPorTipo.values
          .where((item) => item.valor > 0)
          .toList(),
      metas: 2,
      nomeMeta: importantes.nome,
      objetivoMeta: importantes.objetivo,
      objetivoEmergencia: importantes.emergencia,
      valorReservaEmergencia: valorReservaEmergencia,
      valorMetaApartamento: valorMetaApartamento,
      depositosMetaApartamento: depositosMetaApartamento,
    );
  }

  _ConfiguracaoMeta _lerConfiguracaoMeta(Excel excel) {
    final sheet = excel['IMPORTANTE IMPORTANTE'];
    if (sheet.rows.length < 9) {
      return const _ConfiguracaoMeta(
        nome: 'Apartamento',
        objetivo: 0,
        emergencia: 0,
      );
    }

    final nome = _texto(_cell(sheet.rows[8], 8));
    final objetivo = _numero(_cell(sheet.rows[8], 10)) ?? 0;
    final emergencia = _numero(_cell(sheet.rows[8], 14)) ?? 0;

    return _ConfiguracaoMeta(
      nome: nome.isEmpty ? 'Apartamento' : nome,
      objetivo: objetivo,
      emergencia: emergencia,
    );
  }

  List<String> _folhasHistoricas(Excel excel) {
    final mesesComReceita = <String>[];
    final todas = <String>[];

    for (final nome in excel.tables.keys) {
      if (_mesAno(nome) == null) continue;
      todas.add(nome);
      final dados = excel[nome];
      final temReceita = dados.rows.skip(28).any((row) {
        final nomeCell = _cell(row, 1);
        final valorCell = _cell(row, 4);
        return _texto(nomeCell).isNotEmpty && _numero(valorCell) != null;
      });
      if (temReceita) mesesComReceita.add(nome);
    }

    if (mesesComReceita.isEmpty) {
      throw const FormatException(
        'Não encontrei abas mensais com lançamentos na planilha.',
      );
    }

    mesesComReceita.sort((a, b) => _mesAno(a)!.compareTo(_mesAno(b)!));
    final ultimoHistorico = _mesAno(mesesComReceita.last)!;
    todas.sort((a, b) => _mesAno(a)!.compareTo(_mesAno(b)!));

    return todas
        .where((nome) => _mesAno(nome)!.compareTo(ultimoHistorico) <= 0)
        .toList();
  }

  _FolhaImportacao _parseFolha(Excel excel, String nome) {
    final sheet = excel[nome];
    final receitas = <_ReceitaBruta>[];
    final despesas = <_DespesaImportacao>[];
    final reservas = <_ReservaImportacao>[];

    for (final row in sheet.rows.skip(28)) {
      final nomeReceita = _texto(_cell(row, 1));
      final valorReceita = _numero(_cell(row, 4));
      if (nomeReceita.isNotEmpty && valorReceita != null) {
        receitas.add(_ReceitaBruta(descricao: nomeReceita, valor: valorReceita));
      }

      final categoria = _texto(_cell(row, 7));
      final forma = _texto(_cell(row, 8));
      final valor = _numero(_cell(row, 10));
      final data = _data(_cell(row, 12));
      final essencial = _texto(_cell(row, 13));
      if (categoria.isNotEmpty && forma.isNotEmpty && valor != null && data != null) {
        despesas.add(
          _DespesaImportacao(
            categoria: categoria,
            formaPagamento: forma,
            valor: valor,
            data: data,
            essencial: essencial,
          ),
        );
      }

      final nomeReserva = _texto(_cell(row, 22));
      final tipoReserva = _texto(_cell(row, 23));
      final valorReserva = _numero(_cell(row, 25));
      final dataReserva = _data(_cell(row, 27));
      if (nomeReserva.isNotEmpty &&
          tipoReserva.isNotEmpty &&
          valorReserva != null &&
          dataReserva != null) {
        reservas.add(
          _ReservaImportacao(
            nome: nomeReserva,
            tipo: tipoReserva,
            valor: valorReserva,
            data: dataReserva,
          ),
        );
      }
    }

    return _FolhaImportacao(
      receitas: receitas,
      despesas: despesas,
      reservas: reservas,
    );
  }

  _MesAno? _mesAno(String nome) {
    final match = RegExp(r'^(.+?)(20\d{2})$').firstMatch(nome);
    if (match == null) return null;
    final mes = _meses[match.group(1)!];
    final ano = int.tryParse(match.group(2)!);
    if (mes == null || ano == null) return null;
    return _MesAno(ano: ano, mes: mes);
  }

  DateTime _dataDaReceita(String descricao, _MesAno mesAno) {
    final dataCompleta = RegExp(r'(\d{1,2})[/-](\d{1,2})').firstMatch(descricao);
    if (dataCompleta != null) {
      final dia = int.parse(dataCompleta.group(1)!);
      final mes = int.parse(dataCompleta.group(2)!);
      if (_dataValida(mesAno.ano, mes, dia)) {
        return DateTime(mesAno.ano, mes, dia);
      }
    }

    final diaExplicito = RegExp(r'\bdia\s+(\d{1,2})\b', caseSensitive: false)
        .firstMatch(descricao);
    if (diaExplicito != null) {
      final dia = int.parse(diaExplicito.group(1)!);
      if (_dataValida(mesAno.ano, mesAno.mes, dia)) {
        return DateTime(mesAno.ano, mesAno.mes, dia);
      }
    }

    return DateTime(mesAno.ano, mesAno.mes, 1);
  }

  bool _dataValida(int ano, int mes, int dia) {
    if (mes < 1 || mes > 12 || dia < 1 || dia > 31) return false;
    final data = DateTime(ano, mes, dia);
    return data.year == ano && data.month == mes && data.day == dia;
  }

  DateTime? _data(Data? cell) {
    final value = cell?.value;
    if (value is DateCellValue) return value.asDateTimeLocal();
    if (value is DateTimeCellValue) return value.asDateTimeLocal();

    final texto = cell?.displayText.trim() ?? '';
    final iso = DateTime.tryParse(texto);
    if (iso != null) return DateTime(iso.year, iso.month, iso.day);

    final match = RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})$').firstMatch(texto);
    if (match != null) {
      return DateTime(
        int.parse(match.group(3)!),
        int.parse(match.group(2)!),
        int.parse(match.group(1)!),
      );
    }
    return null;
  }

  double? _numero(Data? cell) {
    final value = cell?.value;
    if (value is DoubleCellValue) return value.value;
    if (value is IntCellValue) return value.value.toDouble();

    final texto = cell?.displayText.trim() ?? '';
    if (texto.isEmpty) return null;

    final normalizado = texto
        .replaceAll('R\$', '')
        .replaceAll('.', '')
        .replaceAll(',', '.')
        .trim();
    return double.tryParse(normalizado);
  }

  String _texto(Data? cell) => cell?.displayText.trim() ?? '';

  Data? _cell(List<Data?> row, int index) {
    if (index < 0 || index >= row.length) return null;
    return row[index];
  }

  _TipoDataReceita _tipoDataReceita(String descricao) {
    if (RegExp(r'(\d{1,2})[/-](\d{1,2})').hasMatch(descricao)) {
      return _TipoDataReceita.completa;
    }
    if (RegExp(r'\bdia\s+\d{1,2}\b', caseSensitive: false).hasMatch(descricao)) {
      return _TipoDataReceita.dia;
    }
    return _TipoDataReceita.ausente;
  }

  String _chaveData(DateTime data) =>
      '${data.year}-${data.month.toString().padLeft(2, '0')}-${data.day.toString().padLeft(2, '0')}';

  String _nomeCategoria(String categoria) {
    const icones = [
      '🏠', '📦', '🚘', '🚗', '🍗', '🧾', '👔', '🔋', '⛽', '🚴',
      '💪', '📚', '💊', '🎮', '🛒',
    ];
    for (final icone in icones) {
      if (categoria.startsWith(icone)) {
        return categoria.substring(icone.length).trim();
      }
    }
    return categoria.trim();
  }

  String _iconeCategoria(String categoria) {
    const icones = [
      '🏠', '📦', '🚘', '🚗', '🍗', '🧾', '👔', '🔋', '⛽', '🚴',
      '💪', '📚', '💊', '🎮', '🛒',
    ];
    for (final icone in icones) {
      if (categoria.startsWith(icone)) return icone;
    }
    return '💰';
  }

  String _chaveLancamento({
    required String descricao,
    required double valor,
    required bool receita,
    required DateTime data,
    required int? contaId,
    required int? cartaoId,
  }) {
    return [
      descricao.trim().toLowerCase(),
      valor.toStringAsFixed(2),
      receita ? '1' : '0',
      _chaveData(data),
      contaId.toString(),
      cartaoId?.toString() ?? '',
    ].join('|');
  }

  List<String> _avisos(_DadosImportacao dados) {
    final avisos = <String>[];
    if (dados.comDataCompleta > 0) {
      avisos.add(
        '${dados.comDataCompleta} receita(s) possuem dia e mês na descrição. Essas datas serão preservadas.',
      );
    }
    if (dados.comDiaExplicito > 0) {
      avisos.add(
        '${dados.comDiaExplicito} receita(s) informam apenas o dia. O mês será obtido pela aba.',
      );
    }
    if (dados.semDataExplicita > 0) {
      avisos.add(
        '${dados.semDataExplicita} receita(s) não possuem data identificável. Será usado o dia 1 do mês da aba.',
      );
    }
    if (dados.duplicadosNaPlanilha > 0) {
      avisos.add(
        '${dados.duplicadosNaPlanilha} linha(s) repetida(s) entre abas foram removidas da prévia.',
      );
    }
    if (dados.negativas > 0) {
      avisos.add(
        '${dados.negativas} despesa(s) possuem valor negativo. Elas serão tratadas como ajuste/estorno.',
      );
    }
    avisos.add(
      'A coluna "Contas" não será usada para formar saldo bancário. Ela contém contas/obrigações da sua planilha, não o saldo atual das contas.',
    );
    avisos.add(
      'O histórico da planilha não define o saldo atual da sua conta. Informe o saldo real de hoje para que o Horizonte calcule automaticamente o saldo inicial compatível com o histórico.',
    );
    avisos.add(
      'Compras no cartão não retiram dinheiro da conta no momento da importação; elas entram no cartão e serão consideradas quando a fatura for paga.',
    );
    avisos.add(
      'Investimentos da planilha não serão importados. A carteira do Horizonte usa os dados do Investidor10, evitando duplicidade com reservas e metas da planilha.',
    );
    return avisos;
  }
}

class _DadosImportacao {
  final List<_ReceitaImportacao> receitas;
  final List<_DespesaImportacao> despesas;
  final Set<String> formas;
  final Set<String> categorias;
  final int negativas;
  final int comDataCompleta;
  final int comDiaExplicito;
  final int semDataExplicita;
  final int duplicadosNaPlanilha;
  final List<_InvestimentoImportacao> investimentos;
  final int metas;
  final String nomeMeta;
  final double objetivoMeta;
  final double objetivoEmergencia;
  final double valorReservaEmergencia;
  final double valorMetaApartamento;
  final List<MetaDeposito> depositosMetaApartamento;

  const _DadosImportacao({
    required this.receitas,
    required this.despesas,
    required this.formas,
    required this.categorias,
    required this.negativas,
    required this.comDataCompleta,
    required this.comDiaExplicito,
    required this.semDataExplicita,
    required this.duplicadosNaPlanilha,
    required this.investimentos,
    required this.metas,
    required this.nomeMeta,
    required this.objetivoMeta,
    required this.objetivoEmergencia,
    required this.valorReservaEmergencia,
    required this.valorMetaApartamento,
    required this.depositosMetaApartamento,
  });
}

class _FolhaImportacao {
  final List<_ReceitaBruta> receitas;
  final List<_DespesaImportacao> despesas;
  final List<_ReservaImportacao> reservas;

  const _FolhaImportacao({
    required this.receitas,
    required this.despesas,
    required this.reservas,
  });
}

class _ReceitaBruta {
  final String descricao;
  final double valor;
  const _ReceitaBruta({required this.descricao, required this.valor});
}

class _ReceitaImportacao {
  final String descricao;
  final double valor;
  final DateTime data;
  const _ReceitaImportacao({required this.descricao, required this.valor, required this.data});
}

class _DespesaImportacao {
  final String categoria;
  final String formaPagamento;
  final double valor;
  final DateTime data;
  final String essencial;
  const _DespesaImportacao({
    required this.categoria,
    required this.formaPagamento,
    required this.valor,
    required this.data,
    required this.essencial,
  });
}

class _ReservaImportacao {
  final String nome;
  final String tipo;
  final double valor;
  final DateTime data;
  const _ReservaImportacao({required this.nome, required this.tipo, required this.valor, required this.data});
}

class _InvestimentoImportacao {
  final String nome;
  final String tipo;
  final double valor;
  final DateTime data;
  const _InvestimentoImportacao({required this.nome, required this.tipo, required this.valor, required this.data});
}

class _ConfiguracaoMeta {
  final String nome;
  final double objetivo;
  final double emergencia;
  const _ConfiguracaoMeta({required this.nome, required this.objetivo, required this.emergencia});
}

enum _TipoDataReceita { completa, dia, ausente }

class _MesAno implements Comparable<_MesAno> {
  final int ano;
  final int mes;
  const _MesAno({required this.ano, required this.mes});

  @override
  int compareTo(_MesAno other) {
    return (ano * 100 + mes).compareTo(other.ano * 100 + other.mes);
  }
}
