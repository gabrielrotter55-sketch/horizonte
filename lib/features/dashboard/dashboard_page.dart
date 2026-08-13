import 'package:flutter/material.dart';

import '../../database/database_service.dart';
import '../../repositories/cartao_repository.dart';
import '../../repositories/conta_repository.dart';
import '../../repositories/lancamento_repository.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_spacing.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/utils/formatters.dart';
import '../cartoes/pages/cartoes_page.dart';
import '../categorias/pages/categorias_page.dart';
import '../contas/pages/contas_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() =>
      _DashboardPageState();
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

    final cartoes =
        await _cartaoRepository.buscarTodas();

    return _DashboardData(
      patrimonio: patrimonio,
      receitasMes: receitasMes,
      despesasMes: despesasMes,
      quantidadeContas: contas.length,
      quantidadeCartoes: cartoes.length,
    );
  }

  Future<void> _atualizar() async {
    setState(() {
      _dadosFuture = _carregarDados();
    });

    await _dadosFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Horizonte'),
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
                padding: const EdgeInsets.all(
                  AppSpacing.lg,
                ),
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
            onRefresh: _atualizar,
            child: SingleChildScrollView(
              physics:
                  const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                100,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // =====================================
                  // SAUDAÇÃO
                  // =====================================

                  const Text(
                    'Boa noite, Gabriel 👋',
                    style: AppTextStyles.title,
                  ),

                  const SizedBox(height: AppSpacing.xs),

                  const Text(
                    'Vamos conferir como estão suas finanças hoje.',
                    style: AppTextStyles.subtitle,
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // =====================================
                  // PATRIMÔNIO
                  // =====================================

                  _PatrimonioCard(
                    patrimonio: dados.patrimonio,
                    quantidadeContas:
                        dados.quantidadeContas,
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // =====================================
                  // RECEITAS / DESPESAS
                  // =====================================

                  Row(
                    children: [
                      Expanded(
                        child: _FinanceiroCard(
                          titulo: 'Receitas',
                          valor: dados.receitasMes,
                          icon: Icons.arrow_downward,
                          cor: AppColors.success,
                        ),
                      ),
                      const SizedBox(
                        width: AppSpacing.sm,
                      ),
                      Expanded(
                        child: _FinanceiroCard(
                          titulo: 'Despesas',
                          valor: dados.despesasMes,
                          icon: Icons.arrow_upward,
                          cor: AppColors.danger,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // =====================================
                  // RESULTADO DO MÊS
                  // =====================================

                  _ResultadoCard(
                    valor: resultadoMes,
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // =====================================
                  // ACESSOS RÁPIDOS
                  // =====================================

                  const Text(
                    'Organização',
                    style: AppTextStyles.cardTitle,
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  _AcessoCard(
                    icon: Icons.account_balance_outlined,
                    titulo: 'Contas',
                    descricao:
                        '${dados.quantidadeContas} '
                        '${dados.quantidadeContas == 1 ? 'conta' : 'contas'} cadastradas',
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ContasPage(),
                        ),
                      );

                      if (mounted) {
                        _atualizar();
                      }
                    },
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  _AcessoCard(
                    icon: Icons.credit_card_outlined,
                    titulo: 'Cartões',
                    descricao:
                        '${dados.quantidadeCartoes} '
                        '${dados.quantidadeCartoes == 1 ? 'cartão' : 'cartões'} cadastrado'
                        '${dados.quantidadeCartoes == 1 ? '' : 's'}',
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CartoesPage(),
                        ),
                      );

                      if (mounted) {
                        _atualizar();
                      }
                    },
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  _AcessoCard(
                    icon: Icons.category_outlined,
                    titulo: 'Categorias',
                    descricao:
                        'Organize seus lançamentos',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              CategoriasPage(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // =====================================
                  // RESUMO
                  // =====================================

                  const Text(
                    'Resumo do mês',
                    style: AppTextStyles.cardTitle,
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  _ResumoCard(
                    receitas: dados.receitasMes,
                    despesas: dados.despesasMes,
                    resultado: resultadoMes,
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

// =====================================================
// CARD DE PATRIMÔNIO
// =====================================================

class _PatrimonioCard extends StatelessWidget {
  final double patrimonio;
  final int quantidadeContas;

  const _PatrimonioCard({
    required this.patrimonio,
    required this.quantidadeContas,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: AppColors.primary,
                  size: 21,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Text(
                'Seu patrimônio',
                style: AppTextStyles.cardTitle,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          Text(
            Formatters.moeda(patrimonio),
            style: AppTextStyles.value,
          ),

          const SizedBox(height: AppSpacing.xs),

          Text(
            '$quantidadeContas '
            '${quantidadeContas == 1 ? 'conta cadastrada' : 'contas cadastradas'}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// RECEITAS / DESPESAS
// =====================================================

class _FinanceiroCard extends StatelessWidget {
  final String titulo;
  final double valor;
  final IconData icon;
  final Color cor;

  const _FinanceiroCard({
    required this.titulo,
    required this.valor,
    required this.icon,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: cor,
                size: 21,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          Text(
            Formatters.moeda(valor),
            style: AppTextStyles.smallValue,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// =====================================================
// RESULTADO
// =====================================================

class _ResultadoCard extends StatelessWidget {
  final double valor;

  const _ResultadoCard({
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    final positivo = valor >= 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: positivo
                  ? AppColors.success.withValues(
                      alpha: 0.10,
                    )
                  : AppColors.danger.withValues(
                      alpha: 0.10,
                    ),
              borderRadius:
                  BorderRadius.circular(12),
            ),
            child: Icon(
              positivo
                  ? Icons.trending_up
                  : Icons.trending_down,
              color: positivo
                  ? AppColors.success
                  : AppColors.danger,
            ),
          ),

          const SizedBox(width: AppSpacing.sm),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Resultado do mês',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  Formatters.moeda(valor),
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// ACESSO RÁPIDO
// =====================================================

class _AcessoCard extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String descricao;
  final VoidCallback onTap;

  const _AcessoCard({
    required this.icon,
    required this.titulo,
    required this.descricao,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 21,
                ),
              ),

              const SizedBox(width: AppSpacing.md),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      descricao,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================
// RESUMO
// =====================================================

class _ResumoCard extends StatelessWidget {
  final double receitas;
  final double despesas;
  final double resultado;

  const _ResumoCard({
    required this.receitas,
    required this.despesas,
    required this.resultado,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        children: [
          _ResumoLinha(
            titulo: 'Receitas',
            valor: receitas,
            cor: AppColors.success,
          ),

          const Divider(
            height: 20,
          ),

          _ResumoLinha(
            titulo: 'Despesas',
            valor: despesas,
            cor: AppColors.textPrimary,
          ),

          const Divider(
            height: 20,
          ),

          _ResumoLinha(
            titulo: 'Resultado',
            valor: resultado,
            cor: resultado >= 0
                ? AppColors.success
                : AppColors.danger,
            destaque: true,
          ),
        ],
      ),
    );
  }
}

class _ResumoLinha extends StatelessWidget {
  final String titulo;
  final double valor;
  final Color cor;
  final bool destaque;

  const _ResumoLinha({
    required this.titulo,
    required this.valor,
    required this.cor,
    this.destaque = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
      children: [
        Text(
          titulo,
          style: TextStyle(
            fontSize: destaque ? 15 : 14,
            fontWeight: destaque
                ? FontWeight.w600
                : FontWeight.normal,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          Formatters.moeda(valor),
          style: TextStyle(
            fontSize: destaque ? 17 : 15,
            fontWeight: FontWeight.bold,
            color: cor,
          ),
        ),
      ],
    );
  }
}

// =====================================================
// DADOS
// =====================================================

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