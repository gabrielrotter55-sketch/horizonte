import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/investimento.dart';
import '../../repositories/investimento_repository.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/utils/formatters.dart';

class InvestimentosPage extends StatefulWidget {
  const InvestimentosPage({super.key});

  @override
  State<InvestimentosPage> createState() => _InvestimentosPageState();
}

class _InvestimentosPageState extends State<InvestimentosPage> {
  final _repo = InvestimentoRepository();
  List<Investimento> _itens = [];
  double _usd = 5.30;
  bool _carregando = true;
  String _filtro = 'Todos';

  static const tipos = [
    'Ações', 'FIIs', 'Stocks', 'ETFs internacionais',
    'Criptomoedas', 'Reserva de oportunidade', 'Renda Fixa', 'Outros',
  ];

  @override
  void initState() { super.initState(); _carregar(); }

  Future<void> _carregar() async {
    final itens = await _repo.buscarTodas();
    final usd = await _repo.cotacaoDolar();
    if (!mounted) return;
    setState(() { _itens = itens; _usd = usd; _carregando = false; });
  }

  double _brl(Investimento i, double valor) => i.internacional ? valor * _usd : valor;

  List<Investimento> get _visiveis => _filtro == 'Todos'
      ? _itens
      : _itens.where((i) => i.tipo == _filtro).toList();

  Future<void> _novo([Investimento? item]) async {
    final resultado = await showModalBottomSheet<Investimento>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _InvestimentoForm(investimento: item),
    );
    if (resultado == null) return;
    await _repo.salvar(resultado);
    await _carregar();
  }

  Future<void> _editarUsd() async {
    final valor = await showDialog<double>(
      context: context,
      builder: (_) => _CotacaoDialog(valorInicial: _usd),
    );
    if (valor == null) return;
    await _repo.salvarCotacaoDolar(valor);
    if (mounted) setState(() => _usd = valor);
  }

  Future<void> _excluir(Investimento item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir posição?'),
        content: Text('Remover ${item.ticker.isEmpty ? item.nome : item.ticker} da carteira?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Excluir')),
        ],
      ),
    );
    if (ok != true) return;
    await _repo.excluir(item.id);
    await _carregar();
  }

  @override
  Widget build(BuildContext context) {
    final atual = _itens.fold<double>(0, (s, i) => s + _brl(i, i.valorAtual));
    final aplicado = _itens.fold<double>(0, (s, i) => s + _brl(i, i.valorInvestido));
    final resultado = atual - aplicado;
    final exterior = _itens.where((i) => i.internacional).fold<double>(0, (s, i) => s + i.valorAtual);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Investimentos'),
        actions: [
          IconButton(tooltip: 'Cotação do dólar', onPressed: _editarUsd, icon: const Icon(Icons.currency_exchange_rounded)),
          IconButton(tooltip: 'Nova posição', onPressed: () => _novo(), icon: const Icon(Icons.add_rounded)),
        ],
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _carregar,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                children: [
                  _ResumoCarteira(atual: atual, aplicado: aplicado, resultado: resultado, exteriorUsd: exterior, usd: _usd, onUsd: _editarUsd),
                  const SizedBox(height: 12),
                  _AssistenteAlocacao(itens: _itens, usd: _usd),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['Todos', ...tipos].map((tipo) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(label: Text(tipo), selected: _filtro == tipo, onSelected: (_) => setState(() => _filtro = tipo)),
                      )).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_itens.isEmpty)
                    const _Vazio()
                  else if (_visiveis.isEmpty)
                    const Padding(padding: EdgeInsets.all(24), child: Center(child: Text('Nenhuma posição neste grupo.')))
                  else
                    ..._visiveis.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _PosicaoCard(item: item, usd: _usd, onEditar: () => _novo(item), onExcluir: () => _excluir(item)),
                    )),
                ],
              ),
            ),
    );
  }
}

class _AssistenteAlocacao extends StatefulWidget {
  final List<Investimento> itens;
  final double usd;
  const _AssistenteAlocacao({required this.itens, required this.usd});

  @override
  State<_AssistenteAlocacao> createState() => _AssistenteAlocacaoState();
}

class _AssistenteAlocacaoState extends State<_AssistenteAlocacao> {
  static const _key = 'horizonte_alocacao_alvos_v1';
  static const _classes = <String>['Ações', 'BDRs', 'ETFs internacionais', 'FIIs', 'Renda Fixa', 'Criptomoedas'];
  Map<String, double> _alvos = {
    'Ações': .25,
    'BDRs': .15,
    'ETFs internacionais': .05,
    'FIIs': .35,
    'Renda Fixa': .15,
    'Criptomoedas': .05,
  };
  double _aporte = 0;
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarAlvos();
  }

  Future<void> _carregarAlvos() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      try {
        final decoded = Map<String, dynamic>.from(__decode(raw));
        for (final classe in _classes) {
          final value = (decoded[classe] as num?)?.toDouble();
          if (value != null) _alvos[classe] = value;
        }
      } catch (_) {}
    }
    if (mounted) setState(() => _carregando = false);
  }

  Map<String, dynamic> __decode(String raw) {
    final value = jsonDecode(raw);
    return value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};
  }

  Future<void> _salvarAlvos(Map<String, double> valores) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(valores));
    if (mounted) setState(() => _alvos = valores);
  }

  Future<void> _configurar() async {
    final resultado = await showDialog<Map<String, double>>(
      context: context,
      builder: (_) => _AlocacaoConfigDialog(initial: _alvos),
    );
    if (resultado != null) await _salvarAlvos(resultado);
  }

  Future<void> _informarAporte() async {
    final resultado = await showDialog<double>(
      context: context,
      builder: (_) => _AporteDialog(initial: _aporte),
    );
    if (resultado != null && mounted) setState(() => _aporte = resultado);
  }

  double _brl(Investimento i, double valor) => i.internacional ? valor * widget.usd : valor;

  @override
  Widget build(BuildContext context) {
    if (_carregando) return const Card(child: Padding(padding: EdgeInsets.all(16), child: LinearProgressIndicator()));
    final totais = <String, double>{};
    for (final i in widget.itens) {
      totais[i.tipo] = (totais[i.tipo] ?? 0) + _brl(i, i.valorAtual);
    }
    final total = totais.values.fold<double>(0, (a, b) => a + b);
    final percentuais = <String, double>{for (final classe in _classes) classe: total <= 0 ? 0 : (totais[classe] ?? 0) / total};
    final deficits = <String, double>{for (final classe in _classes) classe: (_alvos[classe] ?? 0) - (percentuais[classe] ?? 0)};
    final prioritarias = deficits.entries.where((e) => e.value > 0).toList()..sort((a, b) => b.value.compareTo(a.value));
    final soma = _alvos.values.fold<double>(0, (a, b) => a + b);
    final aporteTotal = _aporte;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.psychology_alt_outlined, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            const Expanded(child: Text('Assistente de alocação', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800))),
            IconButton(tooltip: 'Configurar percentuais', onPressed: _configurar, icon: const Icon(Icons.tune_rounded)),
          ]),
          const SizedBox(height: 4),
          Text('Estratégia configurável • total ${(soma * 100).toStringAsFixed(0)}%'),
          const SizedBox(height: 10),
          OutlinedButton.icon(onPressed: _informarAporte, icon: const Icon(Icons.add_card_rounded), label: Text(aporteTotal > 0 ? 'Aporte: ${Formatters.moeda(aporteTotal)}' : 'Informar valor do aporte')),
          const SizedBox(height: 10),
          if (total <= 0)
            const Text('Cadastre seus investimentos para calcular a distribuição atual.')
          else ...[
            ..._classes.map((classe) {
              final atual = percentuais[classe]!;
              final alvo = _alvos[classe]!;
              final valorAporte = aporteTotal <= 0 || deficits[classe]! <= 0 ? 0.0 : aporteTotal * deficits[classe]! / prioritarias.fold<double>(0, (s, e) => s + e.value);
              return Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: Row(children: [
                  Expanded(child: Text(classe)),
                  Text('${(atual * 100).toStringAsFixed(1)}% → ${(alvo * 100).toStringAsFixed(1)}%', style: const TextStyle(fontWeight: FontWeight.w700)),
                  if (valorAporte > 0) ...[const SizedBox(width: 8), Text(Formatters.moeda(valorAporte), style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w800))],
                ]),
              );
            }),
            const Divider(),
            if (prioritarias.isEmpty)
              const Text('A carteira está dentro ou acima dos percentuais configurados.')
            else ...[
              Text('Prioridade de rebalanceamento: ${prioritarias.first.key}', style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              ...prioritarias.take(3).map((entry) {
                final candidatos = widget.itens.where((i) => i.tipo == entry.key).toList()..sort((a, b) => a.rentabilidade.compareTo(b.rentabilidade));
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text('${entry.key}: ${(entry.value * 100).toStringAsFixed(1)} p.p. abaixo do alvo. ${candidatos.isEmpty ? 'Nenhum ativo cadastrado nesta classe.' : 'Possíveis ativos: ${candidatos.take(3).map((i) => i.ticker.isEmpty ? i.nome : i.ticker).join(', ')}.'}'),
                );
              }),
              const Text('Os candidatos são apenas uma leitura dos dados cadastrados e não representam garantia de desempenho futuro.', style: TextStyle(fontSize: 12)),
            ],
          ],
        ]),
      ),
    );
  }
}

class _AlocacaoConfigDialog extends StatefulWidget {
  final Map<String, double> initial;
  const _AlocacaoConfigDialog({required this.initial});
  @override
  State<_AlocacaoConfigDialog> createState() => _AlocacaoConfigDialogState();
}

class _AlocacaoConfigDialogState extends State<_AlocacaoConfigDialog> {
  late final Map<String, TextEditingController> _controllers;
  static const classes = _AssistenteAlocacaoState._classes;

  @override
  void initState() {
    super.initState();
    _controllers = {for (final c in classes) c: TextEditingController(text: ((widget.initial[c] ?? 0) * 100).toStringAsFixed(1).replaceAll('.', ','))};
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) controller.dispose();
    super.dispose();
  }

  double _parse(String value) => double.tryParse(value.trim().replaceAll('.', '').replaceAll(',', '.')) ?? 0;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Percentuais da estratégia'),
    content: SingleChildScrollView(child: Column(children: [
      for (final classe in classes) TextField(controller: _controllers[classe], keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: classe, suffixText: '%')),
    ])),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
      FilledButton(onPressed: () {
        final values = {for (final classe in classes) classe: _parse(_controllers[classe]!.text) / 100};
        final total = values.values.fold<double>(0, (a, b) => a + b);
        if ((total - 1).abs() > .0001) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Os percentuais precisam totalizar 100%. Total atual: ${(total * 100).toStringAsFixed(1)}%.')));
          return;
        }
        Navigator.pop(context, values);
      }, child: const Text('Salvar')),
    ],
  );
}

class _AporteDialog extends StatefulWidget {
  final double initial;
  const _AporteDialog({required this.initial});
  @override
  State<_AporteDialog> createState() => _AporteDialogState();
}

class _AporteDialogState extends State<_AporteDialog> {
  late final TextEditingController _controller;
  @override
  void initState() { super.initState(); _controller = TextEditingController(text: widget.initial > 0 ? widget.initial.toStringAsFixed(2).replaceAll('.', ',') : ''); }
  @override
  void dispose() { _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Valor do próximo aporte'),
    content: TextField(controller: _controller, autofocus: true, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(prefixText: 'R\$ ', labelText: 'Quanto você vai aportar?')),
    actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')), FilledButton(onPressed: () { final v = double.tryParse(_controller.text.trim().replaceAll('.', '').replaceAll(',', '.')) ?? 0; if (v >= 0) Navigator.pop(context, v); }, child: const Text('Usar'))],
  );
}

class _ResumoCarteira extends StatelessWidget {
  final double atual, aplicado, resultado, exteriorUsd, usd;
  final VoidCallback onUsd;
  const _ResumoCarteira({required this.atual, required this.aplicado, required this.resultado, required this.exteriorUsd, required this.usd, required this.onUsd});

  @override
  Widget build(BuildContext context) {
    final positivo = resultado >= 0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Carteira de investimentos', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text(Formatters.moeda(atual), style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800)),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: _Mini(label: 'Aplicado', value: Formatters.moeda(aplicado))),
          Expanded(child: _Mini(label: 'Resultado', value: '${resultado >= 0 ? '+' : ''}${Formatters.moeda(resultado)}', color: positivo ? Colors.greenAccent : Colors.redAccent, right: true)),
        ]),
        const SizedBox(height: 14),
        const Divider(color: Colors.white24),
        Row(children: [
          const Icon(Icons.public_rounded, size: 18, color: Colors.white70),
          const SizedBox(width: 7),
          Expanded(child: Text('Exterior: US\$ ${exteriorUsd.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white70))),
          TextButton(onPressed: onUsd, style: TextButton.styleFrom(foregroundColor: Colors.white), child: Text('US\$ 1 = R\$ ${usd.toStringAsFixed(2)}')),
        ]),
      ]),
    );
  }
}

class _Mini extends StatelessWidget {
  final String label, value; final Color color; final bool right;
  const _Mini({required this.label, required this.value, this.color = Colors.white, this.right = false});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: right ? CrossAxisAlignment.end : CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
    const SizedBox(height: 3),
    Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w800)),
  ]);
}

class _PosicaoCard extends StatelessWidget {
  final Investimento item; final double usd; final VoidCallback onEditar, onExcluir;
  const _PosicaoCard({required this.item, required this.usd, required this.onEditar, required this.onExcluir});
  @override
  Widget build(BuildContext context) {
    final positivo = item.resultado >= 0;
    final brl = item.internacional ? item.valorAtual * usd : item.valorAtual;
    final nome = item.ticker.isEmpty ? item.nome : item.ticker;
    final sigla = nome.length <= 3 ? nome.toUpperCase() : nome.substring(0, 3).toUpperCase();
    return Card(child: InkWell(borderRadius: BorderRadius.circular(20), onTap: onEditar, child: Padding(padding: const EdgeInsets.fromLTRB(16, 14, 8, 14), child: Row(children: [
      Container(width: 46, height: 46, decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(14)), alignment: Alignment.center, child: Text(sigla, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800))),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(nome, style: const TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 3),
        Text('${item.tipo} • ${item.instituicao}', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 7),
        Text(item.internacional ? 'US\$ ${item.valorAtual.toStringAsFixed(2)} • ${Formatters.moeda(brl)}' : Formatters.moeda(brl), style: const TextStyle(fontWeight: FontWeight.w700)),
        Text('${positivo ? '+' : ''}${Formatters.moeda(item.internacional ? item.resultado * usd : item.resultado)} (${(item.rentabilidade * 100).toStringAsFixed(2)}%)', style: TextStyle(color: positivo ? AppColors.success : AppColors.danger, fontWeight: FontWeight.w600)),
      ])),
      PopupMenuButton<String>(onSelected: (op) { if (op == 'editar') onEditar(); if (op == 'excluir') onExcluir(); }, itemBuilder: (_) => const [PopupMenuItem(value: 'editar', child: Text('Editar')), PopupMenuItem(value: 'excluir', child: Text('Excluir'))]),
    ]))));
  }
}

class _InvestimentoForm extends StatefulWidget {
  final Investimento? investimento;
  const _InvestimentoForm({this.investimento});
  @override State<_InvestimentoForm> createState() => _InvestimentoFormState();
}

class _CotacaoDialog extends StatefulWidget {
  final double valorInicial;
  const _CotacaoDialog({required this.valorInicial});
  @override State<_CotacaoDialog> createState()=>_CotacaoDialogState();
}
class _CotacaoDialogState extends State<_CotacaoDialog>{
  late final TextEditingController _controller;
  @override void initState(){super.initState();_controller=TextEditingController(text:widget.valorInicial.toStringAsFixed(2).replaceAll('.',','));}
  @override void dispose(){_controller.dispose();super.dispose();}
  double _parse(String s)=>double.tryParse(s.trim().replaceAll('.','').replaceAll(',','.'))??0;
  @override Widget build(BuildContext context)=>AlertDialog(
    title:const Text('Cotação do dólar'),
    content:TextField(controller:_controller,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:const InputDecoration(labelText:r'US$ 1,00 vale',prefixText:'R\$ ',suffixText:' BRL')),
    actions:[TextButton(onPressed:()=>Navigator.of(context).pop(),child:const Text('Cancelar')),FilledButton(onPressed:(){final v=_parse(_controller.text);if(v>0&&v.isFinite)Navigator.of(context).pop(v);},child:const Text('Salvar'))],
  );
}

class _InvestimentoFormState extends State<_InvestimentoForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nome, _ticker, _quantidade, _pm, _atual;
  late String _tipo, _instituicao, _moeda;
  late DateTime _data;

  @override
  void initState() {
    super.initState();
    final i = widget.investimento;
    _nome = TextEditingController(text: i?.nome ?? '');
    _ticker = TextEditingController(text: i?.ticker ?? '');
    final qtd = i?.quantidade ?? 1;
    final pm = i?.precoMedio ?? i?.valorInvestido ?? 0;
    final atual = i?.precoAtual ?? i?.valorAtual ?? 0;
    _quantidade = TextEditingController(text: qtd > 0 ? _num(qtd) : '1');
    _pm = TextEditingController(text: pm > 0 ? _num(pm) : '');
    _atual = TextEditingController(text: atual > 0 ? _num(atual) : '');
    _tipo = i?.tipo ?? 'Ações';
    _instituicao = i?.instituicao.isNotEmpty == true ? i!.instituicao : _instituicaoPadrao(_tipo);
    _moeda = i?.moeda ?? _moedaPadrao(_tipo);
    _data = i?.data ?? DateTime.now();
  }

  static String _num(double v) => v.toStringAsFixed(6).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  static String _instituicaoPadrao(String tipo) => tipo == 'Criptomoedas' ? 'Binance' : (tipo == 'Stocks' || tipo == 'ETFs internacionais' ? 'Nomad' : 'Nubank');
  static String _moedaPadrao(String tipo) => tipo == 'Stocks' || tipo == 'ETFs internacionais' ? 'USD' : 'BRL';

  @override void dispose() { _nome.dispose(); _ticker.dispose(); _quantidade.dispose(); _pm.dispose(); _atual.dispose(); super.dispose(); }

  double _valor(String texto) => double.tryParse(texto.replaceAll('.', '').replaceAll(',', '.')) ?? 0;

  void _tipoMudou(String? tipo) {
    if (tipo == null) return;
    setState(() { _tipo = tipo; _instituicao = _instituicaoPadrao(tipo); _moeda = _moedaPadrao(tipo); });
  }

  Future<void> _dataPicker() async {
    final d = await showDatePicker(context: context, initialDate: _data, firstDate: DateTime(2000), lastDate: DateTime(2100), locale: const Locale('pt', 'BR'));
    if (d != null) setState(() => _data = d);
  }

  void _salvar() {
    if (!_formKey.currentState!.validate()) return;
    final qtd = _valor(_quantidade.text), pm = _valor(_pm.text), atual = _valor(_atual.text);
    final agora = DateTime.now();
    Navigator.pop(context, Investimento(id: widget.investimento?.id ?? agora.microsecondsSinceEpoch.toString(), nome: _nome.text.trim(), ticker: _ticker.text.trim().toUpperCase(), tipo: _tipo, instituicao: _instituicao, moeda: _moeda, quantidade: qtd, precoMedio: pm, precoAtual: atual, valorInvestido: qtd * pm, valorAtual: qtd * atual, data: _data, origem: widget.investimento?.origem ?? 'investidor10'));
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final moeda = _moeda == 'USD' ? 'US\$ ' : 'R\$ ';
    return Padding(padding: EdgeInsets.fromLTRB(20, 8, 20, bottom + 20), child: Form(key: _formKey, child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(widget.investimento == null ? 'Nova posição' : 'Editar posição', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
      const SizedBox(height: 6),
      Text('Use os dados atuais do Investidor10. O Horizonte calcula o patrimônio internacional em reais pela cotação que você informar.', style: Theme.of(context).textTheme.bodyMedium),
      const SizedBox(height: 18),
      TextFormField(controller: _nome, decoration: const InputDecoration(labelText: 'Nome do ativo'), validator: (v) => v == null || v.trim().isEmpty ? 'Informe o ativo' : null),
      const SizedBox(height: 12),
      TextFormField(controller: _ticker, textCapitalization: TextCapitalization.characters, decoration: const InputDecoration(labelText: 'Ticker', hintText: 'Ex.: WEGE3, IVV, BTC')),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(initialValue: _tipo, decoration: const InputDecoration(labelText: 'Tipo'), items: _tiposForm.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(), onChanged: _tipoMudou),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(initialValue: _instituicao, decoration: const InputDecoration(labelText: 'Instituição'), items: const ['Nubank', 'Nomad', 'Binance', 'Mercado Pago', 'Outra'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(), onChanged: (v) { if (v != null) setState(() => _instituicao = v); }),
      const SizedBox(height: 12),
      SegmentedButton<String>(segments: const [ButtonSegment(value: 'BRL', label: Text('R\$')), ButtonSegment(value: 'USD', label: Text('US\$'))], selected: {_moeda}, onSelectionChanged: (s) => setState(() => _moeda = s.first)),
      const SizedBox(height: 16),
      const Text('Dados da posição', style: TextStyle(fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      TextFormField(controller: _quantidade, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Quantidade'), validator: (v) => _valor(v ?? '') <= 0 ? 'Informe a quantidade' : null),
      const SizedBox(height: 12),
      TextFormField(controller: _pm, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: 'Preço médio', prefixText: moeda), validator: (v) => _valor(v ?? '') <= 0 ? 'Informe o preço médio' : null),
      const SizedBox(height: 12),
      TextFormField(controller: _atual, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: 'Preço atual', prefixText: moeda), validator: (v) => _valor(v ?? '') <= 0 ? 'Informe o preço atual' : null),
      const SizedBox(height: 8),
      ValueListenableBuilder<TextEditingValue>(valueListenable: _quantidade, builder: (context, q, child) { final qtd = _valor(q.text); final pm = _valor(_pm.text); final at = _valor(_atual.text); return Text('Investido: $moeda${(qtd * pm).toStringAsFixed(2)}  •  Atual: $moeda${(qtd * at).toStringAsFixed(2)}', style: Theme.of(context).textTheme.bodySmall); }),
      const SizedBox(height: 12),
      InkWell(onTap: _dataPicker, borderRadius: BorderRadius.circular(14), child: InputDecorator(decoration: const InputDecoration(labelText: 'Data da atualização', prefixIcon: Icon(Icons.calendar_today_outlined)), child: Text(DateFormat('dd/MM/yyyy', 'pt_BR').format(_data)))),
      const SizedBox(height: 24),
      SizedBox(width: double.infinity, height: 52, child: FilledButton(onPressed: _salvar, child: Text(widget.investimento == null ? 'Adicionar posição' : 'Salvar alterações'))),
    ]))));
  }

  static const _tiposForm = ['Ações', 'FIIs', 'Stocks', 'ETFs internacionais', 'Criptomoedas', 'Reserva de oportunidade', 'Renda Fixa', 'Outros'];
}

class _Vazio extends StatelessWidget {
  const _Vazio();
  @override Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(26), child: Column(children: [Icon(Icons.auto_graph_rounded, size: 56, color: Theme.of(context).colorScheme.primary), const SizedBox(height: 14), const Text('Sua carteira começa aqui', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)), const SizedBox(height: 8), const Text('Cadastre as posições do Investidor10 e acompanhe ações, FIIs, exterior, cripto e reserva de oportunidade.', textAlign: TextAlign.center)])));
}
