import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  double _parse(String texto) {
    final normalizado = texto.trim().replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(normalizado) ?? 0;
  }

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
    final c = TextEditingController(text: _usd.toStringAsFixed(2).replaceAll('.', ','));
    final valor = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cotação do dólar'),
        content: TextField(
          controller: c,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: r'US$ 1,00 vale',
            prefixText: 'R\$ ',
            suffixText: ' BRL',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              final v = _parse(c.text);
              if (v > 0 && v.isFinite) Navigator.pop(ctx, v);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
    c.dispose();
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
