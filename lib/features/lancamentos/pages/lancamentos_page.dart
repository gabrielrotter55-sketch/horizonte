import 'package:flutter/material.dart';

import '../../../database/app_database.dart';
import '../../../database/database_service.dart';
import '../../../repositories/beneficio_repository.dart';
import '../../../repositories/lancamento_repository.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_spacing.dart';
import '../../../shared/utils/formatters.dart';
import 'novo_lancamento_page.dart';

class LancamentosPage extends StatefulWidget {
  const LancamentosPage({super.key});
  @override State<LancamentosPage> createState() => _LancamentosPageState();
}

class _LancamentosPageState extends State<LancamentosPage> {
  final repository = LancamentoRepository(DatabaseService.instance.database);
  final _buscaController = TextEditingController();
  String _busca = '';
  int _tipo = 0; // 0 todos, 1 receitas, 2 despesas
  DateTime? _dataInicial;
  DateTime? _dataFinal;
  Map<int, String> _categorias = {};
  Map<int, String> _contas = {};
  Map<int, String> _cartoes = {};

  @override
  void initState() {
    super.initState();
    _carregarNomes();
    _buscaController.addListener(() {
      final valor = _buscaController.text.trim();
      if (valor != _busca && mounted) setState(() => _busca = valor);
    });
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  Future<void> _carregarNomes() async {
    final db = DatabaseService.instance.database;
    final categorias = await db.select(db.categorias).get();
    final contas = await db.select(db.contas).get();
    final cartoes = await db.select(db.cartoes).get();
    if (!mounted) return;
    setState(() {
      _categorias = {for (final x in categorias) x.id: x.nome};
      _contas = {for (final x in contas) x.id: x.nome};
      _cartoes = {for (final x in cartoes) x.id: x.nome};
    });
  }

  String _normalizar(String valor) => valor
      .toLowerCase()
      .replaceAll('á', 'a').replaceAll('à', 'a').replaceAll('ã', 'a').replaceAll('â', 'a')
      .replaceAll('é', 'e').replaceAll('ê', 'e').replaceAll('í', 'i')
      .replaceAll('ó', 'o').replaceAll('ô', 'o').replaceAll('õ', 'o')
      .replaceAll('ú', 'u').replaceAll('ç', 'c');

  String _valorBusca(double valor) => valor.toStringAsFixed(2).replaceAll('.', ',');

  bool _dataDentro(DateTime data) {
    final inicio = _dataInicial == null ? null : DateTime(_dataInicial!.year, _dataInicial!.month, _dataInicial!.day);
    final fim = _dataFinal == null ? null : DateTime(_dataFinal!.year, _dataFinal!.month, _dataFinal!.day, 23, 59, 59);
    return (inicio == null || !data.isBefore(inicio)) && (fim == null || !data.isAfter(fim));
  }

  bool _corresponde(Lancamento item) {
    // O histórico principal mostra somente lançamentos até hoje. Parcelas futuras
    // continuam salvas no banco e podem ser consultadas usando o filtro de datas.
    if (_dataInicial == null && _dataFinal == null && item.data.isAfter(DateTime.now())) return false;
    if (_tipo == 1 && !item.receita) return false;
    if (_tipo == 2 && item.receita) return false;
    if (!_dataDentro(item.data)) return false;
    if (_busca.isEmpty) return true;

    final categoria = _categorias[item.categoriaId] ?? '';
    final conta = item.contaId == null ? '' : (_contas[item.contaId!] ?? '');
    final cartao = item.cartaoId == null ? '' : (_cartoes[item.cartaoId!] ?? '');
    final origem = item.origem == 'beneficio:vr_flash' ? 'VR Flash' : item.origem;
    final data = '${item.data.day.toString().padLeft(2, '0')}/${item.data.month.toString().padLeft(2, '0')}/${item.data.year}';
    final dataIso = '${item.data.year}-${item.data.month.toString().padLeft(2, '0')}-${item.data.day.toString().padLeft(2, '0')}';
    final texto = _normalizar('${item.descricao} $categoria $conta $cartao $origem $data $dataIso ${_valorBusca(item.valor)} ${item.valor.toStringAsFixed(2)}');
    final termo = _normalizar(_busca).replaceAll('r\$', '').trim();
    return texto.contains(termo);
  }

  Future<void> _filtros() async {
    var tipo = _tipo;
    var inicio = _dataInicial;
    var fim = _dataFinal;
    final resultado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Filtros'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tipo de lançamento', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  SegmentedButton<int>(
                    segments: const [
                      ButtonSegment(value: 0, label: Text('Todos')),
                      ButtonSegment(value: 1, label: Text('Receitas')),
                      ButtonSegment(value: 2, label: Text('Despesas')),
                    ],
                    selected: {tipo},
                    onSelectionChanged: (v) => setDialogState(() => tipo = v.first),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.date_range_outlined),
                    title: Text(inicio == null ? 'Data inicial' : 'A partir de ${_formatarData(inicio!)}'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () async {
                      final d = await showDatePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                        initialDate: inicio ?? DateTime.now(),
                      );
                      if (d != null) setDialogState(() => inicio = d);
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.event_outlined),
                    title: Text(fim == null ? 'Data final' : 'Até ${_formatarData(fim!)}'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () async {
                      final d = await showDatePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                        initialDate: fim ?? inicio ?? DateTime.now(),
                      );
                      if (d != null) setDialogState(() => fim = d);
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  tipo = 0;
                  inicio = null;
                  fim = null;
                  setDialogState(() {});
                },
                child: const Text('Limpar'),
              ),
              FilledButton(
                onPressed: () {
                  _tipo = tipo;
                  _dataInicial = inicio;
                  _dataFinal = fim;
                  Navigator.pop(dialogContext, true);
                },
                child: const Text('Aplicar'),
              ),
            ],
          );
        },
      ),
    );
    if (resultado == true && mounted) setState(() {});
  }

  Future<void> _confirmarExclusao(BuildContext context, Lancamento lancamento) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir lançamento?'),
        content: Text('Tem certeza que deseja excluir "${lancamento.descricao}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Excluir')),
        ],
      ),
    );
    if (confirmar != true) return;
    if (lancamento.origem == 'beneficio:vr_flash') {
      final vr = BeneficioRepository();
      if (lancamento.receita) {
        await vr.estornarReceita(lancamento.valor);
      } else {
        await vr.estornarGasto(lancamento.valor);
      }
    }
    await repository.excluir(lancamento.id);
  }

  String _formatarData(DateTime data) => '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lançamentos'),
        actions: [
          IconButton(tooltip: 'Filtros', onPressed: _filtros, icon: const Icon(Icons.tune_rounded)),
          IconButton(tooltip: 'Novo lançamento', onPressed: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => const NovoLancamentoPage())); if (mounted) _carregarNomes(); }, icon: const Icon(Icons.add_rounded)),
        ],
      ),
      body: StreamBuilder<List<Lancamento>>(
        stream: repository.observar(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final todos = snapshot.data!;
          final filtrados = todos.where(_corresponde).toList()..sort((a, b) {
            final porData = b.data.compareTo(a.data);
            if (porData != 0) return porData;
            return b.id.compareTo(a.id);
          });
          final grupos = <String, List<Lancamento>>{};
          for (final item in filtrados) {
            final chave = '${item.data.year}-${item.data.month.toString().padLeft(2, '0')}';
            grupos.putIfAbsent(chave, () => <Lancamento>[]).add(item);
          }
          return ListView(padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, 100), children: [
            TextField(
              controller: _buscaController,
              decoration: InputDecoration(
                hintText: 'Buscar por descrição, valor, categoria, data, conta, cartão ou VR...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _busca.isEmpty ? null : IconButton(onPressed: _buscaController.clear, icon: const Icon(Icons.clear_rounded)),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: Text('${filtrados.length} ${filtrados.length == 1 ? 'lançamento' : 'lançamentos'}', style: const TextStyle(fontSize: 14, color: AppColors.textSecondary))),
              if (_tipo != 0 || _dataInicial != null || _dataFinal != null) Chip(label: const Text('Filtros ativos'), onDeleted: () => setState(() { _tipo = 0; _dataInicial = null; _dataFinal = null; })),
            ]),
            const SizedBox(height: AppSpacing.md),
            if (filtrados.isEmpty) const Card(child: Padding(padding: EdgeInsets.all(20), child: Center(child: Text('Nenhum lançamento encontrado.')))),
            for (final entrada in grupos.entries) ...[
              _MesLancamentosHeader(mes: _formatarMesAno(entrada.value.first.data), quantidade: entrada.value.length),
              const SizedBox(height: AppSpacing.sm),
              ...entrada.value.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _LancamentoCard(
                  descricao: item.descricao,
                  valor: item.valor,
                  receita: item.receita,
                  data: _formatarData(item.data),
                  detalhe: _detalhe(item),
                  onEditar: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => NovoLancamentoPage(lancamento: item))); if (mounted) _carregarNomes(); },
                  onExcluir: () => _confirmarExclusao(context, item),
                ),
              )),
              const SizedBox(height: AppSpacing.md),
            ],
          ]);
        },
      ),
    );
  }

  String _detalhe(Lancamento item) {
    final partes = <String>[];
    if (_categorias[item.categoriaId] != null) partes.add(_categorias[item.categoriaId]!);
    if (item.origem == 'beneficio:vr_flash') partes.add('VR Flash');
    else if (item.cartaoId != null && _cartoes[item.cartaoId!] != null) partes.add(_cartoes[item.cartaoId!]!);
    else if (item.contaId != null && _contas[item.contaId!] != null) partes.add(_contas[item.contaId!]!);
    return '${partes.isEmpty ? (item.receita ? 'Receita' : 'Despesa') : partes.join(' • ')} • ${_formatarData(item.data)}';
  }
}

class _MesLancamentosHeader extends StatelessWidget {
  final String mes;
  final int quantidade;
  const _MesLancamentosHeader({required this.mes, required this.quantidade});
  @override Widget build(BuildContext context) => Row(children: [Expanded(child: Text(mes, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary))), Text('$quantidade ${quantidade == 1 ? 'lançamento' : 'lançamentos'}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))]);
}

String _formatarMesAno(DateTime data) {
  const meses = ['Janeiro','Fevereiro','Março','Abril','Maio','Junho','Julho','Agosto','Setembro','Outubro','Novembro','Dezembro'];
  return '${meses[data.month - 1]} ${data.year}';
}

class _LancamentoCard extends StatelessWidget {
  final String descricao;
  final double valor;
  final bool receita;
  final String data;
  final String detalhe;
  final VoidCallback onEditar;
  final VoidCallback onExcluir;
  const _LancamentoCard({required this.descricao, required this.valor, required this.receita, required this.data, required this.detalhe, required this.onEditar, required this.onExcluir});
  @override
  Widget build(BuildContext context) => Card(child: ListTile(
    leading: CircleAvatar(child: Icon(receita ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded)),
    title: Text(descricao, maxLines: 2, overflow: TextOverflow.ellipsis),
    subtitle: Text(detalhe, maxLines: 2, overflow: TextOverflow.ellipsis),
    trailing: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 150),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Flexible(child: Text(Formatters.moeda(valor), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800))),
        PopupMenuButton<String>(onSelected: (v) { if (v == 'editar') onEditar(); else onExcluir(); }, itemBuilder: (_) => const [PopupMenuItem(value: 'editar', child: Text('Editar')), PopupMenuItem(value: 'excluir', child: Text('Excluir'))]),
      ]),
    ),
  ));
}
