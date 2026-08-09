import 'package:flutter/material.dart';

import '../../database/database_service.dart';
import '../../repositories/cartao_repository.dart';
import '../../repositories/conta_repository.dart';
import '../../repositories/lancamento_repository.dart';
import '../../shared/utils/formatters.dart';
import '../../shared/widgets/dashboard_tile.dart';
import '../../shared/widgets/info_card.dart';
import '../cartoes/pages/cartoes_page.dart';
import '../categorias/pages/categorias_page.dart';
import '../contas/pages/contas_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _contaRepository = ContaRepository(
    DatabaseService.instance.database,
  );

  final _lancamentoRepository = LancamentoRepository(
    DatabaseService.instance.database,
  );

  final _cartaoRepository = CartaoRepository(
    DatabaseService.instance.database,
  );

  late Future<_DashboardData> _dadosFuture;

  @override
  void initState() {
    super.initState();
    _dadosFuture = _carregarDados();
  }

  Future<_DashboardData> _carregarDados() async {
    final contas = await _contaRepository.buscarTodas();

    double patrimonio = 0;

    for (final conta in contas) {
      patrimonio += await _contaRepository.saldoAtual(
        conta.id,
      );
    }

    final lancamentos =
        await _lancamentoRepository.buscarTodas();

    final agora = DateTime.now();

    final inicioDoMes = DateTime(
      agora.year,
      agora.month,
      1,
    );

    final fimDoMes = DateTime(
      agora.year,
      agora.month + 1,
      1,
    );

    double receitasMes = 0;
    double despesasMes = 0;

    for (final lancamento in lancamentos) {
      if (!lancamento.data.isBefore(inicioDoMes) &&
          lancamento.data.isBefore(fimDoMes)) {
        if (lancamento.receita) {
          receitasMes += lancamento.valor;
        } else {
          despesasMes += lancamento.valor;
        }
      }
    }

    final cartoes = await _cartaoRepository.buscarTodas();

    return _DashboardData(
      patrimonio: patrimonio,
      receitasMes: receitasMes,
      despesasMes: despesasMes,
      quantidadeContas: contas.length,
      quantidadeCartoes: cartoes.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Horizonte'),
        centerTitle: false,
      ),
      body: FutureBuilder<_DashboardData>(
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
                  'Erro ao carregar o Dashboard:\n'
                  '${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
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

          final resultadoMes =
              dados.receitasMes - dados.despesasMes;

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _dadosFuture = _carregarDados();
              });

              await _dadosFuture;
            },
            child: SingleChildScrollView(
              physics:
                  const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    '👋 Boa noite, Gabriel',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'Vamos conferir como estão suas finanças hoje.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 24),

                  InfoCard(
                    title: '💰 Seu patrimônio',
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          Formatters.moeda(
                            dados.patrimonio,
                          ),
                          style: const TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${dados.quantidadeContas} '
                          '${dados.quantidadeContas == 1 ? 'conta' : 'contas'} cadastradas',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: DashboardTile(
                          icon: Icons.bar_chart,
                          title: 'Resultado do mês',
                          value: Formatters.moeda(
                            resultadoMes,
                          ),
                          color: resultadoMes >= 0
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DashboardTile(
                          icon: Icons.credit_card,
                          title: 'Cartões',
                          value:
                              '${dados.quantidadeCartoes}',
                          color: Colors.deepPurple,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: DashboardTile(
                          icon: Icons.arrow_downward,
                          title: 'Receitas',
                          value: Formatters.moeda(
                            dados.receitasMes,
                          ),
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DashboardTile(
                          icon: Icons.arrow_upward,
                          title: 'Despesas',
                          value: Formatters.moeda(
                            dados.despesasMes,
                          ),
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ContasPage(),
                        ),
                      ).then((_) {
                        if (mounted) {
                          setState(() {
                            _dadosFuture =
                                _carregarDados();
                          });
                        }
                      });
                    },
                    child: const DashboardTile(
                      icon: Icons.account_balance,
                      title: 'Contas',
                      value: 'Gerenciar contas',
                      color: Colors.teal,
                    ),
                  ),

                  const SizedBox(height: 16),

                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CategoriasPage(),
                        ),
                      );
                    },
                    child: const DashboardTile(
                      icon: Icons.category_outlined,
                      title: 'Categorias',
                      value: 'Gerenciar categorias',
                      color: Colors.indigo,
                    ),
                  ),

                  const SizedBox(height: 16),

                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CartoesPage(),
                        ),
                      ).then((_) {
                        if (mounted) {
                          setState(() {
                            _dadosFuture =
                                _carregarDados();
                          });
                        }
                      });
                    },
                    child: const DashboardTile(
                      icon: Icons.credit_card,
                      title: 'Cartões',
                      value: 'Gerenciar cartões',
                      color: Colors.deepPurple,
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Resumo do mês',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  InfoCard(
                    title: 'Movimentações',
                    child: Column(
                      children: [
                        _ResumoLinha(
                          titulo: 'Receitas',
                          valor: Formatters.moeda(
                            dados.receitasMes,
                          ),
                          positivo: true,
                        ),
                        const Divider(),
                        _ResumoLinha(
                          titulo: 'Despesas',
                          valor: Formatters.moeda(
                            dados.despesasMes,
                          ),
                          positivo: false,
                        ),
                        const Divider(),
                        _ResumoLinha(
                          titulo: 'Resultado',
                          valor: Formatters.moeda(
                            resultadoMes,
                          ),
                          positivo: resultadoMes >= 0,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ResumoLinha extends StatelessWidget {
  final String titulo;
  final String valor;
  final bool positivo;

  const _ResumoLinha({
    required this.titulo,
    required this.valor,
    required this.positivo,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 6,
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Text(titulo),
          Text(
            valor,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: positivo
                  ? Colors.green
                  : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardData {
  final double patrimonio;
  final double receitasMes;
  final double despesasMes;
  final int quantidadeContas;
  final int quantidadeCartoes;

  const _DashboardData({
    required this.patrimonio,
    required this.receitasMes,
    required this.despesasMes,
    required this.quantidadeContas,
    required this.quantidadeCartoes,
  });
}