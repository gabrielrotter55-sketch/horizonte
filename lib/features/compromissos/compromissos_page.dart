
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../database/app_database.dart';
import '../../database/database_service.dart';
import '../../models/compromisso.dart';
import '../../repositories/categoria_repository.dart';
import '../../repositories/compromisso_repository.dart';
import '../../repositories/conta_repository.dart';
import '../../repositories/lancamento_repository.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/utils/formatters.dart';

class CompromissosPage extends StatefulWidget {
  const CompromissosPage({super.key});

  @override
  State<CompromissosPage> createState() => _CompromissosPageState();
}

class _CompromissosPageState extends State<CompromissosPage> {
  final _repository = CompromissoRepository();
  late Future<List<Compromisso>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repository.buscarTodos();
  }

  void _recarregar() {
    setState(() => _future = _repository.buscarTodos());
  }

  Future<void> _novo([Compromisso? compromisso]) async {
    final resultado = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _CompromissoForm(compromisso: compromisso),
    );
    if (resultado == true) _recarregar();
  }

  Future<void> _excluir(Compromisso item) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir compromisso?'),
        content: Text(item.descricao),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir')),
        ],
      ),
    );
    if (confirmar == true) {
      await _repository.excluir(item.id);
      _recarregar();
    }
  }

  Future<void> _pagar(Compromisso item) async {
    final resultado = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _PagamentoCompromissoSheet(compromisso: item),
    );
    if (resultado == true) _recarregar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contas e compromissos'),
        actions: [
          IconButton(
            tooltip: 'Novo compromisso',
            onPressed: () => _novo(),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'compromissos_fab',
        onPressed: () => _novo(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Novo'),
      ),
      body: FutureBuilder<List<Compromisso>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final itens = snapshot.data ?? const <Compromisso>[];
          final pendentes = itens.where((e) => e.status == StatusCompromisso.pendente).toList();
          final pagos = itens.where((e) => e.status == StatusCompromisso.pago).toList();

          return RefreshIndicator(
            onRefresh: () async => _recarregar(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              children: [
                _ResumoCompromissos(itens: pendentes),
                const SizedBox(height: 18),
                const Text('Pendentes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                if (pendentes.isEmpty)
                  const _Empty(text: 'Nenhum compromisso pendente.')
                else
                  ...pendentes.map((item) => _CompromissoCard(
                        item: item,
                        onPagar: () => _pagar(item),
                        onEditar: () => _novo(item),
                        onExcluir: () => _excluir(item),
                      )),
                if (pagos.isNotEmpty) ...[
                  const SizedBox(height: 22),
                  const Text('Histórico', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  ...pagos.take(10).map((item) => _CompromissoCard(
                        item: item,
                        onPagar: null,
                        onEditar: () => _novo(item),
                        onExcluir: () => _excluir(item),
                      )),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ResumoCompromissos extends StatelessWidget {
  final List<Compromisso> itens;
  const _ResumoCompromissos({required this.itens});

  @override
  Widget build(BuildContext context) {
    final total = itens.fold<double>(0, (sum, item) => sum + item.valor);
    final vencidos = itens.where((e) => e.data.isBefore(DateTime.now())).length;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Expanded(child: _Resumo(label: 'Pendentes', value: '${itens.length}')),
            Expanded(child: _Resumo(label: 'Total', value: Formatters.moeda(total))),
            Expanded(child: _Resumo(label: 'Vencidos', value: '$vencidos', danger: vencidos > 0)),
          ],
        ),
      ),
    );
  }
}

class _Resumo extends StatelessWidget {
  final String label, value;
  final bool danger;
  const _Resumo({required this.label, required this.value, this.danger = false});
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: danger ? AppColors.danger : null)),
        ],
      );
}

class _CompromissoCard extends StatelessWidget {
  final Compromisso item;
  final VoidCallback? onPagar, onEditar, onExcluir;
  const _CompromissoCard({required this.item, required this.onPagar, required this.onEditar, required this.onExcluir});

  String _tipo() {
    switch (item.tipo) {
      case TipoCompromisso.mensal:
        return 'Mensal';
      case TipoCompromisso.anual:
        return 'Anual';
      case TipoCompromisso.esporadico:
        return 'Esporádico';
    }
  }

  @override
  Widget build(BuildContext context) {
    final hoje = DateTime.now();
    final vencido = item.status == StatusCompromisso.pendente &&
        item.data.isBefore(DateTime(hoje.year, hoje.month, hoje.day));
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: vencido ? AppColors.danger.withValues(alpha: .12) : Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            vencido ? Icons.priority_high_rounded : Icons.event_note_outlined,
            color: vencido ? AppColors.danger : Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(item.descricao, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(
          '${_tipo()} • ${DateFormat('dd/MM/yyyy', 'pt_BR').format(item.data)}'
          '${item.favorecido.isEmpty ? '' : ' • ${item.favorecido}'}',
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'pagar' && onPagar != null) onPagar!();
            if (value == 'editar') onEditar?.call();
            if (value == 'excluir') onExcluir?.call();
          },
          itemBuilder: (_) => [
            if (onPagar != null) const PopupMenuItem(value: 'pagar', child: Text('Marcar como pago')),
            const PopupMenuItem(value: 'editar', child: Text('Editar')),
            const PopupMenuItem(value: 'excluir', child: Text('Excluir')),
          ],
        ),
        isThreeLine: true,
        subtitleTextStyle: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  final String text;
  const _Empty({required this.text});
  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Center(child: Text(text, textAlign: TextAlign.center)),
        ),
      );
}

class _CompromissoForm extends StatefulWidget {
  final Compromisso? compromisso;
  const _CompromissoForm({this.compromisso});
  @override
  State<_CompromissoForm> createState() => _CompromissoFormState();
}

class _CompromissoFormState extends State<_CompromissoForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _descricao, _valor, _favorecido, _categoria, _observacao;
  late TipoCompromisso _tipo;
  late DateTime _data;

  @override
  void initState() {
    super.initState();
    final i = widget.compromisso;
    _descricao = TextEditingController(text: i?.descricao ?? '');
    _valor = TextEditingController(text: i == null ? '' : _numero(i.valor));
    _favorecido = TextEditingController(text: i?.favorecido ?? '');
    _categoria = TextEditingController(text: i?.categoria ?? 'Outras despesas');
    _observacao = TextEditingController(text: i?.observacao ?? '');
    _tipo = i?.tipo ?? TipoCompromisso.mensal;
    _data = i?.data ?? DateTime.now();
  }

  static String _numero(double value) => value.toStringAsFixed(2).replaceAll('.', ',');

  double? _parse(String value) {
    final limpo = value.replaceAll(RegExp(r'[R$\s.]'), '').replaceAll(',', '.');
    return double.tryParse(limpo);
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    final valor = _parse(_valor.text);
    if (valor == null || valor <= 0) return;
    final item = Compromisso(
      id: widget.compromisso?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      descricao: _descricao.text.trim(),
      valor: valor,
      data: _data,
      tipo: _tipo,
      categoria: _categoria.text.trim().isEmpty ? 'Outras despesas' : _categoria.text.trim(),
      favorecido: _favorecido.text.trim(),
      status: widget.compromisso?.status ?? StatusCompromisso.pendente,
      observacao: _observacao.text.trim().isEmpty ? null : _observacao.text.trim(),
      pagoEm: widget.compromisso?.pagoEm,
    );
    await CompromissoRepository().salvar(item);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 8, 20, MediaQuery.viewInsetsOf(context).bottom + 20),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.compromisso == null ? 'Novo compromisso' : 'Editar compromisso', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 18),
              TextFormField(
                controller: _descricao,
                decoration: const InputDecoration(labelText: 'Descrição', prefixIcon: Icon(Icons.description_outlined)),
                validator: (v) => v == null || v.trim().isEmpty ? 'Informe a descrição.' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _valor,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Valor', prefixIcon: Icon(Icons.attach_money_rounded)),
                validator: (v) => _parse(v ?? '') == null ? 'Informe um valor válido.' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<TipoCompromisso>(
                initialValue: _tipo,
                decoration: const InputDecoration(labelText: 'Recorrência'),
                items: const [
                  DropdownMenuItem(value: TipoCompromisso.mensal, child: Text('Mensal')),
                  DropdownMenuItem(value: TipoCompromisso.anual, child: Text('Anual')),
                  DropdownMenuItem(value: TipoCompromisso.esporadico, child: Text('Esporádico')),
                ],
                onChanged: (v) => setState(() => _tipo = v ?? _tipo),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Data de vencimento'),
                subtitle: Text(DateFormat('dd/MM/yyyy', 'pt_BR').format(_data)),
                trailing: const Icon(Icons.calendar_today_outlined),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _data,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                    locale: const Locale('pt', 'BR'),
                  );
                  if (picked != null) setState(() => _data = picked);
                },
              ),
              TextFormField(
                controller: _favorecido,
                decoration: const InputDecoration(labelText: 'Para quem / instituição (opcional)', prefixIcon: Icon(Icons.person_outline_rounded)),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _categoria,
                decoration: const InputDecoration(labelText: 'Categoria', prefixIcon: Icon(Icons.category_outlined)),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _observacao,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Observação (opcional)', prefixIcon: Icon(Icons.notes_outlined)),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(onPressed: _salvar, icon: const Icon(Icons.check_rounded), label: const Text('Salvar compromisso')),
            ],
          ),
        ),
      ),
    );
  }
}

class _PagamentoCompromissoSheet extends StatefulWidget {
  final Compromisso compromisso;
  const _PagamentoCompromissoSheet({required this.compromisso});
  @override
  State<_PagamentoCompromissoSheet> createState() => _PagamentoCompromissoSheetState();
}

class _PagamentoCompromissoSheetState extends State<_PagamentoCompromissoSheet> {
  final _db = DatabaseService.instance.database;
  late Future<List<Conta>> _contas;
  int? _contaId;
  DateTime _dataPagamento = DateTime.now();

  @override
  void initState() {
    super.initState();
    _contas = ContaRepository(_db).buscarTodas();
  }

  Future<void> _pagar() async {
    final contas = await _contas;
    if (_contaId == null || contas.isEmpty) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cadastre ou selecione uma conta para registrar o pagamento.')));
      return;
    }

    final categorias = await CategoriaRepository(_db).buscarTodas();
    final despesas = categorias.where((e) => !e.receita).toList();
    int? categoriaId;
    if (despesas.isEmpty) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cadastre uma categoria de despesa primeiro.')));
      return;
    }
    final preferida = despesas.firstWhere(
      (e) => e.nome.toLowerCase().contains(widget.compromisso.categoria.toLowerCase()),
      orElse: () => despesas.first,
    );
    categoriaId = preferida.id;

    await LancamentoRepository(_db).salvar(
      LancamentosCompanion.insert(
        descricao: widget.compromisso.descricao,
        valor: widget.compromisso.valor,
        receita: false,
        data: _dataPagamento,
        categoriaId: categoriaId,
        contaId: drift.Value(_contaId!),
        cartaoId: const drift.Value(null),
        origem: const drift.Value('compromisso'),
      ),
    );
    await _repositoryMarcarPago();
    if (mounted) Navigator.pop(context, true);
  }

  Future<void> _repositoryMarcarPago() async {
    await CompromissoRepository().marcarComoPago(widget.compromisso.id, _dataPagamento);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 8, 20, MediaQuery.viewInsetsOf(context).bottom + 24),
      child: FutureBuilder<List<Conta>>(
        future: _contas,
        builder: (context, snapshot) {
          final contas = snapshot.data ?? const <Conta>[];
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Registrar pagamento', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text('${widget.compromisso.descricao} • ${Formatters.moeda(widget.compromisso.valor)}'),
              const SizedBox(height: 18),
              DropdownButtonFormField<int>(
                initialValue: _contaId,
                decoration: const InputDecoration(labelText: 'Conta que será usada'),
                items: contas.map((conta) => DropdownMenuItem(value: conta.id, child: Text(conta.nome))).toList(),
                onChanged: (v) => setState(() => _contaId = v),
              ),
              const SizedBox(height: 18),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Data do pagamento'),
                subtitle: Text(DateFormat('dd/MM/yyyy', 'pt_BR').format(_dataPagamento)),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _dataPagamento,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                    locale: const Locale('pt', 'BR'),
                  );
                  if (picked != null) setState(() => _dataPagamento = picked);
                },
              ),
              const SizedBox(height: 8),
              FilledButton.icon(onPressed: _pagar, icon: const Icon(Icons.check_rounded), label: const Text('Confirmar pagamento')),
            ],
          );
        },
      ),
    );
  }
}
