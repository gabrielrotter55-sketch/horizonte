import 'package:flutter/material.dart';

import '../../../database/app_database.dart';
import '../../../database/database_service.dart';
import '../../../repositories/cartao_repository.dart';
import '../../../repositories/fatura_repository.dart';
import '../../../shared/utils/formatters.dart';
import 'detalhes_fatura_page.dart';

class FaturasPage extends StatelessWidget {
  FaturasPage({super.key});

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

              final mesReferencia = _mesReferencia(
                hoje,
                cartao.fechamento,
              );

              return FutureBuilder<_DadosFatura>(
                future: _carregarFatura(
                  cartao.id,
                  mesReferencia,
                ),
                builder: (context, faturaSnapshot) {
                  if (faturaSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    );
                  }

                  if (faturaSnapshot.hasError) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Erro ao carregar fatura:\n'
                          '${faturaSnapshot.error}',
                        ),
                      ),
                    );
                  }

                  if (!faturaSnapshot.hasData) {
                    return const SizedBox.shrink();
                  }

                  final dados = faturaSnapshot.data!;

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
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          const Text(
                            'Fatura atual',
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            Formatters.moeda(
                              dados.total,
                            ),
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                child: _InfoItem(
                                  titulo: 'Fechamento',
                                  valor:
                                      'Dia ${cartao.fechamento}',
                                ),
                              ),
                              Expanded(
                                child: _InfoItem(
                                  titulo: 'Vencimento',
                                  valor:
                                      'Dia ${cartao.vencimento}',
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          Container(
                            width: double.infinity,
                            padding:
                                const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(12),
                              color: dados.fatura.paga
                                  ? Colors.green.withValues(
                                      alpha: 0.1,
                                    )
                                  : Colors.orange.withValues(
                                      alpha: 0.1,
                                    ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  dados.fatura.paga
                                      ? Icons.check_circle
                                      : Icons.schedule,
                                  color: dados.fatura.paga
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  dados.fatura.paga
                                      ? 'Fatura paga'
                                      : 'Fatura em aberto',
                                  style: TextStyle(
                                    fontWeight:
                                        FontWeight.bold,
                                    color: dados.fatura.paga
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        DetalhesFaturaPage(
                                      fatura: dados.fatura,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.receipt_long,
                              ),
                              label: const Text(
                                'Ver fatura',
                              ),
                            ),
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

  Future<_DadosFatura> _carregarFatura(
    int cartaoId,
    _Referencia referencia,
  ) async {
    var fatura =
        await faturaRepository
            .buscarPorCartaoEReferencia(
      cartaoId: cartaoId,
      mes: referencia.mes,
      ano: referencia.ano,
    );

    if (fatura == null) {
      final id = await faturaRepository.criar(
        cartaoId: cartaoId,
        mes: referencia.mes,
        ano: referencia.ano,
      );

      fatura =
          await faturaRepository.buscarPorId(id);
    }

    if (fatura == null) {
      throw Exception(
        'Não foi possível criar a fatura.',
      );
    }

    final total =
        await faturaRepository.calcularTotal(
      fatura.id,
    );

    return _DadosFatura(
      fatura: fatura,
      total: total,
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

class _InfoItem extends StatelessWidget {
  final String titulo;
  final String valor;

  const _InfoItem({
    required this.titulo,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: TextStyle(
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          valor,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}