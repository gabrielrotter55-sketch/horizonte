import 'package:flutter/material.dart';

import '../../../database/app_database.dart';
import '../../../database/database_service.dart';
import '../../../repositories/cartao_repository.dart';
import '../../../repositories/fatura_repository.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_spacing.dart';
import '../../../shared/utils/formatters.dart';
import 'detalhes_fatura_page.dart';

class FaturasPage extends StatefulWidget {
  const FaturasPage({super.key});

  @override
  State<FaturasPage> createState() => _FaturasPageState();
}

class _FaturasPageState extends State<FaturasPage> {
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
              child: Padding(
                padding: const EdgeInsets.all(
                  AppSpacing.lg,
                ),
                child: Text(
                  'Erro ao carregar cartões:\n'
                  '${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final cartoes = snapshot.data ?? [];

          if (cartoes.isEmpty) {
            return const _EstadoVazioFaturas();
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
                'Suas faturas',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(
                height: AppSpacing.xs,
              ),

              Text(
                '${cartoes.length} '
                '${cartoes.length == 1 ? 'cartão' : 'cartões'}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(
                height: AppSpacing.md,
              ),

              ...cartoes.map(
                (cartao) {
                  final hoje = DateTime.now();

                  final referenciaAtual =
                      _mesReferencia(
                    hoje,
                    cartao.fechamento,
                  );

                  final referenciaProxima =
                      _proximaReferencia(
                    referenciaAtual,
                  );

                  return FutureBuilder<
                      _DadosCartaoFaturas>(
                    future: _carregarDadosCartao(
                      cartao.id,
                      referenciaAtual,
                      referenciaProxima,
                    ),
                    builder: (
                      context,
                      faturasSnapshot,
                    ) {
                      if (faturasSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.only(
                            bottom: AppSpacing.md,
                          ),
                          child: _FaturaCarregando(),
                        );
                      }

                      if (faturasSnapshot.hasError) {
                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppSpacing.md,
                          ),
                          child: _ErroFatura(
                            erro:
                                '${faturasSnapshot.error}',
                          ),
                        );
                      }

                      if (!faturasSnapshot.hasData) {
                        return const SizedBox.shrink();
                      }

                      final dados =
                          faturasSnapshot.data!;

                      return Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppSpacing.lg,
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            // ==================================
                            // CARTÃO
                            // ==================================

                            Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration:
                                      BoxDecoration(
                                    color:
                                        AppColors.primaryLight,
                                    borderRadius:
                                        BorderRadius.circular(
                                      14,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons
                                        .credit_card_outlined,
                                    color:
                                        AppColors.primary,
                                    size: 23,
                                  ),
                                ),

                                const SizedBox(
                                  width: AppSpacing.md,
                                ),

                                Expanded(
                                  child: Text(
                                    cartao.nome,
                                    style:
                                        const TextStyle(
                                      fontSize: 18,
                                      fontWeight:
                                          FontWeight.w600,
                                      color: AppColors
                                          .textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(
                              height: AppSpacing.md,
                            ),

                            // ==================================
                            // FATURA ATUAL
                            // ==================================

                            _FaturaAtualCard(
                              mes: _nomeReferencia(
                                referenciaAtual.mes,
                                referenciaAtual.ano,
                              ),
                              valor:
                                  dados.atual.total,
                              paga: dados
                                  .atual.fatura.paga,
                              fechamento:
                                  cartao.fechamento,
                              vencimento:
                                  cartao.vencimento,
                              onVerFatura: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        DetalhesFaturaPage(
                                      fatura: dados
                                          .atual.fatura,
                                    ),
                                  ),
                                );

                                if (mounted) {
                                  setState(() {});
                                }
                              },
                            ),

                            const SizedBox(
                              height: AppSpacing.md,
                            ),

                            // ==================================
                            // PRÓXIMA FATURA
                            // ==================================

                            _ProximaFaturaCard(
                              mes: _nomeReferencia(
                                referenciaProxima.mes,
                                referenciaProxima.ano,
                              ),
                              valor:
                                  dados.proxima.total,
                              onVerFatura: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        DetalhesFaturaPage(
                                      fatura: dados
                                          .proxima.fatura,
                                    ),
                                  ),
                                );

                                if (mounted) {
                                  setState(() {});
                                }
                              },
                            ),

                            const SizedBox(
                              height: AppSpacing.lg,
                            ),

                            // ==================================
                            // HISTÓRICO
                            // ==================================

                            const Text(
                              'Histórico',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight:
                                    FontWeight.bold,
                                color:
                                    AppColors.textPrimary,
                              ),
                            ),

                            const SizedBox(
                              height: AppSpacing.sm,
                            ),

                            if (dados.historico.isEmpty)
                              const _HistoricoVazio()
                            else
                              ...dados.historico.map(
                                (historico) {
                                  return Padding(
                                    padding:
                                        const EdgeInsets
                                            .only(
                                      bottom:
                                          AppSpacing.sm,
                                    ),
                                    child:
                                        _HistoricoFaturaCard(
                                      mes: _nomeReferencia(
                                        historico
                                            .fatura
                                            .mesReferencia,
                                        historico
                                            .fatura
                                            .anoReferencia,
                                      ),
                                      valor:
                                          historico.total,
                                      paga: historico
                                          .fatura.paga,
                                      onTap: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                DetalhesFaturaPage(
                                              fatura:
                                                  historico
                                                      .fatura,
                                            ),
                                          ),
                                        );

                                        if (mounted) {
                                          setState(() {});
                                        }
                                      },
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  // ====================================================
  // CARREGAMENTO DAS FATURAS
  // ====================================================

  Future<_DadosCartaoFaturas>
      _carregarDadosCartao(
    int cartaoId,
    _Referencia referenciaAtual,
    _Referencia referenciaProxima,
  ) async {
    // ================================================
    // FATURA ATUAL
    // ================================================

    var faturaAtual =
        await faturaRepository
            .buscarPorCartaoEReferencia(
      cartaoId: cartaoId,
      mes: referenciaAtual.mes,
      ano: referenciaAtual.ano,
    );

    if (faturaAtual == null) {
      final id = await faturaRepository.criar(
        cartaoId: cartaoId,
        mes: referenciaAtual.mes,
        ano: referenciaAtual.ano,
      );

      faturaAtual =
          await faturaRepository.buscarPorId(id);
    }

    if (faturaAtual == null) {
      throw Exception(
        'Não foi possível criar a fatura atual.',
      );
    }

    final totalAtual =
        await faturaRepository.calcularTotal(
      faturaAtual.id,
    );

    // ================================================
    // PRÓXIMA FATURA
    // ================================================

    var faturaProxima =
        await faturaRepository
            .buscarPorCartaoEReferencia(
      cartaoId: cartaoId,
      mes: referenciaProxima.mes,
      ano: referenciaProxima.ano,
    );

    if (faturaProxima == null) {
      final id = await faturaRepository.criar(
        cartaoId: cartaoId,
        mes: referenciaProxima.mes,
        ano: referenciaProxima.ano,
      );

      faturaProxima =
          await faturaRepository.buscarPorId(id);
    }

    if (faturaProxima == null) {
      throw Exception(
        'Não foi possível criar a próxima fatura.',
      );
    }

    final totalProxima =
        await faturaRepository.calcularTotal(
      faturaProxima.id,
    );

    // ================================================
    // HISTÓRICO
    // ================================================

    final todas =
        await faturaRepository.buscarTodas();

    final faturasDoCartao = todas.where(
      (fatura) =>
          fatura.cartaoId == cartaoId &&
          !(
            fatura.mesReferencia ==
                referenciaAtual.mes &&
            fatura.anoReferencia ==
                referenciaAtual.ano
          ) &&
          !(
            fatura.mesReferencia ==
                referenciaProxima.mes &&
            fatura.anoReferencia ==
                referenciaProxima.ano
          ),
    ).toList();

    faturasDoCartao.sort(
      (a, b) {
        final dataA = DateTime(
          a.anoReferencia,
          a.mesReferencia,
        );

        final dataB = DateTime(
          b.anoReferencia,
          b.mesReferencia,
        );

        return dataB.compareTo(dataA);
      },
    );

    final historico =
        <_DadosFaturaHistorico>[];

    for (final fatura in faturasDoCartao) {
      final total =
          await faturaRepository.calcularTotal(
        fatura.id,
      );

      historico.add(
        _DadosFaturaHistorico(
          fatura: fatura,
          total: total,
        ),
      );
    }

    return _DadosCartaoFaturas(
      atual: _DadosFatura(
        fatura: faturaAtual,
        total: totalAtual,
      ),
      proxima: _DadosFatura(
        fatura: faturaProxima,
        total: totalProxima,
      ),
      historico: historico,
    );
  }

  // ====================================================
  // REFERÊNCIAS
  // ====================================================

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

  _Referencia _proximaReferencia(
    _Referencia referencia,
  ) {
    if (referencia.mes == 12) {
      return _Referencia(
        mes: 1,
        ano: referencia.ano + 1,
      );
    }

    return _Referencia(
      mes: referencia.mes + 1,
      ano: referencia.ano,
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

  String _nomeReferencia(
    int mes,
    int ano,
  ) {
    return '${_nomeMes(mes)}/$ano';
  }
}

// ======================================================
// FATURA ATUAL
// ======================================================

class _FaturaAtualCard extends StatelessWidget {
  final String mes;
  final double valor;
  final bool paga;
  final int fechamento;
  final int vencimento;
  final VoidCallback onVerFatura;

  const _FaturaAtualCard({
    required this.mes,
    required this.valor,
    required this.paga,
    required this.fechamento,
    required this.vencimento,
    required this.onVerFatura,
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
        borderRadius: BorderRadius.circular(22),
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
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Fatura atual',
                      style: TextStyle(
                        fontSize: 13,
                        color:
                            AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      mes,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.w600,
                        color:
                            AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusFatura(
                paga: paga,
              ),
            ],
          ),

          const SizedBox(
            height: AppSpacing.lg,
          ),

          const Text(
            'Total da fatura',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            Formatters.moeda(valor),
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(
            height: AppSpacing.md,
          ),

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
                    color:
                        AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: AppSpacing.md,
          ),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onVerFatura,
              icon: const Icon(
                Icons.receipt_long_outlined,
                size: 19,
              ),
              label: const Text(
                'Ver fatura',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ======================================================
// PRÓXIMA FATURA
// ======================================================

class _ProximaFaturaCard extends StatelessWidget {
  final String mes;
  final double valor;
  final VoidCallback onVerFatura;

  const _ProximaFaturaCard({
    required this.mes,
    required this.valor,
    required this.onVerFatura,
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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius:
                  BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              color: AppColors.primary,
              size: 22,
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
                const Text(
                  'Próxima fatura',
                  style: TextStyle(
                    fontSize: 13,
                    color:
                        AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  mes,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.w600,
                    color:
                        AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Em aberto',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w600,
                    color: AppColors.primary,
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
                Formatters.moeda(valor),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color:
                      AppColors.textPrimary,
                ),
              ),
              IconButton(
                onPressed: onVerFatura,
                icon: const Icon(
                  Icons.chevron_right,
                ),
                color:
                    AppColors.textSecondary,
                visualDensity:
                    VisualDensity.compact,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ======================================================
// HISTÓRICO
// ======================================================
class _HistoricoVazio extends StatelessWidget {
  const _HistoricoVazio();

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
      child: const Text(
        'Nenhuma fatura anterior.',
        style: TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _HistoricoFaturaCard
    extends StatelessWidget {
  final String mes;
  final double valor;
  final bool paga;
  final VoidCallback onTap;

  const _HistoricoFaturaCard({
    required this.mes,
    required this.valor,
    required this.paga,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
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
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: paga
                    ? AppColors.success
                        .withValues(alpha: 0.10)
                    : AppColors.primaryLight,
                borderRadius:
                    BorderRadius.circular(13),
              ),
              child: Icon(
                paga
                    ? Icons.check_circle_outline
                    : Icons.receipt_long_outlined,
                color: paga
                    ? AppColors.success
                    : AppColors.primary,
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
                    mes,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight:
                          FontWeight.w600,
                      color:
                          AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    paga
                        ? 'Fatura paga'
                        : 'Fatura em aberto',
                    style: const TextStyle(
                      fontSize: 12,
                      color:
                          AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            Text(
              Formatters.moeda(valor),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color:
                    AppColors.textPrimary,
              ),
            ),

            const SizedBox(width: 4),

            const Icon(
              Icons.chevron_right,
              color:
                  AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================
// STATUS
// ======================================================

class _StatusFatura extends StatelessWidget {
  final bool paga;

  const _StatusFatura({
    required this.paga,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(20),
        color: paga
            ? AppColors.success
                .withValues(alpha: 0.10)
            : AppColors.primaryLight,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            paga
                ? Icons.check_circle_outline
                : Icons.schedule_outlined,
            size: 15,
            color: paga
                ? AppColors.success
                : AppColors.primary,
          ),
          const SizedBox(width: 5),
          Text(
            paga ? 'Paga' : 'Em aberto',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: paga
                  ? AppColors.success
                  : AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ======================================================
// CARREGAMENTO
// ======================================================

class _FaturaCarregando
    extends StatelessWidget {
  const _FaturaCarregando();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius:
            BorderRadius.circular(20),
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

// ======================================================
// ERRO
// ======================================================

class _ErroFatura
    extends StatelessWidget {
  final String erro;

  const _ErroFatura({
    required this.erro,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Text(
        'Erro ao carregar faturas:\n$erro',
        style: const TextStyle(
          color: AppColors.danger,
        ),
      ),
    );
  }
}

// ======================================================
// ESTADO VAZIO
// ======================================================

class _EstadoVazioFaturas
    extends StatelessWidget {
  const _EstadoVazioFaturas();

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
                Icons.receipt_long_outlined,
                color: AppColors.primary,
                size: 30,
              ),
            ),

            const SizedBox(
              height: AppSpacing.md,
            ),

            const Text(
              'Nenhum cartão cadastrado',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
                color:
                    AppColors.textPrimary,
              ),
            ),

            const SizedBox(
              height: AppSpacing.xs,
            ),

            const Text(
              'Cadastre um cartão para acompanhar suas faturas.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color:
                    AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================
// REFERÊNCIA
// ======================================================

class _Referencia {
  final int mes;
  final int ano;

  const _Referencia({
    required this.mes,
    required this.ano,
  });
}

// ======================================================
// DADOS DA FATURA
// ======================================================

class _DadosFatura {
  final Fatura fatura;
  final double total;

  const _DadosFatura({
    required this.fatura,
    required this.total,
  });
}

// ======================================================
// DADOS DO HISTÓRICO
// ======================================================

class _DadosFaturaHistorico {
  final Fatura fatura;
  final double total;

  const _DadosFaturaHistorico({
    required this.fatura,
    required this.total,
  });
}

// ======================================================
// DADOS DO CARTÃO
// ======================================================

class _DadosCartaoFaturas {
  final _DadosFatura atual;
  final _DadosFatura proxima;
  final List<_DadosFaturaHistorico> historico;

  const _DadosCartaoFaturas({
    required this.atual,
    required this.proxima,
    required this.historico,
  });
}