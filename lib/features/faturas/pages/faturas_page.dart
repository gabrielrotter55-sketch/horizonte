import 'package:flutter/material.dart';

import '../../../database/app_database.dart';
import '../../../database/database_service.dart';
import '../../../repositories/cartao_repository.dart';
import '../../../repositories/fatura_repository.dart';
import '../../../shared/utils/formatters.dart';
import 'detalhes_fatura_page.dart';

class FaturasPage extends StatefulWidget {
  const FaturasPage({super.key});

  @override
  State<FaturasPage> createState() => _FaturasPageState();
}

class _FaturasPageState extends State<FaturasPage> {
  final cartaoRepository = CartaoRepository(
    DatabaseService.instance.database,
  );

  final faturaRepository = FaturaRepository(
    DatabaseService.instance.database,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Faturas'),
      ),
      body: FutureBuilder(
        future: cartaoRepository.buscarTodas(),
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
                'Erro ao carregar cartões:\n'
                '${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          final cartoes = snapshot.data ?? [];

          if (cartoes.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum cartão cadastrado',
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cartoes.length,
            itemBuilder: (context, index) {
              final cartao = cartoes[index];

              final hoje = DateTime.now();

              final referenciaAtual = _mesReferencia(
                hoje,
                cartao.fechamento,
              );

              final referenciaProxima =
                  _proximaReferencia(
                referenciaAtual,
              );

              return FutureBuilder<
                  _DadosCartaoFaturas>(
                future: _carregarDadosCartao(
                  cartao.id,
                  referenciaAtual,
                  referenciaProxima,
                ),
                builder: (context, faturasSnapshot) {
                  if (faturasSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(
                          child:
                              CircularProgressIndicator(),
                        ),
                      ),
                    );
                  }

                  if (faturasSnapshot.hasError) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Erro ao carregar faturas:\n'
                          '${faturasSnapshot.error}',
                        ),
                      ),
                    );
                  }

                  if (!faturasSnapshot.hasData) {
                    return const SizedBox.shrink();
                  }

                  final dados =
                      faturasSnapshot.data!;

                  return Card(
                    margin: const EdgeInsets.only(
                      bottom: 16,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          // =========================
                          // CARTÃO
                          // =========================

                          Row(
                            children: [
                              const CircleAvatar(
                                child: Icon(
                                  Icons.credit_card,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  cartao.nome,
                                  style:
                                      const TextStyle(
                                    fontSize: 18,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // =========================
                          // FATURA ATUAL
                          // =========================

                          const Text(
                            'Fatura atual',
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            Formatters.moeda(
                              dados.atual.total,
                            ),
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 12),

                          _StatusFatura(
                            paga: dados.atual.fatura.paga,
                          ),

                          const SizedBox(height: 12),

                          _BotaoVerFatura(
                            context: context,
                            fatura:
                                dados.atual.fatura,
                            onReturn: () {
                              setState(() {});
                            },
                          ),

                          const SizedBox(height: 24),

                          const Divider(),

                          const SizedBox(height: 24),

                          // =========================
                          // PRÓXIMA FATURA
                          // =========================

                          const Text(
                            'Próxima fatura',
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            Formatters.moeda(
                              dados.proxima.total,
                            ),
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            _nomeMes(
                              referenciaProxima.mes,
                            ),
                            style: TextStyle(
                              color:
                                  Colors.grey.shade600,
                            ),
                          ),

                          const SizedBox(height: 12),

                          const _StatusFatura(
                            paga: false,
                          ),

                          const SizedBox(height: 12),

                          _BotaoVerFatura(
                            context: context,
                            fatura:
                                dados.proxima.fatura,
                            onReturn: () {
                              setState(() {});
                            },
                          ),

                          const SizedBox(height: 24),

                          const Divider(),

                          const SizedBox(height: 20),

                          // =========================
                          // HISTÓRICO
                          // =========================

                          const Text(
                            'Histórico de faturas',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 12),

                          if (dados.historico.isEmpty)
                            const Card(
                              child: Padding(
                                padding:
                                    EdgeInsets.all(16),
                                child: Center(
                                  child: Text(
                                    'Nenhuma fatura anterior.',
                                  ),
                                ),
                              ),
                            ),

                          ...dados.historico.map(
                            (historico) {
                              return Card(
                                margin:
                                    const EdgeInsets.only(
                                  bottom: 8,
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    child: Icon(
                                      historico
                                              .fatura
                                              .paga
                                          ? Icons
                                              .check_circle
                                          : Icons
                                              .receipt_long,
                                    ),
                                  ),
                                  title: Text(
                                    _nomeReferencia(
                                      historico.fatura
                                          .mesReferencia,
                                      historico.fatura
                                          .anoReferencia,
                                    ),
                                  ),
                                  subtitle: Text(
                                    historico.fatura
                                            .paga
                                        ? 'Fatura paga'
                                        : 'Fatura em aberto',
                                  ),
                                  trailing: Text(
                                    Formatters.moeda(
                                      historico.total,
                                    ),
                                    style:
                                        const TextStyle(
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                  onTap: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            DetalhesFaturaPage(
                                          fatura:
                                              historico
                                                  .fatura,
                                        ),
                                      ),
                                    );

                                    if (mounted) {
                                      setState(() {});
                                    }
                                  },
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<_DadosCartaoFaturas>
      _carregarDadosCartao(
    int cartaoId,
    _Referencia referenciaAtual,
    _Referencia referenciaProxima,
  ) async {
    // =========================
    // FATURA ATUAL
    // =========================

    var faturaAtual =
        await faturaRepository
            .buscarPorCartaoEReferencia(
      cartaoId: cartaoId,
      mes: referenciaAtual.mes,
      ano: referenciaAtual.ano,
    );

    if (faturaAtual == null) {
      final id = await faturaRepository.criar(
        cartaoId: cartaoId,
        mes: referenciaAtual.mes,
        ano: referenciaAtual.ano,
      );

      faturaAtual =
          await faturaRepository.buscarPorId(id);
    }

    if (faturaAtual == null) {
      throw Exception(
        'Não foi possível criar a fatura atual.',
      );
    }

    final totalAtual =
        await faturaRepository.calcularTotal(
      faturaAtual.id,
    );

    // =========================
    // PRÓXIMA FATURA
    // =========================

    var faturaProxima =
        await faturaRepository
            .buscarPorCartaoEReferencia(
      cartaoId: cartaoId,
      mes: referenciaProxima.mes,
      ano: referenciaProxima.ano,
    );

    if (faturaProxima == null) {
      final id = await faturaRepository.criar(
        cartaoId: cartaoId,
        mes: referenciaProxima.mes,
        ano: referenciaProxima.ano,
      );

      faturaProxima =
          await faturaRepository.buscarPorId(id);
    }

    if (faturaProxima == null) {
      throw Exception(
        'Não foi possível criar a próxima fatura.',
      );
    }

    final totalProxima =
        await faturaRepository.calcularTotal(
      faturaProxima.id,
    );

    // =========================
    // HISTÓRICO
    // =========================

    final todas =
        await faturaRepository.buscarTodas();

    final faturasDoCartao = todas.where(
      (fatura) =>
          fatura.cartaoId == cartaoId &&
          !(
            fatura.mesReferencia ==
                referenciaAtual.mes &&
            fatura.anoReferencia ==
                referenciaAtual.ano
          ) &&
          !(
            fatura.mesReferencia ==
                referenciaProxima.mes &&
            fatura.anoReferencia ==
                referenciaProxima.ano
          ),
    ).toList();

    faturasDoCartao.sort(
      (a, b) {
        final dataA = DateTime(
          a.anoReferencia,
          a.mesReferencia,
        );

        final dataB = DateTime(
          b.anoReferencia,
          b.mesReferencia,
        );

        return dataB.compareTo(dataA);
      },
    );

    final historico =
        <_DadosFaturaHistorico>[];

    for (final fatura in faturasDoCartao) {
      final total =
          await faturaRepository.calcularTotal(
        fatura.id,
      );

      historico.add(
        _DadosFaturaHistorico(
          fatura: fatura,
          total: total,
        ),
      );
    }

    return _DadosCartaoFaturas(
      atual: _DadosFatura(
        fatura: faturaAtual,
        total: totalAtual,
      ),
      proxima: _DadosFatura(
        fatura: faturaProxima,
        total: totalProxima,
      ),
      historico: historico,
    );
  }

  _Referencia _mesReferencia(
    DateTime data,
    int diaFechamento,
  ) {
    if (data.day <= diaFechamento) {
      return _Referencia(
        mes: data.month,
        ano: data.year,
      );
    }

    if (data.month == 12) {
      return _Referencia(
        mes: 1,
        ano: data.year + 1,
      );
    }

    return _Referencia(
      mes: data.month + 1,
      ano: data.year,
    );
  }

  _Referencia _proximaReferencia(
    _Referencia referencia,
  ) {
    if (referencia.mes == 12) {
      return _Referencia(
        mes: 1,
        ano: referencia.ano + 1,
      );
    }

    return _Referencia(
      mes: referencia.mes + 1,
      ano: referencia.ano,
    );
  }

  String _nomeMes(int mes) {
    const meses = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];

    return meses[mes - 1];
  }

  String _nomeReferencia(
    int mes,
    int ano,
  ) {
    return '${_nomeMes(mes)}/$ano';
  }
}

class _BotaoVerFatura extends StatelessWidget {
  final BuildContext context;
  final Fatura fatura;
  final VoidCallback onReturn;

  const _BotaoVerFatura({
    required this.context,
    required this.fatura,
    required this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  DetalhesFaturaPage(
                fatura: fatura,
              ),
            ),
          );

          onReturn();
        },
        icon: const Icon(
          Icons.receipt_long,
        ),
        label: const Text(
          'Ver fatura',
        ),
      ),
    );
  }
}

class _StatusFatura extends StatelessWidget {
  final bool paga;

  const _StatusFatura({
    required this.paga,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: paga
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.orange.withValues(alpha: 0.1),
      ),
      child: Row(
        children: [
          Icon(
            paga
                ? Icons.check_circle
                : Icons.schedule,
            color: paga
                ? Colors.green
                : Colors.orange,
          ),
          const SizedBox(width: 8),
          Text(
            paga
                ? 'Fatura paga'
                : 'Fatura em aberto',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: paga
                  ? Colors.green
                  : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }
}

class _Referencia {
  final int mes;
  final int ano;

  const _Referencia({
    required this.mes,
    required this.ano,
  });
}

class _DadosFatura {
  final Fatura fatura;
  final double total;

  const _DadosFatura({
    required this.fatura,
    required this.total,
  });
}

class _DadosFaturaHistorico {
  final Fatura fatura;
  final double total;

  const _DadosFaturaHistorico({
    required this.fatura,
    required this.total,
  });
}

class _DadosCartaoFaturas {
  final _DadosFatura atual;
  final _DadosFatura proxima;
  final List<_DadosFaturaHistorico> historico;

  const _DadosCartaoFaturas({
    required this.atual,
    required this.proxima,
    required this.historico,
  });
}