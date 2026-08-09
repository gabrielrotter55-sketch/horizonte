import 'package:flutter/material.dart';

import '../../../database/database_service.dart';
import '../../../repositories/cartao_repository.dart';
import '../../../shared/utils/formatters.dart';
import '../../faturas/pages/faturas_page.dart';
import 'novo_cartao_page.dart';

class CartoesPage extends StatelessWidget {
  CartoesPage({super.key});

  final repository = CartaoRepository(
    DatabaseService.instance.database,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cartões'),
      ),
      body: StreamBuilder(
        stream: repository.observar(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final cartoes = snapshot.data!;

          if (cartoes.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum cartão cadastrado',
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: cartoes.length,
            itemBuilder: (context, index) {
              final cartao = cartoes[index];

              return FutureBuilder<double>(
                future: repository.valorUtilizado(
                  cartao.id,
                ),
                builder: (context, utilizadoSnapshot) {
                  if (!utilizadoSnapshot.hasData) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    );
                  }

                  final utilizado =
                      utilizadoSnapshot.data!;

                  final disponivel =
                      cartao.limite - utilizado;

                  return Card(
                    margin: const EdgeInsets.only(
                      bottom: 12,
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
                              IconButton(
                                tooltip: 'Editar',
                                icon: const Icon(
                                  Icons.edit_outlined,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          NovoCartaoPage(
                                        cartao: cartao,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          Text(
                            'Limite',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                            ),
                          ),

                          Text(
                            Formatters.moeda(
                              cartao.limite,
                            ),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Expanded(
                                child: _InfoItem(
                                  titulo: 'Utilizado',
                                  valor:
                                      Formatters.moeda(
                                    utilizado,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: _InfoItem(
                                  titulo: 'Disponível',
                                  valor:
                                      Formatters.moeda(
                                    disponivel,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          Text(
                            'Fecha dia ${cartao.fechamento} • '
                            'Vence dia ${cartao.vencimento}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
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
                                        FaturasPage(),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.receipt_long_outlined,
                              ),
                              label: const Text(
                                'Ver fatura atual',
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const NovoCartaoPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
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