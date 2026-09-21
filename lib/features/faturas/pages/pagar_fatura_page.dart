import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../../../database/app_database.dart';
import '../../../database/database_service.dart';
import '../../../repositories/conta_repository.dart';
import '../../../repositories/fatura_repository.dart';
import '../../../repositories/pagamento_fatura_repository.dart';
import '../../../shared/utils/formatters.dart';

class PagarFaturaPage extends StatefulWidget {
  final Fatura fatura;
  final double valor;

  const PagarFaturaPage({
    super.key,
    required this.fatura,
    required this.valor,
  });

  @override
  State<PagarFaturaPage> createState() =>
      _PagarFaturaPageState();
}

class _PagarFaturaPageState
    extends State<PagarFaturaPage> {
  final _db = DatabaseService.instance.database;

  late final ContaRepository _contaRepository;
  late final FaturaRepository _faturaRepository;
  late final PagamentoFaturaRepository
      _pagamentoFaturaRepository;

  int? _contaSelecionada;

  bool _pagando = false;

  late Future<List<_ContaPagamento>> _contasFuture;
  late Future<double> _valorRestanteFuture;

  @override
  void initState() {
    super.initState();

    _contaRepository = ContaRepository(_db);
    _faturaRepository = FaturaRepository(_db);

    _pagamentoFaturaRepository =
        PagamentoFaturaRepository(_db);

    _valorRestanteFuture =
        _faturaRepository.calcularValorRestante(
      widget.fatura.id,
    );

    _contasFuture = _carregarContas();
  }

  Future<List<_ContaPagamento>> _carregarContas() async {
    final contas =
        await _contaRepository.buscarTodas();

    final resultado = <_ContaPagamento>[];

    for (final conta in contas) {
      final saldo =
          await _contaRepository.saldoAtual(
        conta.id,
      );

      resultado.add(
        _ContaPagamento(
          conta: conta,
          saldo: saldo,
        ),
      );
    }

    return resultado;
  }

  Future<void> _confirmarPagamento(
    double valorRestante,
  ) async {
    if (valorRestante <= 0) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Esta fatura já está totalmente paga.',
          ),
        ),
      );

      return;
    }

    if (_contaSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Selecione uma conta para pagar a fatura.',
          ),
        ),
      );

      return;
    }

    final contas =
        await _contaRepository.buscarTodas();

    Conta? conta;

    for (final item in contas) {
      if (item.id == _contaSelecionada) {
        conta = item;
        break;
      }
    }

    if (conta == null) {
      return;
    }

    final saldo =
        await _contaRepository.saldoAtual(
      conta.id,
    );

    if (saldo < valorRestante) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Saldo insuficiente para pagar esta fatura.',
          ),
        ),
      );

      return;
    }

    if (!mounted) return;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Confirmar pagamento',
          ),
          content: Text(
            'Deseja pagar ${Formatters.moeda(valorRestante)} '
            'usando a conta "${conta!.nome}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) {
      return;
    }

    setState(() {
      _pagando = true;
    });

    try {
      await _db.transaction(() async {
        await _pagamentoFaturaRepository.registrar(
          faturaId: widget.fatura.id,
          contaId: conta!.id,
          valor: valorRestante,
        );

        await (_db.update(_db.faturas)
              ..where(
                (t) => t.id.equals(widget.fatura.id),
              ))
            .write(
          FaturasCompanion(
            paga: const Value(true),
            dataPagamento:
                Value(DateTime.now()),
          ),
        );
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Fatura paga com sucesso!',
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao pagar a fatura:\n$e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _pagando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pagar fatura',
        ),
      ),
      body: FutureBuilder<double>(
        future: _valorRestanteFuture,
        builder: (context, valorSnapshot) {
          if (valorSnapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (valorSnapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Erro ao calcular o valor restante:\n'
                  '${valorSnapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final valorRestante =
              valorSnapshot.data ?? 0;

          return FutureBuilder<
              List<_ContaPagamento>>(
            future: _contasFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'Erro ao carregar contas:\n'
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              final contas = snapshot.data ?? [];

              if (contas.isEmpty) {
                return const Center(
                  child: Text(
                    'Nenhuma conta cadastrada.',
                  ),
                );
              }

              return Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        Card(
                          child: Padding(
                            padding:
                                const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Valor da fatura',
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  Formatters.moeda(
                                    widget.valor,
                                  ),
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 20),

                                const Text(
                                  'Já pago',
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 4),

                                FutureBuilder<double>(
                                  future: _faturaRepository
                                      .calcularTotalPago(
                                    widget.fatura.id,
                                  ),
                                  builder:
                                      (context, snapshot) {
                                    final pago =
                                        snapshot.data ?? 0;

                                    return Text(
                                      Formatters.moeda(
                                        pago,
                                      ),
                                      style:
                                          const TextStyle(
                                        fontSize: 20,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    );
                                  },
                                ),

                                const SizedBox(height: 20),

                                const Text(
                                  'Restante',
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 4),

                                Text(
                                  Formatters.moeda(
                                    valorRestante,
                                  ),
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight:
                                        FontWeight.bold,
                                    color: valorRestante > 0
                                        ? Theme.of(context)
                                            .colorScheme
                                            .primary
                                        : Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        const Text(
                          'Escolha a conta',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 12),

                        ...contas.map(
                          (item) {
                            final selecionada =
                                _contaSelecionada ==
                                    item.conta.id;

                            final saldoSuficiente =
                                item.saldo >=
                                    valorRestante;

                            return Card(
                              margin:
                                  const EdgeInsets.only(
                                bottom: 10,
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  child: Icon(
                                    selecionada
                                        ? Icons.check
                                        : Icons
                                            .account_balance,
                                  ),
                                ),
                                title: Text(
                                  item.conta.nome,
                                ),
                                subtitle: Text(
                                  'Saldo: '
                                  '${Formatters.moeda(item.saldo)}',
                                ),
                                trailing: Icon(
                                  selecionada
                                      ? Icons
                                          .radio_button_checked
                                      : Icons
                                          .radio_button_off,
                                  color: selecionada
                                      ? Theme.of(context)
                                          .colorScheme
                                          .primary
                                      : Colors.grey,
                                ),
                                onTap:
                                    saldoSuficiente &&
                                            valorRestante >
                                                0 &&
                                            !_pagando
                                        ? () {
                                            setState(() {
                                              _contaSelecionada =
                                                  item.conta
                                                      .id;
                                            });
                                          }
                                        : null,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  SafeArea(
                    child: Padding(
                      padding:
                          const EdgeInsets.all(16),
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed:
                              _pagando ||
                                      valorRestante <= 0
                                  ? null
                                  : () =>
                                      _confirmarPagamento(
                                        valorRestante,
                                      ),
                          icon: _pagando
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(
                                  Icons
                                      .payments_outlined,
                                ),
                          label: Text(
                            _pagando
                                ? 'Processando...'
                                : 'Pagar ${Formatters.moeda(valorRestante)}',
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _ContaPagamento {
  final Conta conta;
  final double saldo;

  const _ContaPagamento({
    required this.conta,
    required this.saldo,
  });
}