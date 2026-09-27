import 'package:flutter/material.dart';

import '../../../database/app_database.dart';
import '../viewmodels/lancamento_view_model.dart';
import '../../../repositories/beneficio_repository.dart';
import '../../../models/compromisso.dart';
import '../../../repositories/compromisso_repository.dart';

class NovoLancamentoPage extends StatefulWidget {
  final Lancamento? lancamento;
  final bool? receitaInicial;
  final String? origemInicial;

  const NovoLancamentoPage({
    super.key,
    this.lancamento,
    this.receitaInicial,
    this.origemInicial,
  });

  @override
  State<NovoLancamentoPage> createState() =>
      _NovoLancamentoPageState();
}

class _NovoLancamentoPageState
    extends State<NovoLancamentoPage> {
  final _descricaoController = TextEditingController();
  final _valorController = TextEditingController();

  final _viewModel = LancamentoViewModel();
  final _beneficioRepository = BeneficioRepository();

  bool _receita = false;

  DateTime _data = DateTime.now();

  int? _categoriaId;
  int? _contaId;
  int? _cartaoId;
  String _origem = 'manual';
  bool _parcelado = false;
  int _parcelas = 2;
  bool _valorEhParcela = false;

  late Future<_DadosFormulario> _dadosFuture;

  bool get _editando => widget.lancamento != null;

  @override
  void initState() {
    super.initState();

    final lancamento = widget.lancamento;

    if (lancamento != null) {
      _descricaoController.text = lancamento.descricao;

      _valorController.text =
          lancamento.valor.toStringAsFixed(2);

      _receita = lancamento.receita;
      _data = lancamento.data;
      _categoriaId = lancamento.categoriaId;
      _contaId = lancamento.contaId;
      _cartaoId = lancamento.cartaoId;
      _origem = lancamento.origem;
    } else {
      if (widget.receitaInicial != null) {
        _receita = widget.receitaInicial!;
      }
      if (widget.origemInicial != null) {
        _origem = widget.origemInicial!;
      }
    }

    _dadosFuture = _carregarDados();
  }

  Future<_DadosFormulario> _carregarDados() async {
    final todasCategorias = await _viewModel.categoriaRepository.buscarPorTipo(receita: _receita);
    final categorias = [...todasCategorias];
    if (_categoriaId != null && !categorias.any((c) => c.id == _categoriaId)) {
      final todas = await _viewModel.categoriaRepository.buscarTodas();
      // Nunca reintroduz uma categoria de receita dentro de uma despesa (ou vice-versa).
      // Se o lançamento antigo estiver com classificação incompatível, a categoria será
      // limpa e o usuário escolherá uma categoria do tipo correto.
      final atual = todas.where((c) => c.id == _categoriaId && c.receita == _receita);
      if (atual.isNotEmpty) {
        categorias.addAll(atual);
      }
    }

    final contas =
        await _viewModel.contaRepository.buscarTodas();

    final cartoes =
        await _viewModel.cartaoRepository.buscarTodas();

    return _DadosFormulario(
      categorias: categorias,
      contas: contas,
      cartoes: cartoes,
    );
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    _valorController.dispose();

    super.dispose();
  }

  Future<void> _selecionarData() async {
    final data = await showDatePicker(
      context: context,
      initialDate: _data,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (data != null) {
      setState(() {
        _data = data;
      });
    }
  }

  Future<void> _salvar() async {
    final descricao = _descricaoController.text.trim();
    final valor = double.tryParse(_valorController.text.replaceAll(',', '.')) ?? 0;

    if (descricao.isEmpty) { _mostrarErro('Digite uma descrição.'); return; }
    if (valor <= 0) { _mostrarErro('Digite um valor maior que zero.'); return; }
    if (_categoriaId == null) { _mostrarErro('Selecione uma categoria.'); return; }

    final todasCategorias = await _viewModel.categoriaRepository.buscarTodas();
    dynamic categoriaSelecionada;
    for (final categoria in todasCategorias) { if (categoria.id == _categoriaId) { categoriaSelecionada = categoria; break; } }
    if (categoriaSelecionada == null || categoriaSelecionada.receita != _receita) {
      _mostrarErro('A categoria selecionada não pertence ao tipo de lançamento. Escolha uma categoria de ${_receita ? 'receita' : 'despesa'}.');
      return;
    }
    if (_contaId == null && _cartaoId == null && _origem != 'beneficio:vr_flash') { _mostrarErro('Selecione uma conta ou um cartão.'); return; }
    // Receitas no cartão representam reembolsos/estornos e devem reduzir a fatura.

    if (_parcelado && (_receita || _origem == 'beneficio:vr_flash')) { _mostrarErro('Parcelamento está disponível para despesas pagas por conta ou cartão.'); return; }

    final antigo = widget.lancamento;
    final antigoVr = antigo?.origem == 'beneficio:vr_flash';
    final novoVr = _origem == 'beneficio:vr_flash';
    if (novoVr && !_receita) {
      var saldo = await _beneficioRepository.saldoAtual();
      if (antigoVr && antigo!.receita == false) saldo += antigo.valor;
      if (valor > saldo) { _mostrarErro('Saldo insuficiente no VR Flash. Disponível: R\$ ${saldo.toStringAsFixed(2).replaceAll('.', ',')}'); return; }
    }

    if (_editando && _parcelado && !_receita) {
      // Converte um lançamento já existente em parcelado: o registro original
      // vira a primeira parcela e as demais são criadas automaticamente.
      await _viewModel.repository.excluir(widget.lancamento!.id);
      final valorParcela = _valorEhParcela ? valor : valor / _parcelas;
      if (_cartaoId != null) {
        for (var i = 1; i <= _parcelas; i++) {
          await _viewModel.salvar(descricao: '$descricao ($i/$_parcelas)', valor: valorParcela, receita: false, data: _somarMeses(_data, i - 1), categoriaId: _categoriaId!, contaId: null, cartaoId: _cartaoId, origem: _origem);
        }
      } else {
        await _viewModel.salvar(descricao: '$descricao (1/$_parcelas)', valor: valorParcela, receita: false, data: _data, categoriaId: _categoriaId!, contaId: _contaId, cartaoId: null, origem: _origem);
        final repo = CompromissoRepository();
        for (var i = 2; i <= _parcelas; i++) {
          await repo.salvar(Compromisso(id: DateTime.now().microsecondsSinceEpoch.toString() + '_$i', descricao: '$descricao ($i/$_parcelas)', valor: valorParcela, data: _somarMeses(_data, i - 1), tipo: TipoCompromisso.esporadico, categoria: categoriaSelecionada.nome, favorecido: '', status: StatusCompromisso.pendente, observacao: 'Parcela $_parcelas', pagoEm: null));
        }
      }
    } else if (_editando) {
      await _viewModel.editar(id: widget.lancamento!.id, descricao: descricao, valor: valor, receita: _receita, data: _data, categoriaId: _categoriaId!, contaId: _contaId, cartaoId: _cartaoId, origem: _origem);
      if (antigoVr) {
        if (antigo!.receita) await _beneficioRepository.estornarReceita(antigo.valor); else await _beneficioRepository.estornarGasto(antigo.valor);
      }
      if (novoVr) {
        if (_receita) await _beneficioRepository.registrarReceita(valor); else await _beneficioRepository.registrarGasto(valor);
      }
    } else if (_parcelado && !_receita) {
      final valorParcela = _valorEhParcela ? valor : valor / _parcelas;
      if (_cartaoId != null) {
        for (var i = 1; i <= _parcelas; i++) {
          final dataParcela = _somarMeses(_data, i - 1);
          await _viewModel.salvar(descricao: '$descricao ($i/$_parcelas)', valor: valorParcela, receita: false, data: dataParcela, categoriaId: _categoriaId!, contaId: null, cartaoId: _cartaoId, origem: _origem);
        }
      } else {
        await _viewModel.salvar(descricao: '$descricao (1/$_parcelas)', valor: valorParcela, receita: false, data: _data, categoriaId: _categoriaId!, contaId: _contaId, cartaoId: null, origem: _origem);
        final repo = CompromissoRepository();
        for (var i = 2; i <= _parcelas; i++) {
          final dataParcela = _somarMeses(_data, i - 1);
          await repo.salvar(Compromisso(
            id: DateTime.now().microsecondsSinceEpoch.toString() + '_$i',
            descricao: '$descricao ($i/$_parcelas)',
            valor: valorParcela,
            data: dataParcela,
            tipo: TipoCompromisso.esporadico,
            categoria: categoriaSelecionada.nome,
            favorecido: '',
            status: StatusCompromisso.pendente,
            observacao: 'Parcela $_parcelas',
            pagoEm: null,
          ));
        }
      }
    } else {
      await _viewModel.salvar(descricao: descricao, valor: valor, receita: _receita, data: _data, categoriaId: _categoriaId!, contaId: _contaId, cartaoId: _cartaoId, origem: _origem);
      if (novoVr) {
        if (_receita) await _beneficioRepository.registrarReceita(valor); else await _beneficioRepository.registrarGasto(valor);
      }
    }

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  DateTime _somarMeses(DateTime base, int meses) {
    final alvo = DateTime(base.year, base.month + meses, 1);
    final ultimoDia = DateTime(alvo.year, alvo.month + 1, 0).day;
    return DateTime(alvo.year, alvo.month, (base.day > ultimoDia ? ultimoDia : base.day));
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _editando
              ? 'Editar Lançamento'
              : 'Novo Lançamento',
        ),
      ),
      body: FutureBuilder<_DadosFormulario>(
        future: _dadosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erro ao carregar dados: ${snapshot.error}',
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Text(
                'Não foi possível carregar os dados.',
              ),
            );
          }

          final dados = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment<bool>(
                      value: false,
                      label: Text('Despesa'),
                      icon: Icon(
                        Icons.arrow_upward,
                      ),
                    ),
                    ButtonSegment<bool>(
                      value: true,
                      label: Text('Receita'),
                      icon: Icon(
                        Icons.arrow_downward,
                      ),
                    ),
                  ],
                  selected: {_receita},
                  onSelectionChanged: (selection) {
                    setState(() {
                      _receita = selection.first;
                      _categoriaId = null;
                      if (_receita) {
                        _cartaoId = null;
                        _contaId = null;
                        _origem = 'manual';
                      }
                      _dadosFuture = _carregarDados();
                    });
                  },
                ),

                const SizedBox(height: 20),

                TextField(
                  controller: _descricaoController,
                  decoration: const InputDecoration(
                    labelText: 'Descrição',
                    hintText: 'Ex.: Almoço',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),

                TextField(
                  controller: _valorController,
                  keyboardType:
                      const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Valor',
                    hintText: 'Ex.: 45,90',
                    prefixText: 'R\$ ',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),

                InkWell(
                  onTap: _selecionarData,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Data',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(
                        Icons.calendar_today,
                      ),
                    ),
                    child: Text(
                      '${_data.day.toString().padLeft(2, '0')}/'
                      '${_data.month.toString().padLeft(2, '0')}/'
                      '${_data.year}',
                    ),
                  ),
                ),

                if (!_receita && _origem != 'beneficio:vr_flash') ...[
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Parcelado'),
                    subtitle: const Text('Cria automaticamente as parcelas futuras'),
                    value: _parcelado,
                    onChanged: (v) => setState(() => _parcelado = v),
                  ),
                  if (_parcelado)
                    DropdownButtonFormField<int>(
                      initialValue: _parcelas,
                      decoration: const InputDecoration(labelText: 'Número de parcelas', border: OutlineInputBorder()),
                      items: [for (var i = 2; i <= 36; i++) DropdownMenuItem(value: i, child: Text('$i parcelas'))],
                      onChanged: (v) => setState(() => _parcelas = v ?? _parcelas),
                    ),
                  if (_parcelado) ...[
                    const SizedBox(height: 12),
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(value: false, label: Text('Valor total')),
                        ButtonSegment(value: true, label: Text('Valor da parcela')),
                      ],
                      selected: {_valorEhParcela},
                      onSelectionChanged: (v) => setState(() => _valorEhParcela = v.first),
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _valorEhParcela
                            ? 'Informe quanto será cada parcela. O total será calculado automaticamente.'
                            : 'Informe o valor total da compra. O valor de cada parcela será calculado automaticamente.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                ],

                DropdownButtonFormField<int>(
                  initialValue: _categoriaId,
                  decoration: const InputDecoration(
                    labelText: 'Categoria',
                    border: OutlineInputBorder(),
                  ),
                  items: dados.categorias.map(
                    (categoria) {
                      return DropdownMenuItem<int>(
                        value: categoria.id,
                        child: Text(
                          '${categoria.icone} '
                          '${categoria.nome}',
                        ),
                      );
                    },
                  ).toList(),
                  onChanged: (value) {
                    setState(() {
                      _categoriaId = value;
                    });
                  },
                ),

                const SizedBox(height: 20),

                if (_receita) ...[
                  Align(alignment: Alignment.centerLeft, child: Text('Onde recebeu?', style: Theme.of(context).textTheme.titleSmall)),
                  const SizedBox(height: 8),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'conta', label: Text('Conta')),
                      ButtonSegment(value: 'cartao', label: Text('Cartão')),
                      ButtonSegment(value: 'vr', label: Text('VR Flash')),
                    ],
                    selected: {_origem == 'beneficio:vr_flash' ? 'vr' : (_cartaoId != null ? 'cartao' : 'conta')},
                    onSelectionChanged: (selection) {
                      setState(() {
                        if (selection.first == 'vr') {
                          _origem = 'beneficio:vr_flash'; _contaId = null; _cartaoId = null;
                        } else if (selection.first == 'cartao') {
                          _origem = 'manual'; _contaId = null; _cartaoId = dados.cartoes.isEmpty ? null : dados.cartoes.first.id;
                        } else {
                          _origem = 'manual'; _cartaoId = null;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  if (_origem != 'beneficio:vr_flash' && _cartaoId == null) DropdownButtonFormField<int>(
                    initialValue: _contaId,
                    decoration: const InputDecoration(labelText: 'Conta', border: OutlineInputBorder()),
                    items: dados.contas.map((conta) => DropdownMenuItem<int>(value: conta.id, child: Text(conta.nome))).toList(),
                    onChanged: (value) => setState(() => _contaId = value),
                  ),
                  if (_origem != 'beneficio:vr_flash' && _cartaoId != null) DropdownButtonFormField<int>(
                    initialValue: _cartaoId,
                    decoration: const InputDecoration(labelText: 'Cartão', border: OutlineInputBorder()),
                    items: dados.cartoes.map((cartao) => DropdownMenuItem<int>(value: cartao.id, child: Text(cartao.nome))).toList(),
                    onChanged: (value) => setState(() => _cartaoId = value),
                  ),
                ] else ...[
                  Align(alignment: Alignment.centerLeft, child: Text('Forma de pagamento', style: Theme.of(context).textTheme.titleSmall)),
                  const SizedBox(height: 8),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'conta', label: Text('Conta')),
                      ButtonSegment(value: 'cartao', label: Text('Cartão')),
                      ButtonSegment(value: 'vr', label: Text('VR Flash')),
                    ],
                    selected: {_origem == 'beneficio:vr_flash' ? 'vr' : (_cartaoId != null ? 'cartao' : 'conta')},
                    onSelectionChanged: (selection) {
                      final forma = selection.first;
                      setState(() {
                        if (forma == 'vr') {
                          _origem = 'beneficio:vr_flash'; _contaId = null; _cartaoId = null; _parcelado = false;
                        } else {
                          _origem = 'manual';
                          if (forma == 'conta') _cartaoId = null;
                          if (forma == 'cartao') _contaId = null;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  if (_origem != 'beneficio:vr_flash') DropdownButtonFormField<int>(
                    initialValue: _contaId,
                    decoration: InputDecoration(labelText: _cartaoId == null ? 'Conta' : 'Conta (opcional no cartão)', border: const OutlineInputBorder()),
                    items: dados.contas.map((conta) => DropdownMenuItem<int>(value: conta.id, child: Text(conta.nome))).toList(),
                    onChanged: (value) => setState(() => _contaId = value),
                  ),
                  const SizedBox(height: 20),
                  if (_origem != 'beneficio:vr_flash') DropdownButtonFormField<int?>(
                    initialValue: _cartaoId,
                    decoration: const InputDecoration(labelText: 'Cartão', border: OutlineInputBorder()),
                    items: [
                      const DropdownMenuItem<int?>(value: null, child: Text('Nenhum')),
                      ...dados.cartoes.map((cartao) => DropdownMenuItem<int?>(value: cartao.id, child: Text(cartao.nome))),
                    ],
                    onChanged: (value) => setState(() { _cartaoId = value; if (value != null) _contaId = null; }),
                  ),
                ],

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _salvar,
                    child: Text(
                      _editando
                          ? 'Salvar alterações'
                          : 'Salvar lançamento',
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DadosFormulario {
  final List<Categoria> categorias;
  final List<Conta> contas;
  final List<Cartoe> cartoes;

  const _DadosFormulario({
    required this.categorias,
    required this.contas,
    required this.cartoes,
  });
}