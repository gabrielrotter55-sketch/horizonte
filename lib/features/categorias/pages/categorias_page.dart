import 'package:flutter/material.dart';

import '../../../database/database_service.dart';
import '../../../repositories/categoria_repository.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_spacing.dart';
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

  void _editarCategoria(
    BuildContext context,
    categoria,
  ) {
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

          final receitas = categorias
              .where((categoria) => categoria.receita)
              .toList();

          final despesas = categorias
              .where((categoria) => !categoria.receita)
              .toList();

          if (categorias.isEmpty) {
            return _CategoriasVazio(
              onAdicionar: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const NovaCategoriaPage(),
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
                'Suas categorias',
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
                '${categorias.length} '
                '${categorias.length == 1 ? 'categoria cadastrada' : 'categorias cadastradas'}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              if (receitas.isNotEmpty) ...[
                const SizedBox(
                  height: AppSpacing.lg,
                ),
                const _SecaoTitulo(
                  titulo: 'Receitas',
                  quantidade: null,
                  cor: AppColors.success,
                ),
                const SizedBox(
                  height: AppSpacing.sm,
                ),
                _CategoriasCard(
                  categorias: receitas,
                  cor: AppColors.success,
                  onEditar: (categoria) {
                    _editarCategoria(
                      context,
                      categoria,
                    );
                  },
                  onExcluir: (categoria) {
                    _confirmarExclusao(
                      context,
                      categoria.id,
                      categoria.nome,
                    );
                  },
                ),
              ],
              if (despesas.isNotEmpty) ...[
                const SizedBox(
                  height: AppSpacing.lg,
                ),
                _SecaoTitulo(
                  titulo: 'Despesas',
                  quantidade: null,
                  cor: AppColors.primary,
                ),
                const SizedBox(
                  height: AppSpacing.sm,
                ),
                _CategoriasCard(
                  categorias: despesas,
                  cor: AppColors.primary,
                  onEditar: (categoria) {
                    _editarCategoria(
                      context,
                      categoria,
                    );
                  },
                  onExcluir: (categoria) {
                    _confirmarExclusao(
                      context,
                      categoria.id,
                      categoria.nome,
                    );
                  },
                ),
              ],
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'categorias_fab',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const NovaCategoriaPage(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Nova categoria'),
      ),
    );
  }
}

class _SecaoTitulo extends StatelessWidget {
  final String titulo;
  final int? quantidade;
  final Color cor;

  const _SecaoTitulo({
    required this.titulo,
    required this.quantidade,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 7,
          height: 22,
          decoration: BoxDecoration(
            color: cor,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(
          width: AppSpacing.sm,
        ),
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        if (quantidade != null) ...[
          const SizedBox(
            width: AppSpacing.xs,
          ),
          Text(
            '($quantidade)',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

class _CategoriasCard extends StatelessWidget {
  final List categorias;
  final Color cor;
  final void Function(dynamic categoria) onEditar;
  final void Function(dynamic categoria) onExcluir;

  const _CategoriasCard({
    required this.categorias,
    required this.cor,
    required this.onEditar,
    required this.onExcluir,
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
      child: Column(
        children: [
          for (int i = 0; i < categorias.length; i++) ...[
            _CategoriaItem(
              categoria: categorias[i],
              cor: cor,
              onEditar: () {
                onEditar(categorias[i]);
              },
              onExcluir: () {
                onExcluir(categorias[i]);
              },
            ),
            if (i < categorias.length - 1)
              const Divider(
                height: 1,
                indent: 68,
                endIndent: 16,
              ),
          ],
        ],
      ),
    );
  }
}

class _CategoriaItem extends StatelessWidget {
  final dynamic categoria;
  final Color cor;
  final VoidCallback onEditar;
  final VoidCallback onExcluir;

  const _CategoriaItem({
    required this.categoria,
    required this.cor,
    required this.onEditar,
    required this.onExcluir,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 7,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: cor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(13),
            ),
            alignment: Alignment.center,
            child: Text(
              categoria.icone,
              style: const TextStyle(
                fontSize: 21,
              ),
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
                  categoria.nome,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(
                  height: 3,
                ),
                Text(
                  categoria.receita
                      ? 'Receita'
                      : 'Despesa',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Editar',
            visualDensity: VisualDensity.compact,
            icon: const Icon(
              Icons.edit_outlined,
              size: 20,
            ),
            color: AppColors.textSecondary,
            onPressed: onEditar,
          ),
          IconButton(
            tooltip: 'Excluir',
            visualDensity: VisualDensity.compact,
            icon: const Icon(
              Icons.delete_outline,
              size: 20,
            ),
            color: AppColors.textSecondary,
            onPressed: onExcluir,
          ),
        ],
      ),
    );
  }
}

class _CategoriasVazio extends StatelessWidget {
  final VoidCallback onAdicionar;

  const _CategoriasVazio({
    required this.onAdicionar,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
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
                Icons.category_outlined,
                color: AppColors.primary,
                size: 30,
              ),
            ),
            const SizedBox(
              height: AppSpacing.md,
            ),
            const Text(
              'Nenhuma categoria cadastrada',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(
              height: AppSpacing.xs,
            ),
            const Text(
              'Crie categorias para organizar '
              'suas receitas e despesas.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(
              height: AppSpacing.md,
            ),
            FilledButton.icon(
              onPressed: onAdicionar,
              icon: const Icon(Icons.add),
              label: const Text(
                'Criar categoria',
              ),
            ),
          ],
        ),
      ),
    );
  }
}