import 'package:flutter/material.dart';

import '../../../database/app_database.dart';
import '../viewmodels/categoria_view_model.dart';

class NovaCategoriaPage extends StatefulWidget {
  final Categoria? categoria;

  const NovaCategoriaPage({
    super.key,
    this.categoria,
  });

  @override
  State<NovaCategoriaPage> createState() => _NovaCategoriaPageState();
}

class _NovaCategoriaPageState extends State<NovaCategoriaPage> {
  final _nomeController = TextEditingController();

  final _viewModel = CategoriaViewModel();

  String _icone = '💰';
  bool _receita = false;

  bool get _editando => widget.categoria != null;

  @override
  void initState() {
    super.initState();

    final categoria = widget.categoria;

    if (categoria != null) {
      _nomeController.text = categoria.nome;
      _icone = categoria.icone;
      _receita = categoria.receita;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    final nome = _nomeController.text.trim();

    if (nome.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Digite o nome da categoria.'),
        ),
      );
      return;
    }

    // Por enquanto usamos uma cor padrão.
    // Depois vamos criar o seletor de cores.
    const cor = 0xFF2196F3;

    if (_editando) {
      await _viewModel.editar(
        id: widget.categoria!.id,
        nome: nome,
        icone: _icone,
        cor: cor,
        receita: _receita,
      );
    } else {
      await _viewModel.salvar(
        nome: nome,
        icone: _icone,
        cor: cor,
        receita: _receita,
      );
    }

    if (!mounted) return;

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _editando ? 'Editar Categoria' : 'Nova Categoria',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome',
                hintText: 'Ex.: Alimentação',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              initialValue: _icone,
              decoration: const InputDecoration(
                labelText: 'Ícone',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: '💰',
                  child: Text('💰 Dinheiro'),
                ),
                DropdownMenuItem(
                  value: '🍔',
                  child: Text('🍔 Alimentação'),
                ),
                DropdownMenuItem(
                  value: '🚗',
                  child: Text('🚗 Transporte'),
                ),
                DropdownMenuItem(
                  value: '🏠',
                  child: Text('🏠 Casa'),
                ),
                DropdownMenuItem(
                  value: '🎮',
                  child: Text('🎮 Lazer'),
                ),
                DropdownMenuItem(
                  value: '🛒',
                  child: Text('🛒 Compras'),
                ),
                DropdownMenuItem(
                  value: '💊',
                  child: Text('💊 Saúde'),
                ),
                DropdownMenuItem(
                  value: '📚',
                  child: Text('📚 Educação'),
                ),
              ],
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  _icone = value;
                });
              },
            ),

            const SizedBox(height: 20),

            SwitchListTile(
              title: const Text('É uma receita?'),
              subtitle: Text(
                _receita
                    ? 'Esta categoria será usada para receitas'
                    : 'Esta categoria será usada para despesas',
              ),
              value: _receita,
              onChanged: (value) {
                setState(() {
                  _receita = value;
                });
              },
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _salvar,
                child: Text(
                  _editando
                      ? 'Salvar alterações'
                      : 'Salvar',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}