import 'package:flutter/material.dart';

import '../../database/app_database.dart';
import '../../database/database_service.dart';
import '../../repositories/cartao_repository.dart';
import '../../repositories/conta_repository.dart';
import '../../repositories/fatura_repository.dart';
import '../../repositories/lancamento_repository.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_spacing.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/utils/formatters.dart';
import '../cartoes/pages/cartoes_page.dart';
import '../categorias/pages/categorias_page.dart';
import '../contas/pages/contas_page.dart';
import '../faturas/pages/faturas_page.dart';
import 'historico_financeiro_page.dart';
import '../lancamentos/pages/lancamentos_page.dart';

class DashboardPage extends StatefulWidget {
  final ValueNotifier<int>? refreshNotifier;

  const DashboardPage({
    super.key,
    this.refreshNotifier,
  });

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

  final _faturaRepository = FaturaRepository(
    DatabaseService.instance.database,
  );

  late Future<_DashboardData> _dadosFuture;

  @override
  void initState() {
    super.initState();
    _dadosFuture = _carregarDados();
    widget.refreshNotifier?.addListener(_onRefreshRequested);
  }

  @override
  void dispose() {
    widget.refreshNotifier?.removeListener(_onRefreshRequested);
    super.dispose();
  }

  void _onRefreshRequested() {
    if (!mounted) {
      return;
    }

    _atualizar();
  }

  Future<_DashboardData> _carregarDados() async {
    final contas = await _contaRepository.buscarTodas();

    double patrimonio = 0;

    for (final conta in contas) {
      patrimonio += await _contaRepository.saldoAtual(conta.id);
    }

    final lancamentos =
        await _lancamentoRepository.buscarTodas();

    final agora = DateTime.now();

    final resumoMensal =
        await _lancamentoRepository.resumoMensal(
      mes: agora.month,
      ano: agora.year,
    );

    final receitasMes = resumoMensal.receitas;
    final despesasMes = resumoMensal.despesas;

    final historicoMensal =
        await _lancamentoRepository.historicoMensal(
      quantidade: 6,
      referencia: agora,
    );

    final cartoes = await _cartaoRepository.buscarTodas();

    final proximasFaturas = <_FaturaDashboard>[];

    for (final cartao in cartoes) {
      final referencia = _proximaReferenciaFatura(
        agora,
        cartao.fechamento,
      );

      var fatura =
          await _faturaRepository.buscarPorCartaoEReferencia(
        cartaoId: cartao.id,
        mes: referencia.mes,
        ano: referencia.ano,
      );

      if (fatura == null) {
        final id = await _faturaRepository.criar(
          cartaoId: cartao.id,
          mes: referencia.mes,
          ano: referencia.ano,
        );

        fatura = await _faturaRepository.buscarPorId(id);
      }

      if (fatura == null) {
        continue;
      }

      final valorRestante =
          await _faturaRepository.calcularValorRestante(
        fatura.id,
      );

      proximasFaturas.add(
        _FaturaDashboard(
          cartao: cartao.nome,
          mes: _nomeReferenciaFatura(
            referencia.mes,
            referencia.ano,
          ),
          valor: valorRestante,
          fatura: fatura,
        ),
      );
    }

    final gastosCalculados =
        await _lancamentoRepository.gastosPorCategoria(
      mes: agora.month,
      ano: agora.year,
    );

    final gastosCategoria = gastosCalculados
        .map(
          (item) => _CategoriaGasto(
            nome: item.categoria,
            valor: item.valor,
          ),
        )
        .take(5)
        .toList();

    final ultimosLancamentos =
        List<Lancamento>.from(lancamentos);

    ultimosLancamentos.sort(
      (a, b) => b.data.compareTo(a.data),
    );

    final cincoUltimos =
        ultimosLancamentos.take(5).toList();

    return _DashboardData(
      patrimonio: patrimonio,
      receitasMes: receitasMes,
      despesasMes: despesasMes,
      taxaEconomia: resumoMensal.taxaEconomia,
      historicoMensal: historicoMensal,
      quantidadeContas: contas.length,
      quantidadeCartoes: cartoes.length,
      ultimosLancamentos: cincoUltimos,
      gastosPorCategoria: gastosCategoria,
      proximasFaturas: proximasFaturas,
    );
  }

  Future<void> _atualizar() async {
    setState(() {
      _dadosFuture = _carregarDados();
    });

    await _dadosFuture;
  }

  _ReferenciaFatura _proximaReferenciaFatura(
    DateTime data,
    int diaFechamento,
  ) {
    if (data.day <= diaFechamento) {
      if (data.month == 12) {
        return _ReferenciaFatura(
          mes: 1,
          ano: data.year + 1,
        );
      }

      return _ReferenciaFatura(
        mes: data.month + 1,
        ano: data.year,
      );
    }

    if (data.month == 11) {
      return _ReferenciaFatura(
        mes: 1,
        ano: data.year + 1,
      );
    }

    if (data.month == 12) {
      return _ReferenciaFatura(
        mes: 2,
        ano: data.year + 1,
      );
    }

    return _ReferenciaFatura(
      mes: data.month + 2,
      ano: data.year,
    );
  }

  String _nomeReferenciaFatura(
    int mes,
    int ano,
  ) {
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

    return '${meses[mes - 1]}/$ano';
  }

  String _saudacao() {
    final hora = DateTime.now().hour;

    if (hora < 12) {
      return 'Bom dia';
    }

    if (hora < 18) {
      return 'Boa tarde';
    }

    return 'Boa noite';
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
                  Text(
                    '${_saudacao()}, Gabriel 👋',
                    style: AppTextStyles.title,
                  ),
                  const SizedBox(
                    height: AppSpacing.xs,
                  ),
                  const Text(
                    'Vamos conferir como estão suas finanças hoje.',
                    style: AppTextStyles.subtitle,
                  ),
                  const SizedBox(
                    height: AppSpacing.lg,
                  ),
                  _PatrimonioCard(
                    patrimonio: dados.patrimonio,
                    quantidadeContas:
                        dados.quantidadeContas,
                  ),
                  const SizedBox(
                    height: AppSpacing.md,
                  ),
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
                  const SizedBox(
                    height: AppSpacing.md,
                  ),
                  _ResultadoCard(
                    valor: resultadoMes,
                    taxaEconomia: dados.taxaEconomia,
                  ),
                  const SizedBox(
                    height: AppSpacing.lg,
                  ),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Evolução financeira',
                          style: AppTextStyles.cardTitle,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const HistoricoFinanceiroPage(),
                            ),
                          );
                        },
                        child: const Text('Ver mais'),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: AppSpacing.sm,
                  ),
                  _HistoricoMensalCard(
                    historico: dados.historicoMensal.isEmpty
                        ? const []
                        : [dados.historicoMensal.first],
                  ),
                  const SizedBox(
                    height: AppSpacing.lg,
                  ),
                  const Text(
                    'Organização',
                    style: AppTextStyles.cardTitle,
                  ),
                  const SizedBox(
                    height: AppSpacing.sm,
                  ),
                  _AcessoCard(
                    icon:
                        Icons.account_balance_outlined,
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
                  const SizedBox(
                    height: AppSpacing.sm,
                  ),
                  _AcessoCard(
                    icon: Icons.credit_card_outlined,
                    titulo: 'Cartões',
                    descricao:
                        '${dados.quantidadeCartoes} '
                        '${dados.quantidadeCartoes == 1 ? 'cartão' : 'cartões'} '
                        '${dados.quantidadeCartoes == 1 ? 'cadastrado' : 'cadastrados'}',
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
                  const SizedBox(
                    height: AppSpacing.sm,
                  ),
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
                  const SizedBox(
                    height: AppSpacing.lg,
                  ),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Últimos lançamentos',
                          style:
                              AppTextStyles.cardTitle,
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  LancamentosPage(),
                            ),
                          );

                          if (mounted) {
                            _atualizar();
                          }
                        },
                        child: const Text(
                          'Ver todos',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: AppSpacing.xs,
                  ),
                  if (dados.ultimosLancamentos.isEmpty)
                    const _LancamentosVazio()
                  else
                    _UltimosLancamentosCard(
                      lancamentos:
                          dados.ultimosLancamentos,
                    ),
                  const SizedBox(
                    height: AppSpacing.lg,
                  ),
                  const Text(
                    'Gastos por categoria',
                    style: AppTextStyles.cardTitle,
                  ),
                  const SizedBox(
                    height: AppSpacing.sm,
                  ),
                  if (dados.gastosPorCategoria.isEmpty)
                    const _CategoriasVazio()
                  else
                    _GastosCategoriaCard(
                      categorias:
                          dados.gastosPorCategoria,
                      totalDespesas:
                          dados.despesasMes,
                    ),
                  const SizedBox(
                    height: AppSpacing.lg,
                  ),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Faturas',
                          style:
                              AppTextStyles.cardTitle,
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const FaturasPage(),
                            ),
                          );

                          if (mounted) {
                            _atualizar();
                          }
                        },
                        child: const Text(
                          'Ver todas',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: AppSpacing.sm,
                  ),
                  if (dados.proximasFaturas.isEmpty)
                    const _FaturasVazio()
                  else
                    _ProximasFaturasCard(
                      faturas:
                          dados.proximasFaturas,
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const FaturasPage(),
                          ),
                        );

                        if (mounted) {
                          _atualizar();
                        }
                      },
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
      padding: const EdgeInsets.all(
        AppSpacing.lg,
      ),
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
                  Icons
                      .account_balance_wallet_outlined,
                  color: AppColors.primary,
                  size: 21,
                ),
              ),
              const SizedBox(
                width: AppSpacing.sm,
              ),
              const Text(
                'Seu patrimônio',
                style:
                    AppTextStyles.cardTitle,
              ),
            ],
          ),
          const SizedBox(
            height: AppSpacing.md,
          ),
          Text(
            Formatters.moeda(patrimonio),
            style: AppTextStyles.value,
          ),
          const SizedBox(
            height: AppSpacing.xs,
          ),
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
      padding: const EdgeInsets.all(
        AppSpacing.md,
      ),
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
                    fontWeight:
                        FontWeight.w600,
                    color:
                        AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: AppSpacing.sm,
          ),
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

class _ResultadoCard extends StatelessWidget {
  final double valor;
  final double taxaEconomia;

  const _ResultadoCard({
    required this.valor,
    required this.taxaEconomia,
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
                  ? AppColors.success
                      .withValues(alpha: 0.10)
                  : AppColors.danger
                      .withValues(alpha: 0.10),
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
          const SizedBox(
            width: AppSpacing.sm,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Resultado do mês',
                  style: TextStyle(
                    fontSize: 13,
                    color:
                        AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  Formatters.moeda(valor),
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight:
                        FontWeight.bold,
                    color:
                        AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: positivo
                  ? AppColors.success.withValues(alpha: 0.10)
                  : AppColors.danger.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'Economia',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${(taxaEconomia * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: positivo
                        ? AppColors.success
                        : AppColors.danger,
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


class _HistoricoMensalCard extends StatelessWidget {
  final List<HistoricoMensal> historico;

  const _HistoricoMensalCard({
    required this.historico,
  });

  @override
  Widget build(BuildContext context) {
    if (historico.isEmpty) {
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
        child: const Text(
          'Ainda não existem dados para o histórico.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    final item = historico.first;

    final maiorValor = item.resumo.receitas >
            item.resumo.despesas
        ? item.resumo.receitas
        : item.resumo.despesas;

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
      child: _HistoricoMensalItem(
        item: item,
        maiorValor: maiorValor,
        destaque: true,
      ),
    );
  }
}

class _HistoricoMensalItem extends StatelessWidget {
  final HistoricoMensal item;
  final double maiorValor;
  final bool destaque;

  const _HistoricoMensalItem({
    required this.item,
    required this.maiorValor,
    required this.destaque,
  });

  @override
  Widget build(BuildContext context) {
    final receitas = item.resumo.receitas;
    final despesas = item.resumo.despesas;

    final larguraReceita = maiorValor > 0
        ? (receitas / maiorValor).clamp(0.0, 1.0)
        : 0.0;

    final larguraDespesa = maiorValor > 0
        ? (despesas / maiorValor).clamp(0.0, 1.0)
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '${_nomeMes(item.mes)} ${item.ano}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight:
                      destaque ? FontWeight.w700 : FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Text(
              Formatters.moeda(item.resumo.resultado),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: item.resumo.resultado > 0
                    ? AppColors.success
                    : item.resumo.resultado < 0
                        ? AppColors.danger
                        : AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _HistoricoBarra(
          valor: receitas,
          percentual: larguraReceita,
          cor: AppColors.success,
          legenda: 'Receitas',
        ),
        const SizedBox(height: 5),
        _HistoricoBarra(
          valor: despesas,
          percentual: larguraDespesa,
          cor: AppColors.danger,
          legenda: 'Despesas',
        ),
      ],
    );
  }

  String _nomeMes(int mes) {
    const meses = [
      'Jan',
      'Fev',
      'Mar',
      'Abr',
      'Mai',
      'Jun',
      'Jul',
      'Ago',
      'Set',
      'Out',
      'Nov',
      'Dez',
    ];

    return meses[mes - 1];
  }
}

class _HistoricoBarra extends StatelessWidget {
  final double valor;
  final double percentual;
  final Color cor;
  final String legenda;

  const _HistoricoBarra({
    required this.valor,
    required this.percentual,
    required this.cor,
    required this.legenda,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 52,
          child: Text(
            legenda,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              children: [
                Container(
                  height: 7,
                  color: AppColors.primaryLight,
                ),
                FractionallySizedBox(
                  widthFactor: percentual,
                  child: Container(
                    height: 7,
                    decoration: BoxDecoration(
                      color: cor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 82,
          child: Text(
            Formatters.moeda(valor),
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

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
            borderRadius:
                BorderRadius.circular(16),
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
              const SizedBox(
                width: AppSpacing.md,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.w600,
                        color:
                            AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Text(
                      descricao,
                      style: const TextStyle(
                        fontSize: 13,
                        color:
                            AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color:
                    AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UltimosLancamentosCard
    extends StatelessWidget {
  final List<Lancamento> lancamentos;

  const _UltimosLancamentosCard({
    required this.lancamentos,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        children: [
          for (int i = 0;
              i < lancamentos.length;
              i++) ...[
            _LancamentoResumo(
              lancamento: lancamentos[i],
            ),
            if (i < lancamentos.length - 1)
              const Divider(
                height: 1,
                indent: 72,
                endIndent: 16,
              ),
          ],
        ],
      ),
    );
  }
}

class _LancamentoResumo extends StatelessWidget {
  final Lancamento lancamento;

  const _LancamentoResumo({
    required this.lancamento,
  });

  @override
  Widget build(BuildContext context) {
    final receita = lancamento.receita;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 12,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: receita
                  ? AppColors.success
                      .withValues(alpha: 0.10)
                  : AppColors.primaryLight,
              borderRadius:
                  BorderRadius.circular(12),
            ),
            child: Icon(
              receita
                  ? Icons.arrow_downward
                  : Icons.arrow_upward,
              color: receita
                  ? AppColors.success
                  : AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(
            width: AppSpacing.md,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  lancamento.descricao,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight:
                        FontWeight.w600,
                    color:
                        AppColors.textPrimary,
                  ),
                ),
                const SizedBox(
                  height: 3,
                ),
                Text(
                  '${receita ? 'Receita' : 'Despesa'} · '
                  '${_formatarData(lancamento.data)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color:
                        AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            width: AppSpacing.sm,
          ),
          Text(
            Formatters.moeda(
              lancamento.valor,
            ),
            style: TextStyle(
              fontSize: 14,
              fontWeight:
                  FontWeight.bold,
              color: receita
                  ? AppColors.success
                  : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatarData(DateTime data) {
    final dia =
        data.day.toString().padLeft(2, '0');
    final mes =
        data.month.toString().padLeft(2, '0');

    return '$dia/$mes/${data.year}';
  }
}

class _LancamentosVazio
    extends StatelessWidget {
  const _LancamentosVazio();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: const Text(
        'Nenhum lançamento cadastrado.',
        style: TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _GastosCategoriaCard
    extends StatelessWidget {
  final List<_CategoriaGasto> categorias;
  final double totalDespesas;

  const _GastosCategoriaCard({
    required this.categorias,
    required this.totalDespesas,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        children: [
          for (int i = 0;
              i < categorias.length;
              i++) ...[
            _CategoriaGastoItem(
              categoria: categorias[i],
              totalDespesas: totalDespesas,
            ),
            if (i < categorias.length - 1)
              const SizedBox(
                height: AppSpacing.md,
              ),
          ],
        ],
      ),
    );
  }
}

class _CategoriaGastoItem
    extends StatelessWidget {
  final _CategoriaGasto categoria;
  final double totalDespesas;

  const _CategoriaGastoItem({
    required this.categoria,
    required this.totalDespesas,
  });

  @override
  Widget build(BuildContext context) {
    final percentual = totalDespesas > 0
        ? categoria.valor / totalDespesas
        : 0.0;

    final percentualSeguro =
        percentual.clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                categoria.nome,
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight:
                      FontWeight.w600,
                  color:
                      AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(
              width: AppSpacing.sm,
            ),
            Text(
              Formatters.moeda(
                categoria.valor,
              ),
              style: const TextStyle(
                fontSize: 14,
                fontWeight:
                    FontWeight.bold,
                color:
                    AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 7,
        ),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: percentualSeguro,
                  minHeight: 7,
                  backgroundColor:
                      AppColors.primaryLight,
                  valueColor:
                      const AlwaysStoppedAnimation<
                          Color>(
                    AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: AppSpacing.sm,
            ),
            SizedBox(
              width: 42,
              child: Text(
                '${(percentual * 100).round()}%',
                textAlign:
                    TextAlign.right,
                style: const TextStyle(
                  fontSize: 12,
                  color:
                      AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CategoriasVazio
    extends StatelessWidget {
  const _CategoriasVazio();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: const Text(
        'Ainda não existem despesas neste mês.',
        style: TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _ProximasFaturasCard
    extends StatelessWidget {
  final List<_FaturaDashboard> faturas;
  final VoidCallback onTap;

  const _ProximasFaturasCard({
    required this.faturas,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        children: [
          for (int i = 0;
              i < faturas.length;
              i++) ...[
            InkWell(
              onTap: onTap,
              borderRadius:
                  BorderRadius.circular(16),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 13,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration:
                          BoxDecoration(
                        color:
                            AppColors.primaryLight,
                        borderRadius:
                            BorderRadius.circular(
                          12,
                        ),
                      ),
                      child: const Icon(
                        Icons
                            .credit_card_outlined,
                        color:
                            AppColors.primary,
                        size: 21,
                      ),
                    ),
                    const SizedBox(
                      width: AppSpacing.md,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Text(
                            faturas[i].cartao,
                            maxLines: 1,
                            overflow:
                                TextOverflow
                                    .ellipsis,
                            style:
                                const TextStyle(
                              fontSize: 15,
                              fontWeight:
                                  FontWeight.w600,
                              color: AppColors
                                  .textPrimary,
                            ),
                          ),
                          const SizedBox(
                            height: 3,
                          ),
                          Text(
                            'Próxima fatura · '
                            '${faturas[i].mes}',
                            style:
                                const TextStyle(
                              fontSize: 12,
                              color: AppColors
                                  .textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: AppSpacing.sm,
                    ),
                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.end,
                      children: [
                        Text(
                          Formatters.moeda(
                            faturas[i].valor,
                          ),
                          style:
                              const TextStyle(
                            fontSize: 14,
                            fontWeight:
                                FontWeight.bold,
                            color: AppColors
                                .textPrimary,
                          ),
                        ),
                        const SizedBox(
                          height: 2,
                        ),
                        const Icon(
                          Icons.chevron_right,
                          size: 20,
                          color: AppColors
                              .textSecondary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (i < faturas.length - 1)
              const Divider(
                height: 1,
                indent: 72,
                endIndent: 16,
              ),
          ],
        ],
      ),
    );
  }
}

class _FaturasVazio
    extends StatelessWidget {
  const _FaturasVazio();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: const Text(
        'Nenhuma fatura encontrada.',
        style: TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _CategoriaGasto {
  final String nome;
  final double valor;

  const _CategoriaGasto({
    required this.nome,
    required this.valor,
  });
}

class _FaturaDashboard {
  final String cartao;
  final String mes;
  final double valor;
  final Fatura fatura;

  const _FaturaDashboard({
    required this.cartao,
    required this.mes,
    required this.valor,
    required this.fatura,
  });
}

class _ReferenciaFatura {
  final int mes;
  final int ano;

  const _ReferenciaFatura({
    required this.mes,
    required this.ano,
  });
}

class _DashboardData {
  final double patrimonio;
  final double receitasMes;
  final double despesasMes;
  final double taxaEconomia;
  final List<HistoricoMensal> historicoMensal;
  final int quantidadeContas;
  final int quantidadeCartoes;
  final List<Lancamento> ultimosLancamentos;
  final List<_CategoriaGasto> gastosPorCategoria;
  final List<_FaturaDashboard> proximasFaturas;

  const _DashboardData({
    required this.patrimonio,
    required this.receitasMes,
    required this.despesasMes,
    required this.taxaEconomia,
    required this.historicoMensal,
    required this.quantidadeContas,
    required this.quantidadeCartoes,
    required this.ultimosLancamentos,
    required this.gastosPorCategoria,
    required this.proximasFaturas,
  });
}