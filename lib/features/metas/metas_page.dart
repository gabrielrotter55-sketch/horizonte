import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/meta_financeira.dart';
import '../../models/meta_deposito.dart';
import '../../repositories/meta_repository.dart';
import '../../repositories/meta_deposito_repository.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/utils/formatters.dart';

class MetasPage extends StatefulWidget {
  const MetasPage({super.key});

  @override
  State<MetasPage> createState() => _MetasPageState();
}

class _MetasPageState extends State<MetasPage> {
  final _repository = MetaRepository();
  final _depositoRepository = MetaDepositoRepository();
  List<MetaFinanceira> _metas = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final metas = await _repository.buscarTodas();
    if (!mounted) return;
    setState(() {
      _metas = metas;
      _carregando = false;
    });
  }

  Future<void> _novaMeta() async {
    final meta = await showModalBottomSheet<MetaFinanceira>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _MetaFormSheet(),
    );
    if (meta == null) return;
    await _repository.salvar(meta);
    await _carregar();
  }

  Future<void> _editarMeta(MetaFinanceira meta) async {
    final atualizada = await showModalBottomSheet<MetaFinanceira>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _MetaFormSheet(meta: meta),
    );
    if (atualizada == null) return;
    await _repository.salvar(atualizada);
    await _carregar();
  }

  Future<void> _excluirMeta(MetaFinanceira meta) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir meta?'),
        content: Text('A meta "${meta.nome}" será removida.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;
    await _repository.excluir(meta.id);
    await _carregar();
  }

  Future<void> _registrarAporte(MetaFinanceira meta) async {
    final valorController = TextEditingController();
    String pessoa = 'Gabriel';
    final formKey = GlobalKey<FormState>();

    final deposito = await showDialog<MetaDeposito>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Adicionar depósito'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quem fez o depósito?',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'Gabriel', label: Text('Gabriel')),
                    ButtonSegment(value: 'Natália', label: Text('Natália')),
                  ],
                  selected: {pessoa},
                  onSelectionChanged: (selecionado) =>
                      setDialogState(() => pessoa = selecionado.first),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: valorController,
                  autofocus: true,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Valor do depósito',
                    prefixText: 'R\$ ',
                    hintText: '0,00',
                  ),
                  validator: (texto) {
                    final valor = _parseMoeda(texto ?? '');
                    if (!valor.isFinite || valor <= 0) {
                      return 'Informe um valor maior que zero.';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                final agora = DateTime.now();
                Navigator.pop(
                  dialogContext,
                  MetaDeposito(
                    id: agora.microsecondsSinceEpoch.toString(),
                    metaId: meta.id,
                    pessoa: pessoa,
                    valor: _parseMoeda(valorController.text),
                    data: agora,
                    descricao: 'Depósito na meta',
                    origem: 'manual',
                  ),
                );
              },
              child: const Text('Adicionar'),
            ),
          ],
        ),
      ),
    );
    valorController.dispose();

    if (deposito == null) return;

    try {
      await _depositoRepository.salvar(deposito);
      await _sincronizarAcumulado(meta.id);
      await _carregar();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível adicionar o depósito.'),
        ),
      );
    }
  }

  Future<void> _sincronizarAcumulado(String metaId) async {
    final metas = await _repository.buscarTodas();
    final encontrados = metas.where((item) => item.id == metaId).toList();
    final meta = encontrados.isEmpty ? null : encontrados.first;
    if (meta == null) return;

    final total = await _depositoRepository.totalDaMeta(metaId);
    await _repository.salvar(meta.copyWith(acumulado: total));
  }

  Future<void> _mostrarDepositos(MetaFinanceira meta) async {
    final depositos = await _depositoRepository.buscarDaMeta(meta.id);
    final totais = <String, double>{};
    for (final deposito in depositos) {
      totais[deposito.pessoa] = (totais[deposito.pessoa] ?? 0) + deposito.valor;
    }

    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _DepositosSheet(
        meta: meta,
        depositos: depositos,
        totais: totais,
        onExcluir: (deposito) async {
          await _depositoRepository.excluir(deposito.id);
          await _sincronizarAcumulado(meta.id);
          if (mounted) {
            Navigator.pop(context);
            await _carregar();
          }
        },
      ),
    );
  }

  double _parseMoeda(String texto) {
    return double.tryParse(
          texto.replaceAll('.', '').replaceAll(',', '.'),
        ) ??
        double.nan;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Metas'),
        actions: [
          IconButton(
            tooltip: 'Nova meta',
            onPressed: _novaMeta,
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _metas.isEmpty
              ? _EstadoVazio(onCriar: _novaMeta)
              : RefreshIndicator(
                  onRefresh: _carregar,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
                    children: [
                      _ResumoMetas(metas: _metas),
                      const SizedBox(height: 20),
                      ..._metas.map(
                        (meta) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _MetaCard(
                            meta: meta,
                            onAporte: () => _registrarAporte(meta),
                            onEditar: () => _editarMeta(meta),
                            onExcluir: () => _excluirMeta(meta),
                            onDetalhes: () => _mostrarDepositos(meta),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

class _ResumoMetas extends StatelessWidget {
  final List<MetaFinanceira> metas;

  const _ResumoMetas({required this.metas});

  @override
  Widget build(BuildContext context) {
    final objetivo = metas.fold<double>(0, (total, meta) => total + meta.objetivo);
    final acumulado = metas.fold<double>(0, (total, meta) => total + meta.acumulado);
    final concluidas = metas.where((meta) => meta.concluida).length;
    final progresso = objetivo <= 0 ? 0.0 : (acumulado / objetivo).clamp(0, 1).toDouble();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Seu progresso',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              '${metas.length} ${metas.length == 1 ? 'meta ativa' : 'metas ativas'} • $concluidas concluída(s)',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(value: progresso, minHeight: 9),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ResumoValor(
                    titulo: 'Acumulado',
                    valor: Formatters.moeda(acumulado),
                  ),
                ),
                Expanded(
                  child: _ResumoValor(
                    titulo: 'Objetivo',
                    valor: Formatters.moeda(objetivo),
                    alinhadoDireita: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ResumoValor extends StatelessWidget {
  final String titulo;
  final String valor;
  final bool alinhadoDireita;

  const _ResumoValor({
    required this.titulo,
    required this.valor,
    this.alinhadoDireita = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alinhadoDireita ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(titulo, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 3),
        Text(valor, style: const TextStyle(fontWeight: FontWeight.w800)),
      ],
    );
  }
}

class _MetaCard extends StatelessWidget {
  final MetaFinanceira meta;
  final VoidCallback onAporte;
  final VoidCallback onEditar;
  final VoidCallback onExcluir;
  final VoidCallback onDetalhes;

  const _MetaCard({
    required this.meta,
    required this.onAporte,
    required this.onEditar,
    required this.onExcluir,
    required this.onDetalhes,
  });

  @override
  Widget build(BuildContext context) {
    final prazo = meta.prazo == null
        ? null
        : DateFormat('dd/MM/yyyy', 'pt_BR').format(meta.prazo!);
    final percentual = (meta.progresso * 100).toStringAsFixed(0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Color(meta.cor).withValues(alpha: .12),
                  child: Icon(Icons.flag_rounded, color: Color(meta.cor)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(meta.nome, style: const TextStyle(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 3),
                      Text(
                        prazo == null ? 'Sem prazo definido' : 'Prazo: $prazo',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (opcao) {
                    if (opcao == 'editar') onEditar();
                    if (opcao == 'excluir') onExcluir();
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'editar', child: Text('Editar')),
                    PopupMenuItem(value: 'excluir', child: Text('Excluir')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    Formatters.moeda(meta.acumulado),
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                ),
                Text(
                  'de ${Formatters.moeda(meta.objetivo)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(value: meta.progresso, minHeight: 9),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('$percentual%'),
                const Spacer(),
                if (meta.concluida)
                  const Text(
                    'Concluída',
                    style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.success),
                  )
                else
                  Text('${Formatters.moeda((meta.objetivo - meta.acumulado).clamp(0, double.infinity))} restantes'),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: onDetalhes,
                icon: const Icon(Icons.people_alt_outlined),
                label: const Text('Ver quem depositou'),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: meta.concluida ? null : onAporte,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Adicionar valor'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DepositosSheet extends StatelessWidget {
  final MetaFinanceira meta;
  final List<MetaDeposito> depositos;
  final Map<String, double> totais;
  final Future<void> Function(MetaDeposito) onExcluir;

  const _DepositosSheet({
    required this.meta,
    required this.depositos,
    required this.totais,
    required this.onExcluir,
  });

  @override
  Widget build(BuildContext context) {
    final total = totais.values.fold<double>(0, (s, v) => s + v);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(meta.nome, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text('Total acumulado: ${Formatters.moeda(total)}'),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(child: _PessoaTotal(nome: 'Gabriel', valor: totais['Gabriel'] ?? 0, total: total)),
                const SizedBox(width: 12),
                Expanded(child: _PessoaTotal(nome: 'Natália', valor: totais['Natália'] ?? 0, total: total)),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Histórico de depósitos', style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            if (depositos.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text('Nenhum depósito individual registrado ainda.')),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: depositos.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final deposito = depositos[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        child: Text(deposito.pessoa.substring(0, 1)),
                      ),
                      title: Text(deposito.pessoa, style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text(DateFormat('dd/MM/yyyy • HH:mm', 'pt_BR').format(deposito.data)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(Formatters.moeda(deposito.valor), style: const TextStyle(fontWeight: FontWeight.w800)),
                          IconButton(
                            tooltip: 'Excluir depósito',
                            onPressed: () async {
                              final confirmar = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Excluir depósito?'),
                                  content: Text('${deposito.pessoa} • ${Formatters.moeda(deposito.valor)}'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
                                    FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Excluir')),
                                  ],
                                ),
                              );
                              if (confirmar == true) await onExcluir(deposito);
                            },
                            icon: const Icon(Icons.delete_outline_rounded),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PessoaTotal extends StatelessWidget {
  final String nome;
  final double valor;
  final double total;

  const _PessoaTotal({required this.nome, required this.valor, required this.total});

  @override
  Widget build(BuildContext context) {
    final percentual = total <= 0 ? 0 : (valor / total * 100);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(nome, style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(Formatters.moeda(valor), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text('${percentual.toStringAsFixed(1)}% do total', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _MetaFormSheet extends StatefulWidget {
  final MetaFinanceira? meta;

  const _MetaFormSheet({this.meta});

  @override
  State<_MetaFormSheet> createState() => _MetaFormSheetState();
}

class _MetaFormSheetState extends State<_MetaFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nome;
  late final TextEditingController _objetivo;
  late final TextEditingController _acumulado;
  DateTime? _prazo;
  int _cor = 0xFF6C4AB6;

  @override
  void initState() {
    super.initState();
    final meta = widget.meta;
    _nome = TextEditingController(text: meta?.nome ?? '');
    _objetivo = TextEditingController(
      text: meta == null ? '' : meta.objetivo.toStringAsFixed(2).replaceAll('.', ','),
    );
    _acumulado = TextEditingController(
      text: meta == null ? '0,00' : meta.acumulado.toStringAsFixed(2).replaceAll('.', ','),
    );
    _prazo = meta?.prazo;
    _cor = meta?.cor ?? _cor;
  }

  @override
  void dispose() {
    _nome.dispose();
    _objetivo.dispose();
    _acumulado.dispose();
    super.dispose();
  }

  double _valor(String texto) => double.tryParse(
        texto.replaceAll('.', '').replaceAll(',', '.'),
      ) ?? 0;

  Future<void> _selecionarPrazo() async {
    final data = await showDatePicker(
      context: context,
      initialDate: _prazo ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      locale: const Locale('pt', 'BR'),
    );
    if (data == null) return;
    setState(() => _prazo = data);
  }

  void _salvar() {
    if (!_formKey.currentState!.validate()) return;
    final agora = DateTime.now();
    final meta = MetaFinanceira(
      id: widget.meta?.id ?? agora.microsecondsSinceEpoch.toString(),
      nome: _nome.text.trim(),
      objetivo: _valor(_objetivo.text),
      acumulado: _valor(_acumulado.text),
      prazo: _prazo,
      cor: _cor,
      criadoEm: widget.meta?.criadoEm ?? agora,
    );
    Navigator.pop(context, meta);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 8, 20, bottom + 20),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.meta == null ? 'Nova meta' : 'Editar meta',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nome,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(labelText: 'Nome da meta'),
                validator: (value) => value == null || value.trim().isEmpty ? 'Informe um nome' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _objetivo,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Valor objetivo', prefixText: 'R\$ '),
                validator: (value) => _valor(value ?? '') <= 0 ? 'Informe um valor maior que zero' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _acumulado,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Já acumulado', prefixText: 'R\$ '),
                validator: (value) => _valor(value ?? '') < 0 ? 'Informe um valor válido' : null,
              ),
              const SizedBox(height: 14),
              InkWell(
                onTap: _selecionarPrazo,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Prazo (opcional)',
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  child: Text(
                    _prazo == null
                        ? 'Sem prazo definido'
                        : DateFormat('dd/MM/yyyy', 'pt_BR').format(_prazo!),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Cor da meta', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: [
                  0xFF6C4AB6,
                  0xFF2563EB,
                  0xFF0F766E,
                  0xFFEA580C,
                  0xFFDB2777,
                ].map((cor) {
                  return GestureDetector(
                    onTap: () => setState(() => _cor = cor),
                    child: CircleAvatar(
                      backgroundColor: Color(cor),
                      child: _cor == cor ? const Icon(Icons.check, color: Colors.white) : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _salvar,
                  child: Text(widget.meta == null ? 'Criar meta' : 'Salvar alterações'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EstadoVazio extends StatelessWidget {
  final VoidCallback onCriar;

  const _EstadoVazio({required this.onCriar});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.flag_rounded, size: 64, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 18),
            const Text('Nenhuma meta cadastrada', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            const Text('Crie uma meta para acompanhar seu progresso até o que você quer conquistar.', textAlign: TextAlign.center),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: onCriar,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Criar primeira meta'),
            ),
          ],
        ),
      ),
    );
  }
}
