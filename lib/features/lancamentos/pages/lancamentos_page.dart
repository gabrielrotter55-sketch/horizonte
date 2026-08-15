import 'package:flutter/material.dart';

import '../../../database/app_database.dart';
import '../../../database/database_service.dart';
import '../../../repositories/lancamento_repository.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_spacing.dart';
import '../../../shared/utils/formatters.dart';
import 'novo_lancamento_page.dart';

class LancamentosPage extends StatelessWidget {
  LancamentosPage({super.key});

  final repository = LancamentoRepository(
    DatabaseService.instance.database,
  );

  Future<void> _confirmarExclusao(
    BuildContext context,
    int id,
    String descricao,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Excluir lançamento?'),
          content: Text(
            'Tem certeza que deseja excluir "$descricao"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmar == true) {
      await repository.excluir(id);
    }
  }

  String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final ano = data.year.toString();

    return '$dia/$mes/$ano';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lançamentos'),
      ),
      body: StreamBuilder(
        stream: repository.observar(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final lancamentos = snapshot.data!;

          if (lancamentos.isEmpty) {
            return _EstadoVazio(
              onAdicionar: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const NovoLancamentoPage(),
                  ),
                );
              },
            );
          }

          final ordenados =
              List<Lancamento>.from(lancamentos)
                ..sort(
                  (a, b) => b.data.compareTo(a.data),
                );

          final grupos = <String, List<Lancamento>>{};

          for (final lancamento in ordenados) {
            final chave =
                '${lancamento.data.year}-'
                '${lancamento.data.month.toString().padLeft(2, '0')}';

            grupos.putIfAbsent(
              chave,
              () => <Lancamento>[],
            ).add(lancamento);
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              100,
            ),
            children: [
              const Text(
                'Movimentações',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: AppSpacing.xs),

              Text(
                '${lancamentos.length} '
                '${lancamentos.length == 1 ? 'lançamento' : 'lançamentos'}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              for (final entrada in grupos.entries) ...[
                _MesLancamentosHeader(
                  mes: _formatarMesAno(
                    entrada.value.first.data,
                  ),
                  quantidade: entrada.value.length,
                ),

                const SizedBox(height: AppSpacing.sm),

                ...entrada.value.map(
                  (lancamento) {
                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppSpacing.sm,
                      ),
                      child: _LancamentoCard(
                        descricao: lancamento.descricao,
                        valor: lancamento.valor,
                        receita: lancamento.receita,
                        data: _formatarData(
                          lancamento.data,
                        ),
                        onEditar: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  NovoLancamentoPage(
                                lancamento: lancamento,
                              ),
                            ),
                          );
                        },
                        onExcluir: () {
                          _confirmarExclusao(
                            context,
                            lancamento.id,
                            lancamento.descricao,
                          );
                        },
                      ),
                    );
                  },
                ),

                const SizedBox(height: AppSpacing.md),
              ],
            ],
          );
        },
      ),
      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const NovoLancamentoPage(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Novo lançamento'),
      ),
    );
  }
}

// =====================================================
// CABEÇALHO DO MÊS
// =====================================================

class _MesLancamentosHeader extends StatelessWidget {
  final String mes;
  final int quantidade;

  const _MesLancamentosHeader({
    required this.mes,
    required this.quantidade,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            mes,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Text(
          '$quantidade '
          '${quantidade == 1 ? 'lançamento' : 'lançamentos'}',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

String _formatarMesAno(DateTime data) {
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

  return '${meses[data.month - 1]} ${data.year}';
}

// =====================================================
// CARD DO LANÃ‡AMENTO
// =====================================================

class _LancamentoCard extends StatelessWidget {
  final String descricao;
  final double valor;
  final bool receita;
  final String data;
  final VoidCallback onEditar;
  final VoidCallback onExcluir;

  const _LancamentoCard({
    required this.descricao,
    required this.valor,
    required this.receita,
    required this.data,
    required this.onEditar,
    required this.onExcluir,
  });

  @override
  Widget build(BuildContext context) {
    final corIcone = receita
        ? AppColors.success
        : AppColors.primary;

    final corFundoIcone = receita
        ? AppColors.success.withValues(alpha: 0.10)
        : AppColors.primaryLight;

    final corValor = receita
        ? AppColors.success
        : AppColors.textPrimary;

    return Container(
      width: double.infinity,
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
      child: Row(
        children: [
          // Ícone
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: corFundoIcone,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              receita
                  ? Icons.arrow_downward
                  : Icons.arrow_upward,
              color: corIcone,
              size: 21,
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          // Informações
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  descricao,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  receita ? 'Receita' : 'Despesa',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  data,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: AppSpacing.sm),

          // Valor + ações
          Column(
            crossAxisAlignment:
                CrossAxisAlignment.end,
            children: [
              Text(
                Formatters.moeda(valor),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: corValor,
                ),
              ),

              const SizedBox(height: 4),

              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ActionButton(
                    icon: Icons.edit_outlined,
                    tooltip: 'Editar',
                    onPressed: onEditar,
                  ),
                  _ActionButton(
                    icon: Icons.delete_outline,
                    tooltip: 'Excluir',
                    onPressed: onExcluir,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =====================================================
// BOTÕES DE AÇÃO
// =====================================================

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(
        icon,
        size: 19,
      ),
      color: AppColors.textSecondary,
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.all(6),
      constraints: const BoxConstraints(
        minWidth: 32,
        minHeight: 32,
      ),
    );
  }
}

// =====================================================
// ESTADO VAZIO
// =====================================================

class _EstadoVazio extends StatelessWidget {
  final VoidCallback onAdicionar;

  const _EstadoVazio({
    required this.onAdicionar,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                color: AppColors.primary,
                size: 30,
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            const Text(
              'Nenhum lançamento cadastrado',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: AppSpacing.xs),

            const Text(
              'Adicione uma receita ou despesa para começar.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            FilledButton.icon(
              onPressed: onAdicionar,
              icon: const Icon(Icons.add),
              label: const Text('Novo lançamento'),
            ),
          ],
        ),
      ),
    );
  }
}