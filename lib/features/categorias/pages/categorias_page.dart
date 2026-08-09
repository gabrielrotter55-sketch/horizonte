import 'package:flutter/material.dart';

import '../../../database/database_service.dart';
import '../../../repositories/categoria_repository.dart';
import 'nova_categoria_page.dart';

class CategoriasPage extends StatelessWidget {
  CategoriasPage({super.key});

  final repository = CategoriaRepository(
    DatabaseService.instance.database,
  );

  Future<void> _confirmarExclusao(
    BuildContext context,
    int id,
    String nome,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Excluir categoria?'),
          content: Text(
            'Tem certeza que deseja excluir a categoria "$nome"?',
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

  void _editarCategoria(BuildContext context, categoria) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NovaCategoriaPage(
          categoria: categoria,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorias'),
      ),
      body: StreamBuilder(
        stream: repository.observar(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final categorias = snapshot.data!;

          if (categorias.isEmpty) {
            return const Center(
              child: Text('Nenhuma categoria cadastrada'),
            );
          }

          return ListView.builder(
            itemCount: categorias.length,
            itemBuilder: (context, index) {
              final categoria = categorias[index];

              return ListTile(
                leading: CircleAvatar(
                  child: Text(
                    categoria.icone,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                title: Text(categoria.nome),
                subtitle: Text(
                  categoria.receita ? 'Receita' : 'Despesa',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Editar',
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () {
                        _editarCategoria(
                          context,
                          categoria,
                        );
                      },
                    ),
                    IconButton(
                      tooltip: 'Excluir',
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () {
                        _confirmarExclusao(
                          context,
                          categoria.id,
                          categoria.nome,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const NovaCategoriaPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}