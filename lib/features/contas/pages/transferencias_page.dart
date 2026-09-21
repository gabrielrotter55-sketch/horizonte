import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../database/app_database.dart';
import '../../../database/database_service.dart';
import '../../../repositories/conta_repository.dart';
import '../../../repositories/transferencia_repository.dart';
import 'nova_transferencia_page.dart';

class TransferenciasPage extends StatefulWidget {
  const TransferenciasPage({
    super.key,
  });

  @override
  State<TransferenciasPage> createState() =>
      _TransferenciasPageState();
}

class _TransferenciasPageState
    extends State<TransferenciasPage> {
  final _transferenciaRepository =
      TransferenciaRepository(
    DatabaseService.instance.database,
  );

  final _contaRepository = ContaRepository(
    DatabaseService.instance.database,
  );

  final _moeda = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
  );

  final _dataFormat = DateFormat(
    'dd/MM/yyyy',
    'pt_BR',
  );

  Future<Map<int, Conta>> _buscarContas() async {
    final contas = await _contaRepository.buscarTodas();

    return {
      for (final conta in contas) conta.id: conta,
    };
  }

  Future<void> _editar(
    Transferencia transferencia,
  ) async {
    final atualizado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NovaTransferenciaPage(
          transferencia: transferencia,
        ),
      ),
    );

    if (atualizado == true && mounted) {
      setState(() {});
    }
  }

  Future<void> _excluir(
    Transferencia transferencia,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Excluir transferência?',
          ),
          content: const Text(
            'Essa ação irá remover a transferência e atualizar os saldos das contas.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) {
      return;
    }

    await _transferenciaRepository.excluir(
      transferencia.id,
    );

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Transferência excluída.',
        ),
      ),
    );
  }

  String _tituloTransferencia(
    Transferencia transferencia,
    Map<int, Conta> contas,
  ) {
    final origem = contas[
      transferencia.contaOrigemId
    ];

    final destino = contas[
      transferencia.contaDestinoId
    ];

    final nomeOrigem =
        origem?.nome ?? 'Conta desconhecida';

    final nomeDestino =
        destino?.nome ?? 'Conta desconhecida';

    return '$nomeOrigem → $nomeDestino';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Transferências',
        ),
      ),
      body: StreamBuilder<List<Transferencia>>(
        stream: _transferenciaRepository.observar(),
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
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Não foi possível carregar as transferências.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .error,
                  ),
                ),
              ),
            );
          }

          final transferencias =
              snapshot.data ?? [];

          if (transferencias.isEmpty) {
            return const _EstadoVazio();
          }

          return FutureBuilder<Map<int, Conta>>(
            future: _buscarContas(),
            builder: (context, contasSnapshot) {
              if (contasSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final contas =
                  contasSnapshot.data ?? {};

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  100,
                ),
                itemCount: transferencias.length,
                separatorBuilder: (_, _) =>
                const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final transferencia =
                      transferencias[index];

                  return _TransferenciaCard(
                    transferencia: transferencia,
                    titulo: _tituloTransferencia(
                      transferencia,
                      contas,
                    ),
                    moeda: _moeda,
                    dataFormat: _dataFormat,
                    onEditar: () {
                      _editar(transferencia);
                    },
                    onExcluir: () {
                      _excluir(transferencia);
                    },
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton:
          FloatingActionButton.extended(
        heroTag: 'transferencias_fab',
        onPressed: () async {
          final atualizado = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const NovaTransferenciaPage(),
            ),
          );

          if (atualizado == true && mounted) {
            setState(() {});
          }
        },
        icon: const Icon(
          Icons.add,
        ),
        label: const Text(
          'Transferência',
        ),
      ),
    );
  }
}

class _TransferenciaCard extends StatelessWidget {
  final Transferencia transferencia;
  final String titulo;
  final NumberFormat moeda;
  final DateFormat dataFormat;
  final VoidCallback onEditar;
  final VoidCallback onExcluir;

  const _TransferenciaCard({
    required this.transferencia,
    required this.titulo,
    required this.moeda,
    required this.dataFormat,
    required this.onEditar,
    required this.onExcluir,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context)
                  .colorScheme
                  .primaryContainer,
              child: Icon(
                Icons.swap_horiz_rounded,
                color: Theme.of(context)
                    .colorScheme
                    .onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (transferencia
                      .descricao
                      .trim()
                      .isNotEmpty)
                    Text(
                      transferencia.descricao,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 4),
                  Text(
                    dataFormat.format(
                      transferencia.data,
                    ),
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment:
                  CrossAxisAlignment.end,
              children: [
                Text(
                  moeda.format(
                    transferencia.valor,
                  ),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.more_vert,
                  ),
                  onSelected: (opcao) {
                    if (opcao == 'editar') {
                      onEditar();
                    } else if (opcao == 'excluir') {
                      onExcluir();
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'editar',
                      child: Text('Editar'),
                    ),
                    PopupMenuItem(
                      value: 'excluir',
                      child: Text('Excluir'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EstadoVazio extends StatelessWidget {
  const _EstadoVazio();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.swap_horiz_rounded,
              size: 64,
              color: Theme.of(context)
                  .colorScheme
                  .primary,
            ),
            const SizedBox(height: 20),
            const Text(
              'Nenhuma transferência',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'As transferências entre suas contas aparecerão aqui.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: null,
              icon: Icon(
                Icons.swap_horiz_rounded,
              ),
              label: Text(
                'Nova transferência',
              ),
            ),
          ],
        ),
      ),
    );
  }
}