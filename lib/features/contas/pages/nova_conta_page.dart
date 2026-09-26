import 'package:flutter/material.dart';

import '../../../database/app_database.dart';
import '../viewmodels/conta_view_model.dart';

class NovaContaPage extends StatefulWidget {
  final Conta? conta;

  const NovaContaPage({
    super.key,
    this.conta,
  });

  @override
  State<NovaContaPage> createState() => _NovaContaPageState();
}

class _NovaContaPageState extends State<NovaContaPage> {
  final _nomeController = TextEditingController();
  final _saldoController = TextEditingController();

  String _tipo = 'Conta Corrente';

  final _viewModel = ContaViewModel();

  bool get _editando => widget.conta != null;

  @override
  void initState() {
    super.initState();

    final conta = widget.conta;

    if (conta != null) {
      _nomeController.text = conta.nome;
      _saldoController.text = conta.saldoInicial.toStringAsFixed(2);
      _tipo = conta.tipo;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _saldoController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    final nome = _nomeController.text.trim();

    if (nome.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Digite o nome da conta.'),
        ),
      );
      return;
    }

    final saldo = double.tryParse(
          _saldoController.text.replaceAll('.', '').replaceAll(',', '.'),
        ) ??
        0;

    if (_editando) {
      await _viewModel.editar(
        id: widget.conta!.id,
        nome: nome,
        saldo: saldo,
        tipo: _tipo,
      );
    } else {
      await _viewModel.salvar(
        nome: nome,
        saldo: saldo,
        tipo: _tipo,
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
          _editando ? 'Editar Conta' : 'Nova Conta',
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
                hintText: 'Ex.: Banco do Brasil',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: _saldoController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Saldo inicial antes do histórico',
                hintText: 'Ex.: 1500,00',
                border: OutlineInputBorder(),
                prefixText: 'R\$ ',
                helperText: 'É o valor que já existia na conta antes dos lançamentos cadastrados.',
              ),
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              initialValue: _tipo,
              decoration: const InputDecoration(
                labelText: 'Tipo de conta',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Conta Corrente',
                  child: Text('Conta Corrente'),
                ),
                DropdownMenuItem(
                  value: 'Poupança',
                  child: Text('Poupança'),
                ),
                DropdownMenuItem(
                  value: 'Carteira',
                  child: Text('Carteira'),
                ),
              ],
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  _tipo = value;
                });
              },
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _salvar,
                child: Text(
                  _editando ? 'Salvar alterações' : 'Salvar',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}