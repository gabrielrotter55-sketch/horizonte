import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/patrimonio_fisico.dart';
import '../../repositories/patrimonio_fisico_repository.dart';
import '../../shared/utils/formatters.dart';

class PatrimonioFisicoPage extends StatefulWidget {
  const PatrimonioFisicoPage({super.key});

  @override
  State<PatrimonioFisicoPage> createState() => _PatrimonioFisicoPageState();
}

class _PatrimonioFisicoPageState extends State<PatrimonioFisicoPage> {
  final _repository = PatrimonioFisicoRepository();
  List<PatrimonioFisico> _itens = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final itens = await _repository.buscarTodos();
    if (!mounted) return;
    setState(() {
      _itens = itens;
      _carregando = false;
    });
  }

  Future<void> _novo([PatrimonioFisico? item]) async {
    final resultado = await showModalBottomSheet<PatrimonioFisico>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _PatrimonioForm(item: item),
    );
    if (resultado == null) return;
    await _repository.salvar(resultado);
    await _carregar();
  }

  Future<void> _excluir(PatrimonioFisico item) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir patrimônio?'),
        content: Text('Remover "${item.nome}" do patrimônio?'),
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
    await _repository.excluir(item.id);
    await _carregar();
  }

  @override
  Widget build(BuildContext context) {
    final valorBruto = _itens.fold<double>(
      0,
      (total, item) => total + item.valorAtual,
    );
    final divida = _itens.fold<double>(
      0,
      (total, item) => total + item.saldoDevedor,
    );
    final liquido = valorBruto - divida;

    return Scaffold(
      appBar: AppBar(title: const Text('Patrimônio físico')),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'patrimonio_fisico_fab',
        onPressed: () => _novo(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Adicionar patrimônio'),
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _carregar,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Patrimônio físico líquido',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            Formatters.moeda(liquido),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: _Resumo(
                                  titulo: 'Valor dos bens',
                                  valor: Formatters.moeda(valorBruto),
                                ),
                              ),
                              Expanded(
                                child: _Resumo(
                                  titulo: 'Dívidas',
                                  valor: Formatters.moeda(divida),
                                  direita: true,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (_itens.isEmpty)
                    const _Vazio()
                  else
                    ..._itens.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _PatrimonioCard(
                          item: item,
                          onEditar: () => _novo(item),
                          onExcluir: () => _excluir(item),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

class _Resumo extends StatelessWidget {
  final String titulo;
  final String valor;
  final bool direita;

  const _Resumo({
    required this.titulo,
    required this.valor,
    this.direita = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          direita ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(titulo, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 3),
        Text(valor, style: const TextStyle(fontWeight: FontWeight.w800)),
      ],
    );
  }
}

class _PatrimonioCard extends StatelessWidget {
  final PatrimonioFisico item;
  final VoidCallback onEditar;
  final VoidCallback onExcluir;

  const _PatrimonioCard({
    required this.item,
    required this.onEditar,
    required this.onExcluir,
  });

  IconData _icone() {
    switch (item.tipo) {
      case 'Moto':
        return Icons.two_wheeler_rounded;
      case 'Carro':
        return Icons.directions_car_rounded;
      case 'Imóvel':
        return Icons.home_work_rounded;
      default:
        return Icons.inventory_2_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              child: Icon(_icone()),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.nome,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.tipo,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    Formatters.moeda(item.valorAtual),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  if (item.financiado)
                    Text(
                      'Financiamento: ${Formatters.moeda(item.saldoDevedor)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  const SizedBox(height: 3),
                  Text(
                    'Patrimônio líquido: ${Formatters.moeda(item.patrimonioLiquido)}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
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
      ),
    );
  }
}

class _PatrimonioForm extends StatefulWidget {
  final PatrimonioFisico? item;

  const _PatrimonioForm({this.item});

  @override
  State<_PatrimonioForm> createState() => _PatrimonioFormState();
}

class _PatrimonioFormState extends State<_PatrimonioForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nome;
  late final TextEditingController _aquisicao;
  late final TextEditingController _atual;
  late final TextEditingController _divida;
  late final TextEditingController _parcela;
  late final TextEditingController _vencimento;
  late final TextEditingController _instituicao;
  late final TextEditingController _observacao;

  String _tipo = 'Moto';
  DateTime? _dataAquisicao;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _nome = TextEditingController(text: item?.nome ?? '');
    _aquisicao = TextEditingController(
      text: item == null ? '' : _formatarNumero(item.valorAquisicao),
    );
    _atual = TextEditingController(
      text: item == null ? '' : _formatarNumero(item.valorAtual),
    );
    _divida = TextEditingController(
      text: item == null ? '' : _formatarNumero(item.saldoDevedor),
    );
    _parcela = TextEditingController(
      text: item == null ? '' : _formatarNumero(item.parcelaFinanciamento),
    );
    _vencimento = TextEditingController(
      text: item?.vencimentoFinanciamento?.toString() ?? '',
    );
    _instituicao = TextEditingController(
      text: item?.instituicaoFinanciamento ?? '',
    );
    _observacao = TextEditingController(text: item?.observacao ?? '');
    _tipo = item?.tipo ?? 'Moto';
    _dataAquisicao = item?.dataAquisicao;
  }

  String _formatarNumero(double valor) =>
      valor.toStringAsFixed(2).replaceAll('.', ',');

  double _valor(String texto) =>
      double.tryParse(texto.replaceAll('.', '').replaceAll(',', '.')) ?? 0;

  @override
  void dispose() {
    _nome.dispose();
    _aquisicao.dispose();
    _atual.dispose();
    _divida.dispose();
    _parcela.dispose();
    _vencimento.dispose();
    _instituicao.dispose();
    _observacao.dispose();
    super.dispose();
  }

  Future<void> _selecionarData() async {
    final data = await showDatePicker(
      context: context,
      initialDate: _dataAquisicao ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
      locale: const Locale('pt', 'BR'),
    );
    if (data != null) setState(() => _dataAquisicao = data);
  }

  void _salvar() {
    if (!_formKey.currentState!.validate()) return;

    final agora = DateTime.now();
    final divida = _valor(_divida.text);
    final vencimento = int.tryParse(_vencimento.text.trim());

    Navigator.pop(
      context,
      PatrimonioFisico(
        id: widget.item?.id ?? agora.microsecondsSinceEpoch.toString(),
        nome: _nome.text.trim(),
        tipo: _tipo,
        valorAquisicao: _valor(_aquisicao.text),
        valorAtual: _valor(_atual.text),
        saldoDevedor: divida,
        parcelaFinanciamento: _valor(_parcela.text),
        vencimentoFinanciamento: divida > 0 ? vencimento : null,
        instituicaoFinanciamento: divida > 0 ? _instituicao.text.trim() : '',
        dataAquisicao: _dataAquisicao,
        observacao: _observacao.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final temDivida = _valor(_divida.text) > 0;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 8, 20, bottom + 20),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.item == null
                      ? 'Novo patrimônio'
                      : 'Editar patrimônio',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nome,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (value) =>
                    value == null || value.trim().isEmpty
                        ? 'Informe o nome'
                        : null,
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _tipo,
                decoration: const InputDecoration(labelText: 'Tipo'),
                items: const [
                  DropdownMenuItem(value: 'Moto', child: Text('Moto')),
                  DropdownMenuItem(value: 'Carro', child: Text('Carro')),
                  DropdownMenuItem(value: 'Imóvel', child: Text('Imóvel')),
                  DropdownMenuItem(value: 'Outro', child: Text('Outro')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _tipo = value);
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _aquisicao,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Valor de aquisição',
                  prefixText: 'R\$ ',
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _atual,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Valor atual estimado',
                  prefixText: 'R\$ ',
                ),
                validator: (value) => _valor(value ?? '') < 0
                    ? 'Informe um valor válido'
                    : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _divida,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Saldo devedor do financiamento',
                  helperText: 'Deixe 0 se o bem estiver quitado.',
                  prefixText: 'R\$ ',
                ),
                onChanged: (_) => setState(() {}),
              ),
              if (temDivida) ...[
                const SizedBox(height: 14),
                TextFormField(
                  controller: _parcela,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Valor da parcela',
                    prefixText: 'R\$ ',
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _vencimento,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Dia do vencimento',
                    hintText: 'Ex.: 10',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return null;
                    final dia = int.tryParse(value);
                    if (dia == null || dia < 1 || dia > 31) {
                      return 'Informe um dia entre 1 e 31';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _instituicao,
                  decoration: const InputDecoration(
                    labelText: 'Instituição do financiamento',
                  ),
                ),
              ],
              const SizedBox(height: 14),
              InkWell(
                onTap: _selecionarData,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Data de aquisição',
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  child: Text(
                    _dataAquisicao == null
                        ? 'Não informada'
                        : DateFormat('dd/MM/yyyy', 'pt_BR').format(_dataAquisicao!),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _observacao,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Observações',
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _salvar,
                  child: Text(
                    widget.item == null
                        ? 'Adicionar patrimônio'
                        : 'Salvar alterações',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Vazio extends StatelessWidget {
  const _Vazio();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.home_work_outlined,
              size: 56,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 14),
            const Text(
              'Nenhum patrimônio físico',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Cadastre sua moto, carro, imóvel ou outro bem e acompanhe também as dívidas vinculadas a ele.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
