import 'package:flutter/material.dart';

import '../../../database/app_database.dart';
import '../viewmodels/lancamento_view_model.dart';

class NovoLancamentoPage extends StatefulWidget {
  final Lancamento? lancamento;

  const NovoLancamentoPage({
    super.key,
    this.lancamento,
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

  bool _receita = false;

  DateTime _data = DateTime.now();

  int? _categoriaId;
  int? _contaId;
  int? _cartaoId;

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
    }

    _dadosFuture = _carregarDados();
  }

  Future<_DadosFormulario> _carregarDados() async {
    final categorias =
        await _viewModel.categoriaRepository.buscarTodas();

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
    final descricao =
        _descricaoController.text.trim();

    final valor = double.tryParse(
          _valorController.text.replaceAll(',', '.'),
        ) ??
        0;

    if (descricao.isEmpty) {
      _mostrarErro('Digite uma descrição.');
      return;
    }

    if (valor <= 0) {
      _mostrarErro(
        'Digite um valor maior que zero.',
      );
      return;
    }

    if (_categoriaId == null) {
      _mostrarErro(
        'Selecione uma categoria.',
      );
      return;
    }

    if (_contaId == null) {
      _mostrarErro(
        'Selecione uma conta.',
      );
      return;
    }

    if (_editando) {
      await _viewModel.editar(
        id: widget.lancamento!.id,
        descricao: descricao,
        valor: valor,
        receita: _receita,
        data: _data,
        categoriaId: _categoriaId!,
        contaId: _contaId!,
        cartaoId: _cartaoId,
      );
    } else {
      await _viewModel.salvar(
        descricao: descricao,
        valor: valor,
        receita: _receita,
        data: _data,
        categoriaId: _categoriaId!,
        contaId: _contaId!,
        cartaoId: _cartaoId,
      );
    }

    if (!mounted) {
      return;
    }

    Navigator.pop(context, true);
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

                const SizedBox(height: 20),

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

                DropdownButtonFormField<int>(
                  initialValue: _contaId,
                  decoration: const InputDecoration(
                    labelText: 'Conta',
                    border: OutlineInputBorder(),
                  ),
                  items: dados.contas.map(
                    (conta) {
                      return DropdownMenuItem<int>(
                        value: conta.id,
                        child: Text(conta.nome),
                      );
                    },
                  ).toList(),
                  onChanged: (value) {
                    setState(() {
                      _contaId = value;
                    });
                  },
                ),

                const SizedBox(height: 20),

                DropdownButtonFormField<int?>(
                  initialValue: _cartaoId,
                  decoration: const InputDecoration(
                    labelText: 'Cartão',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('Nenhum'),
                    ),
                    ...dados.cartoes.map(
                      (cartao) {
                        return DropdownMenuItem<int?>(
                          value: cartao.id,
                          child: Text(cartao.nome),
                        );
                      },
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _cartaoId = value;
                    });
                  },
                ),

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