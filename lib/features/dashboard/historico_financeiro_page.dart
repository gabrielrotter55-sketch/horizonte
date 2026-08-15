import 'package:flutter/material.dart';

import '../../database/database_service.dart';
import '../../repositories/lancamento_repository.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_spacing.dart';
import '../../shared/theme/app_text_styles.dart';
import '../../shared/utils/formatters.dart';

class HistoricoFinanceiroPage extends StatefulWidget {
  const HistoricoFinanceiroPage({super.key});

  @override
  State<HistoricoFinanceiroPage> createState() =>
      _HistoricoFinanceiroPageState();
}

class _HistoricoFinanceiroPageState
    extends State<HistoricoFinanceiroPage> {
  final _repository = LancamentoRepository(
    DatabaseService.instance.database,
  );

  late Future<List<HistoricoMensal>> _historicoFuture;

  @override
  void initState() {
    super.initState();
    _historicoFuture = _carregarHistorico();
  }

  Future<List<HistoricoMensal>> _carregarHistorico() {
    return _repository.historicoMensal(
      quantidade: 12,
    );
  }

  Future<void> _recarregar() async {
    setState(() {
      _historicoFuture = _carregarHistorico();
    });

    await _historicoFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico financeiro'),
      ),
      body: FutureBuilder<List<HistoricoMensal>>(
        future: _historicoFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final historico = snapshot.data!;

          if (historico.isEmpty) {
            return const Center(
              child: Text(
                'Ainda não existem dados financeiros.',
              ),
            );
          }

          final maiorValor = historico.fold<double>(
            0,
            (maior, item) {
              final maiorDoMes = item.resumo.receitas >
                      item.resumo.despesas
                  ? item.resumo.receitas
                  : item.resumo.despesas;

              return maiorDoMes > maior
                  ? maiorDoMes
                  : maior;
            },
          );

          return RefreshIndicator(
            onRefresh: _recarregar,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.xl,
              ),
              children: [
                const Text(
                  'Seus últimos meses',
                  style: AppTextStyles.cardTitle,
                ),
                const SizedBox(
                  height: AppSpacing.xs,
                ),
                const Text(
                  'Acompanhe a evolução das suas finanças.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(
                  height: AppSpacing.md,
                ),
                for (int i = 0; i < historico.length; i++) ...[
                  _HistoricoCompletoCard(
                    item: historico[i],
                    maiorValor: maiorValor,
                    destaque: i == 0,
                  ),
                  if (i < historico.length - 1)
                    const SizedBox(
                      height: AppSpacing.sm,
                    ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HistoricoCompletoCard extends StatelessWidget {
  final HistoricoMensal item;
  final double maiorValor;
  final bool destaque;

  const _HistoricoCompletoCard({
    required this.item,
    required this.maiorValor,
    required this.destaque,
  });

  @override
  Widget build(BuildContext context) {
    final receitas = item.resumo.receitas;
    final despesas = item.resumo.despesas;
    final resultado = item.resumo.resultado;

    final larguraReceita = maiorValor > 0
        ? (receitas / maiorValor).clamp(0.0, 1.0)
        : 0.0;

    final larguraDespesa = maiorValor > 0
        ? (despesas / maiorValor).clamp(0.0, 1.0)
        : 0.0;

    final corResultado = resultado > 0
        ? AppColors.success
        : resultado < 0
            ? AppColors.danger
            : AppColors.textSecondary;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${_nomeMes(item.mes)} ${item.ano}',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: destaque
                        ? FontWeight.w700
                        : FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                Formatters.moeda(resultado),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: corResultado,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: AppSpacing.md,
          ),
          _LinhaFinanceira(
            titulo: 'Receitas',
            valor: receitas,
            percentual: larguraReceita,
            cor: AppColors.success,
          ),
          const SizedBox(height: 8),
          _LinhaFinanceira(
            titulo: 'Despesas',
            valor: despesas,
            percentual: larguraDespesa,
            cor: AppColors.danger,
          ),
          const SizedBox(
            height: AppSpacing.md,
          ),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Resultado',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
              Text(
                Formatters.moeda(resultado),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: corResultado,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Taxa de economia',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
              Text(
                '${(item.resumo.taxaEconomia * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: corResultado,
                ),
              ),
            ],
          ),
        ],
      ),
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
}

class _LinhaFinanceira extends StatelessWidget {
  final String titulo;
  final double valor;
  final double percentual;
  final Color cor;

  const _LinhaFinanceira({
    required this.titulo,
    required this.valor,
    required this.percentual,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 62,
          child: Text(
            titulo,
            style: const TextStyle(
              fontSize: 12,
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
                  height: 8,
                  color: AppColors.primaryLight,
                ),
                FractionallySizedBox(
                  widthFactor: percentual,
                  child: Container(
                    height: 8,
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
          width: 88,
          child: Text(
            Formatters.moeda(valor),
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
