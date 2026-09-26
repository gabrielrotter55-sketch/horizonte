import 'package:flutter/material.dart';

import '../../../database/app_database.dart';
import '../viewmodels/cartao_view_model.dart';

class NovoCartaoPage extends StatefulWidget {
  final Cartoe? cartao;

  const NovoCartaoPage({
    super.key,
    this.cartao,
  });

  @override
  State<NovoCartaoPage> createState() => _NovoCartaoPageState();
}

class _NovoCartaoPageState extends State<NovoCartaoPage> {
  final _nomeController = TextEditingController();
  final _limiteController = TextEditingController();
  final _fechamentoController = TextEditingController();
  final _vencimentoController = TextEditingController();

  final _viewModel = CartaoViewModel();

  bool get _editando => widget.cartao != null;

  @override
  void initState() {
    super.initState();

    final cartao = widget.cartao;

    if (cartao != null) {
      _nomeController.text = cartao.nome;
      _limiteController.text = cartao.limite.toStringAsFixed(2);
      _fechamentoController.text = cartao.fechamento.toString();
      _vencimentoController.text = cartao.vencimento.toString();
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _limiteController.dispose();
    _fechamentoController.dispose();
    _vencimentoController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    final nome = _nomeController.text.trim();

    if (nome.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Digite o nome do cartão.'),
        ),
      );
      return;
    }

    final limite = double.tryParse(
          _limiteController.text.replaceAll(',', '.'),
        ) ??
        0;

    final fechamento =
        int.tryParse(_fechamentoController.text) ?? 1;

    final vencimento =
        int.tryParse(_vencimentoController.text) ?? 1;

    if (fechamento < 1 || fechamento > 31) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('O fechamento deve estar entre 1 e 31.'),
        ),
      );
      return;
    }

    if (vencimento < 1 || vencimento > 31) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('O vencimento deve estar entre 1 e 31.'),
        ),
      );
      return;
    }

    if (limite < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('O limite não pode ser negativo.'),
        ),
      );
      return;
    }

    if (_editando) {
      await _viewModel.editar(
        id: widget.cartao!.id,
        nome: nome,
        limite: limite,
        fechamento: fechamento,
        vencimento: vencimento,
      );
    } else {
      await _viewModel.salvar(
        nome: nome,
        limite: limite,
        fechamento: fechamento,
        vencimento: vencimento,
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
          _editando ? 'Editar Cartão' : 'Novo Cartão',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome do cartão',
                hintText: 'Ex.: Nubank',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: _limiteController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Limite',
                hintText: 'Ex.: 3000,00',
                prefixText: 'R\$ ',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: _fechamentoController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Dia de fechamento',
                hintText: 'Ex.: 10',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: _vencimentoController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Dia de vencimento',
                hintText: 'Ex.: 17',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

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