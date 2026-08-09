import 'package:flutter/material.dart';

import '../../../database/database_service.dart';
import '../../../repositories/lancamento_repository.dart';
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
            return const Center(
              child: Text(
                'Nenhum lançamento cadastrado',
              ),
            );
          }

          return ListView.builder(
            itemCount: lancamentos.length,
            itemBuilder: (context, index) {
              final lancamento = lancamentos[index];

              final valorFormatado =
    Formatters.moeda(lancamento.valor);

              return ListTile(
                leading: CircleAvatar(
                  child: Icon(
                    lancamento.receita
                        ? Icons.arrow_downward
                        : Icons.arrow_upward,
                  ),
                ),
                title: Text(lancamento.descricao),
                subtitle: Text(
                  lancamento.receita
                      ? 'Receita'
                      : 'Despesa',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      valorFormatado,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: lancamento.receita
                            ? Colors.green
                            : Colors.red,
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
                            builder: (_) => NovoLancamentoPage(
                              lancamento: lancamento,
                            ),
                          ),
                        );
                      },
                    ),

                    IconButton(
                      tooltip: 'Excluir',
                      icon: const Icon(
                        Icons.delete_outline,
                      ),
                      onPressed: () {
                        _confirmarExclusao(
                          context,
                          lancamento.id,
                          lancamento.descricao,
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const NovoLancamentoPage(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Novo lançamento'),
      ),
    );
  }
}