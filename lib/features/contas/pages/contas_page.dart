import 'package:flutter/material.dart';

import '../../../database/database_service.dart';
import '../../../repositories/conta_repository.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_spacing.dart';
import '../../../shared/utils/formatters.dart';
import 'nova_conta_page.dart';
import 'transferencias_page.dart';

class ContasPage extends StatelessWidget {
  ContasPage({super.key});

  final repository = ContaRepository(
    DatabaseService.instance.database,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contas'),
      ),
      body: StreamBuilder(
        stream: repository.observar(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final contas = snapshot.data!;

          if (contas.isEmpty) {
            return _EstadoVazio(
              onAdicionar: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NovaContaPage(),
                  ),
                );
              },
            );
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
                'Suas contas',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: AppSpacing.xs),

              Text(
                '${contas.length} '
                '${contas.length == 1 ? 'conta cadastrada' : 'contas cadastradas'}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              FutureBuilder<double>(
                future: repository.patrimonioTotal(),
                builder: (context, patrimonioSnapshot) {
                  if (!patrimonioSnapshot.hasData) {
                    return const _PatrimonioCardCarregando();
                  }

                  return _PatrimonioCard(
                    valor: patrimonioSnapshot.data!,
                  );
                },
              ),

              const SizedBox(height: AppSpacing.md),

              ...contas.map(
                (conta) {
                  return Padding(
                    padding: const EdgeInsets.only(
                      bottom: AppSpacing.sm,
                    ),
                    child: FutureBuilder<double>(
                      future: repository.saldoAtual(
                        conta.id,
                      ),
                      builder: (
                        context,
                        saldoSnapshot,
                      ) {
                        if (!saldoSnapshot.hasData) {
                          return _ContaCardCarregando(
                            nome: conta.nome,
                            tipo: conta.tipo,
                          );
                        }

                        final saldo =
                            saldoSnapshot.data!;

                        return _ContaCard(
                          nome: conta.nome,
                          tipo: conta.tipo,
                          saldo: saldo,
                        );
                      },
                    ),
                  );
                },
              ),

              const SizedBox(height: AppSpacing.sm),

              const _SecaoDivisoria(),

              const SizedBox(height: AppSpacing.sm),

              _TransferenciasCard(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const TransferenciasPage(),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'contas_fab',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const NovaContaPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// =====================================================
// SEÇÃO DE TRANSFERÊNCIAS
// =====================================================

class _SecaoDivisoria extends StatelessWidget {
  const _SecaoDivisoria();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 32,
      color: AppColors.border,
    );
  }
}

class _TransferenciasCard extends StatelessWidget {
  final VoidCallback onPressed;

  const _TransferenciasCard({
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.swap_horiz_rounded,
            color: AppColors.primary,
            size: 23,
          ),
        ),
        title: const Text(
          'Transferências',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: const Text(
          'Movimentações entre suas contas',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: AppColors.textSecondary,
        ),
        onTap: onPressed,
      ),
    );
  }
}

// =====================================================
// CARD DO PATRIMÔNIO
// =====================================================

class _PatrimonioCard extends StatelessWidget {
  final double valor;

  const _PatrimonioCard({
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    final positivo = valor >= 0;

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
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              color: AppColors.primary,
              size: 23,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Seu patrimônio',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  Formatters.moeda(valor),
                  style: TextStyle(
                    fontSize: 21,
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

class _PatrimonioCardCarregando extends StatelessWidget {
  const _PatrimonioCardCarregando();

  @override
  Widget build(BuildContext context) {
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
      child: const Row(
        children: [
          SizedBox(
            width: 46,
            height: 46,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Seu patrimônio',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 6),
                SizedBox(
                  width: 130,
                  height: 22,
                  child: LinearProgressIndicator(
                    minHeight: 6,
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
// CARD DA CONTA
// =====================================================

class _ContaCard extends StatelessWidget {
  final String nome;
  final String tipo;
  final double saldo;

  const _ContaCard({
    required this.nome,
    required this.tipo,
    required this.saldo,
  });

  @override
  Widget build(BuildContext context) {
    final saldoPositivo = saldo >= 0;

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
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.account_balance_outlined,
              color: AppColors.primary,
              size: 23,
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
                  nome,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  tipo,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Saldo
          Column(
            crossAxisAlignment:
                CrossAxisAlignment.end,
            children: [
              const Text(
                'Saldo',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                Formatters.moeda(saldo),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: saldoPositivo
                      ? AppColors.success
                      : AppColors.danger,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =====================================================
// CARREGANDO
// =====================================================

class _ContaCardCarregando extends StatelessWidget {
  final String nome;
  final String tipo;

  const _ContaCardCarregando({
    required this.nome,
    required this.tipo,
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
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.account_balance_outlined,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  nome,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  tipo,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
        ],
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
                Icons.account_balance_outlined,
                color: AppColors.primary,
                size: 30,
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            const Text(
              'Nenhuma conta cadastrada',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: AppSpacing.xs),

            const Text(
              'Adicione sua primeira conta para começar.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            FilledButton.icon(
              onPressed: onAdicionar,
              icon: const Icon(Icons.add),
              label: const Text('Adicionar conta'),
            ),
          ],
        ),
      ),
    );
  }
}