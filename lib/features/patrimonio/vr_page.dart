import 'package:flutter/material.dart';

import '../../database/app_database.dart';
import '../../database/database_service.dart';
import '../../repositories/beneficio_repository.dart';
import '../../shared/utils/formatters.dart';
import '../lancamentos/pages/novo_lancamento_page.dart';

class VrPage extends StatefulWidget {
  const VrPage({super.key});
  @override State<VrPage> createState() => _VrPageState();
}

class _VrPageState extends State<VrPage> {
  final _repo = BeneficioRepository();
  late Future<BeneficioResumo> _future;

  @override
  void initState() { super.initState(); _future = _repo.resumoMes(); }

  void _atualizar() => setState(() => _future = _repo.resumoMes());

  DateTime _proximoRecebimento() {
    final hoje = DateTime.now();
    if (hoje.day < 20) return DateTime(hoje.year, hoje.month, 20);
    return DateTime(hoje.year, hoje.month + 1, 20);
  }

  int _diasAteRecebimento() {
    final hoje = DateTime.now();
    final proximo = _proximoRecebimento();
    return proximo.difference(DateTime(hoje.year, hoje.month, hoje.day)).inDays + 1;
  }

  Future<void> _saldoInicial() async {
    if (await _repo.temMovimentacoes()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('O saldo inicial só pode ser configurado antes da primeira movimentação.')));
      return;
    }
    final atual = await _repo.saldoInicial();
    if (!mounted) return;
    final valor = await showDialog<double>(context: context, builder: (_) => _ValorDialog(titulo: 'Saldo inicial do VR', valorInicial: atual));
    if (valor == null) return;
    await _repo.salvarSaldoInicial(valor);
    if (mounted) _atualizar();
  }

  Future<void> _abrir(Lancamento? item, {bool? receita}) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => NovoLancamentoPage(lancamento: item, receitaInicial: receita, origemInicial: 'beneficio:vr_flash')));
    if (mounted) _atualizar();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('VR Flash')),
    body: FutureBuilder<BeneficioResumo>(
      future: _future,
      builder: (context, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final d = snap.data!;
        final proximoRecebimento = _proximoRecebimento();
        final diasRestantes = _diasAteRecebimento();
        final double limiteDiario = d.saldoAtual <= 0 ? 0.0 : d.saldoAtual / diasRestantes;
        return ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 110), children: [
          Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Saldo atual', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(Formatters.moeda(d.saldoAtual), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            const Text('O VR funciona como uma carteira separada das contas bancárias.'),
          ]))),
          const SizedBox(height: 12),
          Card(child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.calendar_today_outlined)),
            title: const Text('Limite de gasto diário recomendado'),
            subtitle: Text('Até ${proximoRecebimento.day.toString().padLeft(2, '0')}/${proximoRecebimento.month.toString().padLeft(2, '0')}/${proximoRecebimento.year} • considerando hoje'),
            trailing: Text(Formatters.moeda(limiteDiario), style: const TextStyle(fontWeight: FontWeight.w900)),
          )),
          const SizedBox(height: 12),
          Card(child: Column(children: [
            const ListTile(title: Text('Resumo'), subtitle: Text('Movimentações acumuladas do VR')),
            ListTile(leading: const Icon(Icons.account_balance_wallet_outlined), title: const Text('Saldo inicial'), trailing: Text(Formatters.moeda(d.saldoInicial))),
            ListTile(leading: const Icon(Icons.south_west_rounded), title: const Text('Receitas'), trailing: Text(Formatters.moeda(d.receitas))),
            ListTile(leading: const Icon(Icons.north_east_rounded), title: const Text('Despesas'), trailing: Text(Formatters.moeda(d.despesas))),
          ])),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: OutlinedButton.icon(onPressed: () => _abrir(null, receita: true), icon: const Icon(Icons.add_rounded), label: const Text('Receita'))),
            const SizedBox(width: 10),
            Expanded(child: FilledButton.icon(onPressed: () => _abrir(null, receita: false), icon: const Icon(Icons.remove_rounded), label: const Text('Despesa'))),
          ]),
          const SizedBox(height: 10),
          OutlinedButton.icon(onPressed: _saldoInicial, icon: const Icon(Icons.edit_outlined), label: const Text('Configurar saldo inicial')),
          const SizedBox(height: 20),
          const Text('Histórico', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          FutureBuilder<List<dynamic>>(
            future: _repo.historicoLancamentos(),
            builder: (context, h) {
              if (!h.hasData) return const Card(child: Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator())));
              final itens = h.data!.cast<Lancamento>();
              if (itens.isEmpty) return const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('Nenhuma movimentação no VR.')));
              return Card(child: Column(children: [
                for (final item in itens) ListTile(
                  leading: CircleAvatar(child: Icon(item.receita ? Icons.add_rounded : Icons.remove_rounded)),
                  title: Text(item.descricao),
                  subtitle: Text('${item.receita ? 'Receita' : 'Despesa'} • ${item.data.day.toString().padLeft(2,'0')}/${item.data.month.toString().padLeft(2,'0')}/${item.data.year}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(Formatters.moeda(item.valor), style: const TextStyle(fontWeight: FontWeight.w800)),
                      PopupMenuButton<String>(
                        onSelected: (acao) async {
                          if (acao == 'editar') {
                            await _abrir(item);
                          } else {
                            final confirmar = await showDialog<bool>(
                              context: context,
                              builder: (dialogContext) => AlertDialog(
                                title: const Text('Excluir movimentação?'),
                                content: Text('Excluir "${item.descricao}" do VR?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancelar')),
                                  FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Excluir')),
                                ],
                              ),
                            );
                            if (confirmar == true) {
                              if (item.receita) {
                                await _repo.estornarReceita(item.valor);
                              } else {
                                await _repo.estornarGasto(item.valor);
                              }
                              final db = DatabaseService.instance.database;
                              await (db.delete(db.lancamentos)..where((t) => t.id.equals(item.id))).go();
                              _atualizar();
                            }
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'editar', child: Text('Editar')),
                          PopupMenuItem(value: 'excluir', child: Text('Excluir')),
                        ],
                      ),
                    ],
                  ),
                  onTap: () => _abrir(item),
                ),
              ]));
            },
          ),
        ]);
      },
    ),
  );
}

class _ValorDialog extends StatefulWidget {
  final String titulo;
  final double valorInicial;
  const _ValorDialog({required this.titulo, required this.valorInicial});
  @override State<_ValorDialog> createState() => _ValorDialogState();
}
class _ValorDialogState extends State<_ValorDialog> {
  late final TextEditingController _controller;
  @override void initState() { super.initState(); _controller = TextEditingController(text: widget.valorInicial > 0 ? widget.valorInicial.toStringAsFixed(2).replaceAll('.', ',') : ''); }
  @override void dispose() { _controller.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.titulo),
    content: TextField(controller: _controller, autofocus: true, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Valor', prefixText: 'R\$ ')),
    actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')), FilledButton(onPressed: () { final v = double.tryParse(_controller.text.replaceAll('.', '').replaceAll(',', '.')); if (v != null && v >= 0) Navigator.of(context).pop(v); }, child: const Text('Salvar'))],
  );
}
