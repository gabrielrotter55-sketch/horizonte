import 'package:flutter/material.dart';

import '../../../database/database_service.dart';
import '../../../repositories/cartao_repository.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_spacing.dart';
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
            return _EstadoVazio(
              onAdicionar: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NovoCartaoPage(),
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
                'Seus cartões',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: AppSpacing.xs),

              Text(
                '${cartoes.length} '
                '${cartoes.length == 1 ? 'cartão cadastrado' : 'cartões cadastrados'}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              ...cartoes.map(
                (cartao) {
                  return Padding(
                    padding: const EdgeInsets.only(
                      bottom: AppSpacing.sm,
                    ),
                    child: FutureBuilder<double>(
                      future: repository.valorUtilizado(
                        cartao.id,
                      ),
                      builder: (
                        context,
                        utilizadoSnapshot,
                      ) {
                        if (!utilizadoSnapshot.hasData) {
                          return const _CartaoCarregando();
                        }

                        final utilizado =
                            utilizadoSnapshot.data!;

                        final disponivel =
                            cartao.limite - utilizado;

                        return _CartaoCard(
                          nome: cartao.nome,
                          limite: cartao.limite,
                          utilizado: utilizado,
                          disponivel: disponivel,
                          fechamento:
                              cartao.fechamento,
                          vencimento:
                              cartao.vencimento,
                          onEditar: () {
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
                          onVerFatura: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    FaturasPage(),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'cartoes_fab',
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

// =====================================================
// CARD DO CARTÃO
// =====================================================

class _CartaoCard extends StatelessWidget {
  final String nome;
  final double limite;
  final double utilizado;
  final double disponivel;
  final int fechamento;
  final int vencimento;
  final VoidCallback onEditar;
  final VoidCallback onVerFatura;

  const _CartaoCard({
    required this.nome,
    required this.limite,
    required this.utilizado,
    required this.disponivel,
    required this.fechamento,
    required this.vencimento,
    required this.onEditar,
    required this.onVerFatura,
  });

  @override
  Widget build(BuildContext context) {
    final limiteValido = limite > 0;

    final percentual = limiteValido
        ? (utilizado / limite).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppSpacing.md,
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
          // ==========================================
          // CABEÇALHO
          // ==========================================

          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius:
                      BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.credit_card_outlined,
                  color: AppColors.primary,
                  size: 23,
                ),
              ),

              const SizedBox(width: AppSpacing.md),

              Expanded(
                child: Text(
                  nome,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),

              IconButton(
                tooltip: 'Editar',
                onPressed: onEditar,
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 20,
                ),
                color: AppColors.textSecondary,
                visualDensity:
                    VisualDensity.compact,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // ==========================================
          // DISPONÍVEL
          // ==========================================

          const Text(
            'Limite disponível',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            Formatters.moeda(disponivel),
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // ==========================================
          // BARRA DE UTILIZAÇÃO
          // ==========================================

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percentual,
              minHeight: 7,
              backgroundColor:
                  AppColors.primaryLight,
              valueColor:
                  AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // ==========================================
          // UTILIZADO / LIMITE
          // ==========================================

          Row(
            children: [
              Expanded(
                child: _InfoItem(
                  titulo: 'Utilizado',
                  valor: Formatters.moeda(
                    utilizado,
                  ),
                ),
              ),
              Expanded(
                child: _InfoItem(
                  titulo: 'Limite',
                  valor: Formatters.moeda(
                    limite,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // ==========================================
          // FECHAMENTO / VENCIMENTO
          // ==========================================

          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 15,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Fecha dia $fechamento · '
                  'Vence dia $vencimento',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // ==========================================
          // FATURA
          // ==========================================

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onVerFatura,
              icon: const Icon(
                Icons.receipt_long_outlined,
                size: 19,
              ),
              label: const Text(
                'Ver fatura atual',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// ITEM DE INFORMAÇÃO
// =====================================================

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
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          valor,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

// =====================================================
// CARREGAMENTO
// =====================================================

class _CartaoCarregando extends StatelessWidget {
  const _CartaoCarregando();

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
      child: const Center(
        child: CircularProgressIndicator(),
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
                borderRadius:
                    BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.credit_card_outlined,
                color: AppColors.primary,
                size: 30,
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            const Text(
              'Nenhum cartão cadastrado',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: AppSpacing.xs),

            const Text(
              'Adicione seu primeiro cartão para acompanhar seus gastos.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            FilledButton.icon(
              onPressed: onAdicionar,
              icon: const Icon(Icons.add),
              label: const Text('Adicionar cartão'),
            ),
          ],
        ),
      ),
    );
  }
}