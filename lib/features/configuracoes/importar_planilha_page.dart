import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../database/app_database.dart';
import '../../../database/database_service.dart';
import '../../../repositories/conta_repository.dart';
import '../../../services/planilha_import_service.dart';

class ImportarPlanilhaPage extends StatefulWidget {
  const ImportarPlanilhaPage({super.key});

  @override
  State<ImportarPlanilhaPage> createState() => _ImportarPlanilhaPageState();
}

class _ImportarPlanilhaPageState extends State<ImportarPlanilhaPage> {
  final _service = PlanilhaImportService();
  final _contaRepository = ContaRepository(
    DatabaseService.instance.database,
  );

  List<Conta> _contas = [];
  Uint8List? _bytes;
  String? _nomeArquivo;
  ImportacaoPlanilhaPreview? _preview;
  int? _contaReceitasId;

  bool _carregando = false;
  bool _importando = false;

  final Map<String, TextEditingController> _saldoAtualControllers = {};

  @override
  void initState() {
    super.initState();
    _carregarContas();
  }

  Future<void> _carregarContas() async {
    final db = DatabaseService.instance.database;

    var contas = await _contaRepository.buscarTodas();

    int? mercadoPagoId;
    int? nubankId;

    for (final conta in contas) {
      final nome = conta.nome.trim().toLowerCase();

      if (nome == 'mercado pago') {
        mercadoPagoId = conta.id;
      }

      if (nome == 'nubank') {
        nubankId = conta.id;
      }
    }

    mercadoPagoId ??= await db.into(db.contas).insert(
      ContasCompanion.insert(
        nome: 'Mercado Pago',
        saldoInicial: 0,
        tipo: 'Conta digital',
      ),
    );

    nubankId ??= await db.into(db.contas).insert(
      ContasCompanion.insert(
        nome: 'Nubank',
        saldoInicial: 0,
        tipo: 'Conta digital',
      ),
    );

    contas = await _contaRepository.buscarTodas();

    if (!mounted) return;

    setState(() {
      _contas = contas;

      _contaReceitasId =
          contas.any((conta) => conta.id == mercadoPagoId)
              ? mercadoPagoId
              : nubankId;
    });
  }

  Future<void> _selecionarPlanilha() async {
    setState(() => _carregando = true);

    try {
      final arquivo = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );

      if (arquivo == null) return;

      final bytes = await arquivo.readAsBytes();
      final preview = await _service.analisar(bytes);

      if (!mounted) return;

      setState(() {
        _bytes = bytes;
        _nomeArquivo = arquivo.name;
        _preview = preview;
      });

      await _prepararCamposSaldo(preview);
    } catch (e) {
      if (mounted) {
        _mostrarErro(_mensagemErro(e));
      }
    } finally {
      if (mounted) {
        setState(() => _carregando = false);
      }
    }
  }

  Future<void> _limparImportacaoAnterior() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Limpar importação anterior?'),
        content: const Text(
          'O Horizonte vai remover lançamentos identificados como '
          'importados da planilha e dados de importação de metas/investimentos.\n\n'
          'Lançamentos e patrimônios cadastrados manualmente não serão removidos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Limpar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    setState(() => _importando = true);

    try {
      final resultado = await _service.limparImportacaoAnterior();

      await _carregarContas();

      if (!mounted) return;

      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Importação anterior limpa'),
          content: Text(
            '${resultado.lancamentosRemovidos} lançamentos removidos.\n'
            '${resultado.contasControleRemovidas} contas de controle removidas.\n'
            '${resultado.investimentosRemovidos} investimentos importados removidos.\n'
            '${resultado.metasRemovidas} metas importadas removidas.\n\n'
            'Seus dados cadastrados manualmente foram preservados.',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Concluir'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        _mostrarErro(_mensagemErro(e));
      }
    } finally {
      if (mounted) {
        setState(() => _importando = false);
      }
    }
  }

  Future<void> _importar() async {
    final bytes = _bytes;
    final contaId = _contaReceitasId;
    final preview = _preview;

    if (bytes == null || preview == null) {
      _mostrarErro('Selecione a planilha antes de importar.');
      return;
    }

    if (!_saldosObrigatoriosPreenchidos(preview)) {
      _mostrarErro(
        'Informe o saldo real de hoje para todas as contas usadas na importação.',
      );
      return;
    }

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar importação'),
        content: Text(
          'Serão importadas ${preview.receitas} receitas, '
          '${preview.despesas} despesas, '
          '${preview.investimentos} investimentos e '
          '${preview.metas} metas.\n\n'
          'Contas e obrigações da coluna "Contas" não serão transformadas '
          'em saldo bancário.\n\n'
          'Os saldos informados na seção abaixo representam o saldo real '
          'de hoje. O Horizonte vai ajustar o saldo inicial automaticamente '
          'para que o histórico importado não infle nem reduza '
          'artificialmente o seu patrimônio.\n\n'
          'Deseja continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Importar'),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    setState(() => _importando = true);

    try {
      final resultado = await _service.importar(
        bytes,
        contaPadraoReceitasId: contaId,
        saldosAtuaisDesejados: _saldosInformados(),
      );

      if (!mounted) return;

      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Importação concluída'),
          content: Text(
            '${resultado.receitas} receitas importadas.\n'
            '${resultado.despesas} despesas importadas.\n'
            '${resultado.categoriasCriadas} categorias criadas.\n'
            '${resultado.contasCriadas} contas criadas.\n'
            '${resultado.cartoesCriados} cartões criados.\n'
            '${resultado.investimentosImportados} investimentos importados.\n'
            '${resultado.metasImportadas} metas importadas.\n'
            '${resultado.duplicadosIgnorados} lançamentos duplicados ignorados.',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Concluir'),
            ),
          ],
        ),
      );

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        _mostrarErro(_mensagemErro(e));
      }
    } finally {
      if (mounted) {
        setState(() => _importando = false);
      }
    }
  }

  String _mensagemErro(Object erro) {
    if (erro is FormatException) {
      return erro.message;
    }

    return 'Não foi possível processar a planilha.\n$erro';
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
      ),
    );
  }

  @override
  void dispose() {
    for (final controller in _saldoAtualControllers.values) {
      controller.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final preview = _preview;
    final podeImportar = preview != null && !_importando;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Importar planilha'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
        children: [
          const Text(
            'Trazer dados para o Horizonte',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'A planilha será usada como histórico. A importação separa '
            'contas, cartões, metas e investimentos para evitar distorções '
            'no patrimônio.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),

          const SizedBox(height: 24),

          Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.table_chart_outlined),
              ),
              title: Text(
                _nomeArquivo ?? 'Nenhuma planilha selecionada',
              ),
              subtitle: Text(
                _nomeArquivo == null
                    ? 'Selecione um arquivo .xlsx ou .xls.'
                    : 'Arquivo pronto para análise.',
              ),
              trailing: _carregando
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : IconButton(
                      tooltip: 'Selecionar planilha',
                      onPressed: _selecionarPlanilha,
                      icon: const Icon(
                        Icons.folder_open_outlined,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              onPressed: _carregando ? null : _selecionarPlanilha,
              icon: const Icon(Icons.upload_file_outlined),
              label: const Text('Selecionar planilha'),
            ),
          ),

          const SizedBox(height: 10),

          OutlinedButton.icon(
            onPressed: _importando ? null : _limparImportacaoAnterior,
            icon: const Icon(Icons.cleaning_services_outlined),
            label: const Text('Limpar importação anterior'),
          ),

          if (preview != null) ...[
            const SizedBox(height: 24),

            const Text(
              'Prévia da importação',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 12),

            _ResumoCard(preview: preview),

            const SizedBox(height: 16),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Conta para as receitas',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Escolha onde as receitas históricas serão lançadas. '
                      'A planilha não informa essa conta.',
                    ),

                    const SizedBox(height: 12),

                    DropdownButtonFormField<int>(
                      initialValue: _contaReceitasId,
                      decoration: const InputDecoration(
                        labelText: 'Conta padrão das receitas',
                      ),
                      items: _contas
                          .map(
                            (conta) => DropdownMenuItem<int>(
                              value: conta.id,
                              child: Text(conta.nome),
                            ),
                          )
                          .toList(),
                      onChanged: (value) async {
                        setState(() {
                          _contaReceitasId = value;
                        });

                        if (value != null) {
                          await _prepararCamposSaldo(preview);
                        }
                      },
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      'Saldos reais de hoje',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      'Informe o saldo real de hoje das suas contas bancárias. '
                      'Cartões de crédito não entram aqui.',
                    ),

                    const SizedBox(height: 12),

                    ..._nomesContasDaImportacao(preview).map(
                      (nome) => Padding(
                        padding: const EdgeInsets.only(
                          bottom: 12,
                        ),
                        child: TextField(
                          controller: _controllerSaldo(nome),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: nome,
                            prefixText: 'R\$ ',
                            hintText: '0,00',
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: .08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.auto_fix_high_rounded,
                            size: 20,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'O Horizonte não vai somar o histórico novamente '
                              'ao saldo atual. Ele calcula automaticamente o '
                              'saldo inicial necessário para chegar aos valores '
                              'que você informou.',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            if (preview.avisos.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Antes de importar',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 10),

                      for (final aviso in preview.avisos) ...[
                        const Padding(
                          padding: EdgeInsets.only(bottom: 6),
                          child: Icon(
                            Icons.info_outline_rounded,
                            size: 18,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(aviso),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: podeImportar ? _importar : null,
                icon: _importando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.download_done_rounded,
                      ),
                label: Text(
                  _importando
                      ? 'Importando...'
                      : 'Importar dados',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<String> _nomesContasDaImportacao(
    ImportacaoPlanilhaPreview preview,
  ) {
    final nomes = <String>{
      for (final conta in _contas) conta.nome.trim(),
    };

    if (_contaReceitasId != null) {
      final conta = _contas.where(
        (item) => item.id == _contaReceitasId,
      );

      if (conta.isNotEmpty) {
        nomes.add(conta.first.nome.trim());
      }
    }

    return nomes.where((nome) => nome.isNotEmpty).toList()..sort();
  }

  TextEditingController _controllerSaldo(String nome) {
    return _saldoAtualControllers.putIfAbsent(
      nome.trim().toLowerCase(),
      () => TextEditingController(),
    );
  }

  Future<void> _prepararCamposSaldo(
    ImportacaoPlanilhaPreview preview,
  ) async {
    final nomes = _nomesContasDaImportacao(preview);

    for (final nome in nomes) {
      final controller = _controllerSaldo(nome);

      if (controller.text.isNotEmpty) {
        continue;
      }

      final contasEncontradas = _contas.where(
        (item) =>
            item.nome.trim().toLowerCase() ==
            nome.trim().toLowerCase(),
      );

      double saldo = 0;

      if (contasEncontradas.isNotEmpty) {
        saldo = await _contaRepository.saldoAtual(
          contasEncontradas.first.id,
        );
      }

      controller.text =
          saldo.toStringAsFixed(2).replaceAll('.', ',');
    }

    if (mounted) {
      setState(() {});
    }
  }

  Map<String, double> _saldosInformados() {
    final resultado = <String, double>{};

    for (final entry in _saldoAtualControllers.entries) {
      final texto = entry.value.text.trim();

      final valor = double.tryParse(
        texto.replaceAll('.', '').replaceAll(',', '.'),
      );

      if (valor != null) {
        resultado[entry.key] = valor;
      }
    }

    return resultado;
  }

  bool _saldosObrigatoriosPreenchidos(
    ImportacaoPlanilhaPreview preview,
  ) {
    for (final nome in _nomesContasDaImportacao(preview)) {
      if (_controllerSaldo(nome).text.trim().isEmpty) {
        return false;
      }
    }

    return true;
  }
}

class _ResumoCard extends StatelessWidget {
  final ImportacaoPlanilhaPreview preview;

  const _ResumoCard({
    required this.preview,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _Linha(
              'Receitas',
              '${preview.receitas}',
            ),
            _Linha(
              'Despesas',
              '${preview.despesas}',
            ),
            _Linha(
              'Categorias',
              '${preview.categorias}',
            ),
            _Linha(
              'Formas de pagamento',
              '${preview.formasPagamento}',
            ),
            _Linha(
              'Investimentos',
              '${preview.investimentos}',
            ),
            _Linha(
              'Metas',
              '${preview.metas}',
            ),

            const Divider(height: 24),

            _Linha(
              'Data completa na descrição',
              '${preview.linhasComDataCompleta}',
            ),
            _Linha(
              'Somente dia na descrição',
              '${preview.linhasComDiaExplicito}',
            ),
            _Linha(
              'Sem data na descrição',
              '${preview.linhasSemDataExplicita}',
            ),
            _Linha(
              'Duplicados removidos',
              '${preview.duplicadosNaPlanilha}',
            ),

            if (preview.formas.isNotEmpty) ...[
              const Divider(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  preview.formas.join(' • '),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Linha extends StatelessWidget {
  final String titulo;
  final String valor;

  const _Linha(
    this.titulo,
    this.valor,
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 5,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(titulo),
          ),
          Text(
            valor,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}