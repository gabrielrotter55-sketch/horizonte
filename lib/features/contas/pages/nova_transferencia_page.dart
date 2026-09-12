import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../database/database_service.dart';
import '../../../repositories/conta_repository.dart';
import '../viewmodels/transferencia_viewmodel.dart';

class NovaTransferenciaPage extends StatefulWidget {
  const NovaTransferenciaPage({
    super.key,
  });

  @override
  State<NovaTransferenciaPage> createState() =>
      _NovaTransferenciaPageState();
}

class _NovaTransferenciaPageState
    extends State<NovaTransferenciaPage> {
  final _formKey = GlobalKey<FormState>();

  final _valorController = TextEditingController();
  final _descricaoController = TextEditingController();

  final _viewModel = TransferenciaViewModel();

  late final ContaRepository _contaRepository;

  List<dynamic> _contas = [];

  int? _contaOrigemId;
  int? _contaDestinoId;
  DateTime _data = DateTime.now();

  bool _salvando = false;

  @override
  void initState() {
    super.initState();

    _contaRepository = ContaRepository(
      DatabaseService.instance.database,
    );

    _valorController.addListener(_atualizarResumo);

    _carregarContas();
  }

  @override
  void dispose() {
    _valorController.removeListener(_atualizarResumo);
    _valorController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  void _atualizarResumo() {
    if (!mounted) {
      return;
    }

    setState(() {});
  }

  Future<void> _carregarContas() async {
    final contas = await _contaRepository.buscarTodas();

    if (!mounted) {
      return;
    }

    setState(() {
      _contas = contas;
    });
  }

  Future<void> _selecionarData() async {
    final data = await showDatePicker(
      context: context,
      initialDate: _data,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('pt', 'BR'),
    );

    if (data == null) {
      return;
    }

    setState(() {
      _data = data;
    });
  }

  double _parseValor(String texto) {
    final valor = texto
        .replaceAll('.', '')
        .replaceAll(',', '.');

    return double.tryParse(valor) ?? 0;
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_contaOrigemId == null ||
        _contaDestinoId == null) {
      _mostrarErro(
        'Selecione a conta de origem e a conta de destino.',
      );
      return;
    }

    if (_contaOrigemId == _contaDestinoId) {
      _mostrarErro(
        'A conta de origem e a conta de destino devem ser diferentes.',
      );
      return;
    }

    final valor = _parseValor(
      _valorController.text,
    );

    if (valor <= 0) {
      _mostrarErro(
        'Informe um valor maior que zero.',
      );
      return;
    }

    setState(() {
      _salvando = true;
    });

    try {
      await _viewModel.salvar(
        contaOrigemId: _contaOrigemId!,
        contaDestinoId: _contaDestinoId!,
        valor: valor,
        data: _data,
        descricao: _descricaoController.text.trim(),
      );

      if (!mounted) {
        return;
      }

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) {
        return;
      }

      _mostrarErro(
        e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() {
          _salvando = false;
        });
      }
    }
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
      ),
    );
  }

  String _nomeConta(int id) {
    for (final conta in _contas) {
      if (conta.id == id) {
        return conta.nome;
      }
    }

    return '';
  }

  @override
  Widget build(BuildContext context) {
    final moeda = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );

    final valorAtual = _parseValor(
      _valorController.text,
    );

    final mostrarResumo = _contaOrigemId != null &&
        _contaDestinoId != null &&
        valorAtual > 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova transferência'),
      ),
      body: _contas.length < 2
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Cadastre pelo menos duas contas para realizar uma transferência.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : SafeArea(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    const Text(
                      'Transferir entre contas',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'A transferência movimenta os saldos das contas sem alterar suas receitas ou despesas.',
                    ),
                    const SizedBox(height: 24),

                    DropdownButtonFormField<int>(
                      initialValue: _contaOrigemId,
                      decoration: const InputDecoration(
                        labelText: 'Conta de origem',
                        prefixIcon: Icon(
                          Icons.arrow_upward_rounded,
                        ),
                      ),
                      items: _contas
                          .map(
                            (conta) => DropdownMenuItem<int>(
                              value: conta.id,
                              child: Text(conta.nome),
                            ),
                          )
                          .toList(),
                      onChanged: (valor) {
                        setState(() {
                          _contaOrigemId = valor;

                          if (_contaDestinoId == valor) {
                            _contaDestinoId = null;
                          }
                        });
                      },
                      validator: (valor) {
                        if (valor == null) {
                          return 'Selecione a conta de origem';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    Center(
                      child: Icon(
                        Icons.arrow_downward_rounded,
                        color: Theme.of(context)
                            .colorScheme
                            .primary,
                        size: 28,
                      ),
                    ),

                    const SizedBox(height: 16),

                    DropdownButtonFormField<int>(
                      initialValue: _contaDestinoId,
                      decoration: const InputDecoration(
                        labelText: 'Conta de destino',
                        prefixIcon: Icon(
                          Icons.arrow_downward_rounded,
                        ),
                      ),
                      items: _contas
                          .where(
                            (conta) =>
                                conta.id != _contaOrigemId,
                          )
                          .map(
                            (conta) => DropdownMenuItem<int>(
                              value: conta.id,
                              child: Text(conta.nome),
                            ),
                          )
                          .toList(),
                      onChanged: (valor) {
                        setState(() {
                          _contaDestinoId = valor;
                        });
                      },
                      validator: (valor) {
                        if (valor == null) {
                          return 'Selecione a conta de destino';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    TextFormField(
                      controller: _valorController,
                      keyboardType:
                          const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Valor',
                        hintText: '0,00',
                        prefixText: 'R\$ ',
                        prefixIcon: Icon(
                          Icons.payments_outlined,
                        ),
                      ),
                      validator: (valor) {
                        if (valor == null ||
                            valor.trim().isEmpty) {
                          return 'Informe o valor';
                        }

                        if (_parseValor(valor) <= 0) {
                          return 'Informe um valor maior que zero';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _descricaoController,
                      textCapitalization:
                          TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'Descrição',
                        hintText:
                            'Ex.: Transferência para reserva',
                        prefixIcon: Icon(
                          Icons.notes_outlined,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    InkWell(
                      onTap: _selecionarData,
                      borderRadius: BorderRadius.circular(12),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Data',
                          prefixIcon: Icon(
                            Icons.calendar_today_outlined,
                          ),
                        ),
                        child: Text(
                          DateFormat(
                            'dd/MM/yyyy',
                          ).format(_data),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    if (mostrarResumo)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Resumo',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _nomeConta(
                                        _contaOrigemId!,
                                      ),
                                      style: const TextStyle(
                                        fontWeight:
                                            FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const Padding(
                                    padding:
                                        EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    child: Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 20,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      _nomeConta(
                                        _contaDestinoId!,
                                      ),
                                      style: const TextStyle(
                                        fontWeight:
                                            FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.end,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                moeda.format(valorAtual),
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 28),

                    SizedBox(
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: _salvando
                            ? null
                            : _salvar,
                        icon: _salvando
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.swap_horiz_rounded,
                              ),
                        label: Text(
                          _salvando
                              ? 'Salvando...'
                              : 'Transferir',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}