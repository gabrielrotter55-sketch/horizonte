import 'package:flutter/material.dart';
import 'pagar_fatura_page.dart';

import '../../../database/app_database.dart';
import '../../../database/database_service.dart';
import '../../../repositories/fatura_repository.dart';
import '../../../shared/utils/formatters.dart';

class DetalhesFaturaPage extends StatefulWidget {
  final Fatura fatura;

  const DetalhesFaturaPage({
    super.key,
    required this.fatura,
  });

  @override
  State<DetalhesFaturaPage> createState() =>
      _DetalhesFaturaPageState();
}

class _DetalhesFaturaPageState
    extends State<DetalhesFaturaPage> {
  final _faturaRepository = FaturaRepository(
    DatabaseService.instance.database,
  );

  late Future<_DadosDetalhes> _dadosFuture;

  @override
  void initState() {
    super.initState();
    _dadosFuture = _carregarDados();
  }

  Future<_DadosDetalhes> _carregarDados() async {
    final cartao = await (DatabaseService
            .instance.database
            .select(
              DatabaseService.instance.database.cartoes,
            )
          ..where(
            (t) => t.id.equals(widget.fatura.cartaoId),
          ))
        .getSingle();

    final lancamentos =
        await _faturaRepository.buscarLancamentos(
      widget.fatura.id,
    );

    final total =
        await _faturaRepository.calcularTotal(
      widget.fatura.id,
    );

    return _DadosDetalhes(
      cartao: cartao,
      lancamentos: lancamentos,
      total: total,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da fatura'),
      ),
      body: FutureBuilder<_DadosDetalhes>(
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
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Erro ao carregar a fatura:\n'
                  '${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Text(
                'Não foi possível carregar a fatura.',
              ),
            );
          }

          final dados = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
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
                                dados.cartao.nome,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        const Text(
                          'Total da fatura',
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
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 20),

                        Row(
                          children: [
                            Expanded(
                              child: _InfoItem(
                                titulo: 'Fechamento',
                                valor:
                                    'Dia ${dados.cartao.fechamento}',
                              ),
                            ),
                            Expanded(
                              child: _InfoItem(
                                titulo: 'Vencimento',
                                valor:
                                    'Dia ${dados.cartao.vencimento}',
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        Container(
                          width: double.infinity,
                          padding:
                              const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(12),
                            color: widget.fatura.paga
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
                                widget.fatura.paga
                                    ? Icons.check_circle
                                    : Icons.schedule,
                                color: widget.fatura.paga
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                widget.fatura.paga
                                    ? 'Fatura paga'
                                    : 'Fatura em aberto',
                                style: TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                  color:
                                      widget.fatura.paga
                                          ? Colors.green
                                          : Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'Lançamentos',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                if (dados.lancamentos.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(
                        child: Text(
                          'Nenhum lançamento nesta fatura.',
                        ),
                      ),
                    ),
                  ),

                ...dados.lancamentos.map(
                  (lancamento) {
                    return Card(
                      margin: const EdgeInsets.only(
                        bottom: 8,
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(
                            Icons.shopping_bag_outlined,
                          ),
                        ),
                        title: Text(
                          lancamento.descricao,
                        ),
                        subtitle: Text(
                          _formatarData(
                            lancamento.data,
                          ),
                        ),
                        trailing: Text(
                          Formatters.moeda(
                            lancamento.valor,
                          ),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                if (!widget.fatura.paga)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () async {
                        final resultado =
                            await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                PagarFaturaPage(
                              fatura: widget.fatura,
                              valor: dados.total,
                            ),
                          ),
                        );

                        if (resultado == true &&
                            mounted) {
                          setState(() {
                            _dadosFuture =
                                _carregarDados();
                          });
                        }
                      },
                      icon: const Icon(
                        Icons.payments_outlined,
                      ),
                      label: const Text(
                        'Pagar fatura',
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

  String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final ano = data.year.toString();

    return '$dia/$mes/$ano';
  }
}

class _DadosDetalhes {
  final Cartoe cartao;
  final List<Lancamento> lancamentos;
  final double total;

  const _DadosDetalhes({
    required this.cartao,
    required this.lancamentos,
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