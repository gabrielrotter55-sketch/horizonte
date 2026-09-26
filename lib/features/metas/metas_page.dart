import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/meta_financeira.dart';
import '../../models/meta_deposito.dart';
import '../../models/meta_agrupamento.dart';
import '../../repositories/meta_agrupamento_repository.dart';
import '../../repositories/meta_repository.dart';
import '../../repositories/meta_deposito_repository.dart';
import '../../repositories/conta_repository.dart';
import '../../database/database_service.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/utils/formatters.dart';
import '../../services/financeiro_notifier.dart';

class MetasPage extends StatefulWidget {
  const MetasPage({super.key});

  @override
  State<MetasPage> createState() => _MetasPageState();
}

class _MetasPageState extends State<MetasPage> {
  final _repository = MetaRepository();
  final _agrupamentoRepository = MetaAgrupamentoRepository();
  final _depositoRepository = MetaDepositoRepository();
  final _contaRepository = ContaRepository(DatabaseService.instance.database);
  List<MetaFinanceira> _metas = [];
  bool _carregando = true;
  String _usuario = 'Gabriel';
  String _parceiro = 'Natália';
  List<MetaAgrupamento> _grupos = [];

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final prefs = await SharedPreferences.getInstance();
    final usuario = prefs.getString('horizonte_nome_usuario_v1') ?? 'Gabriel';
    final parceiro = prefs.getString('horizonte_nome_parceiro_v1') ?? 'Natália';
    final metas = await _repository.buscarTodas();
    final grupos = await _agrupamentoRepository.buscarTodos();
    // O saldo da meta é um ativo separado: aportes reais reduzem a conta de origem,
    // rendimentos aumentam a meta e saldos históricos não movimentam contas.
    for (final meta in metas) {
      final total = await _depositoRepository.totalDaMeta(meta.id);
      if ((meta.acumulado - total).abs() > 0.005) {
        await _repository.salvar(meta.copyWith(acumulado: total));
      }
    }
    final atualizadas = await _repository.buscarTodas();
    if (!mounted) return;
    setState(() {
      _metas = atualizadas;
      _usuario = usuario;
      _parceiro = parceiro;
      _grupos = grupos;
      _carregando = false;
    });
  }

  bool _isUsuario(String pessoa) => pessoa == _usuario || pessoa == 'Gabriel';
  bool _isParceiro(String pessoa) => pessoa == _parceiro || pessoa == 'Natália';
  String _nomePessoa(String pessoa) {
    if (_isUsuario(pessoa)) return _usuario;
    if (_isParceiro(pessoa)) return _parceiro;
    return pessoa;
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
    if (meta.saldoInicialGabriel > 0) await _depositoRepository.salvar(MetaDeposito(id:'${meta.id}-ini-g',metaId:meta.id,pessoa:_usuario,valor:meta.saldoInicialGabriel,data:meta.criadoEm,descricao:'Saldo inicial da meta',origem:'saldo_inicial:${meta.id}',tipo:'aporte'));
    if (meta.saldoInicialNatalia > 0) await _depositoRepository.salvar(MetaDeposito(id:'${meta.id}-ini-n',metaId:meta.id,pessoa:_parceiro,valor:meta.saldoInicialNatalia,data:meta.criadoEm,descricao:'Saldo inicial da meta',origem:'saldo_inicial:${meta.id}',tipo:'aporte'));
    if (meta.rendimentoInicial > 0) await _depositoRepository.salvar(MetaDeposito(id:'${meta.id}-ini-r',metaId:meta.id,pessoa:'Meta',valor:meta.rendimentoInicial,data:meta.criadoEm,descricao:'Rendimento inicial da meta',origem:'saldo_inicial:${meta.id}',tipo:'rendeu'));
    await _sincronizarAcumulado(meta.id);
    FinanceiroNotifier.bump();
    await _carregar();
  }

  Future<void> _editarMeta(MetaFinanceira meta) async {
    final historico = await _depositoRepository.buscarDaMeta(meta.id);
    final saldoGabriel = historico
        .where((d) => (d.origem == 'saldo_inicial' || d.origem.startsWith('saldo_inicial:')) && d.isAporte && _isUsuario(d.pessoa))
        .fold<double>(0, (s, d) => s + d.valor);
    final saldoNatalia = historico
        .where((d) => (d.origem == 'saldo_inicial' || d.origem.startsWith('saldo_inicial:')) && d.isAporte && _isParceiro(d.pessoa))
        .fold<double>(0, (s, d) => s + d.valor);
    final rendimentoInicial = historico
        .where((d) => (d.origem == 'saldo_inicial' || d.origem.startsWith('saldo_inicial:')) && d.isRendimento)
        .fold<double>(0, (s, d) => s + d.valor);

    final atualizada = await showModalBottomSheet<MetaFinanceira>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _MetaFormSheet(
        meta: meta,
        historicoGabriel: saldoGabriel,
        historicoNatalia: saldoNatalia,
        historicoRendimento: rendimentoInicial,
      ),
    );
    if (atualizada == null) return;

    await _repository.salvar(atualizada.copyWith(
      saldoInicialGabriel: historicoGabrielValue(atualizada),
      saldoInicialNatalia: historicoNataliaValue(atualizada),
      rendimentoInicial: historicoRendimentoValue(atualizada),
    ));

    // Atualiza apenas os lançamentos históricos. Eles nunca movimentam contas.
    await _depositoRepository.excluirHistoricosIniciais(meta.id);
    await _salvarHistoricoInicial(
      atualizada,
      historicoGabrielValue(atualizada),
      historicoNataliaValue(atualizada),
      historicoRendimentoValue(atualizada),
    );
    await _sincronizarAcumulado(atualizada.id);
    await _carregar();
  }

  double historicoGabrielValue(MetaFinanceira meta) => meta.saldoInicialGabriel;
  double historicoNataliaValue(MetaFinanceira meta) => meta.saldoInicialNatalia;
  double historicoRendimentoValue(MetaFinanceira meta) => meta.rendimentoInicial;

  Future<void> _salvarHistoricoInicial(MetaFinanceira meta, double gabriel, double natalia, double rendimento) async {
    final data = meta.criadoEm;
    if (gabriel > 0) {
      await _depositoRepository.salvar(MetaDeposito(
        id: '${meta.id}-ini-g', metaId: meta.id, pessoa: _usuario, valor: gabriel,
        data: data, descricao: 'Saldo inicial da meta', origem: 'saldo_inicial:${meta.id}', tipo: 'aporte',
      ));
    }
    if (natalia > 0) {
      await _depositoRepository.salvar(MetaDeposito(
        id: '${meta.id}-ini-n', metaId: meta.id, pessoa: _parceiro, valor: natalia,
        data: data, descricao: 'Saldo inicial da meta', origem: 'saldo_inicial:${meta.id}', tipo: 'aporte',
      ));
    }
    if (rendimento > 0) {
      await _depositoRepository.salvar(MetaDeposito(
        id: '${meta.id}-ini-r', metaId: meta.id, pessoa: 'Meta', valor: rendimento,
        data: data, descricao: 'Rendimento inicial da meta', origem: 'saldo_inicial:${meta.id}', tipo: 'rendeu',
      ));
    }
  }

  Future<void> _agruparMeta(MetaFinanceira meta) async {
    final grupos = await _agrupamentoRepository.buscarTodos();
    final individuais = _metas.where((item) => item.id != meta.id).toList();
    if (individuais.isEmpty && grupos.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Crie pelo menos mais uma meta para agrupar.')));
      return;
    }

    final escolha = await showModalBottomSheet<_AgrupamentoEscolha>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            const Padding(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12), child: Text('Agrupar meta', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800))),
            if (individuais.isNotEmpty) ...[
              const Padding(padding: EdgeInsets.fromLTRB(8, 8, 8, 4), child: Text('Criar novo agrupamento com uma meta', style: TextStyle(fontWeight: FontWeight.w700))),
              ...individuais.map((item) => ListTile(
                leading: CircleAvatar(backgroundColor: Color(item.cor).withValues(alpha: .12), child: Icon(Icons.flag_outlined, color: Color(item.cor))),
                title: Text(item.nome),
                subtitle: Text(item.grupoId != null ? 'Somente esta meta • mantém os grupos existentes' : 'Novo agrupamento • ${Formatters.moeda(item.acumulado)}'),
                onTap: () => Navigator.of(sheetContext).pop(_AgrupamentoEscolha.individual(item)),
              )),
            ],
            if (grupos.isNotEmpty) ...[
              const Padding(padding: EdgeInsets.fromLTRB(8, 16, 8, 4), child: Text('Adicionar a um grupo existente', style: TextStyle(fontWeight: FontWeight.w700))),
              ...grupos.map((grupo) {
                final itens = _metas.where((m) => grupo.metaIds.contains(m.id)).toList();
                final total = itens.fold<double>(0, (sum, item) => sum + item.acumulado);
                final pertence = grupo.metaIds.contains(meta.id);
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.link_rounded)),
                  title: Text(grupo.nome),
                  subtitle: Text('${itens.length} metas • ${Formatters.moeda(total)}${pertence ? ' • já participa' : ''}'),
                  enabled: !pertence,
                  onTap: pertence ? null : () => Navigator.of(sheetContext).pop(_AgrupamentoEscolha.grupo(grupo.id, grupo.nome)),
                );
              }),
            ],
          ],
        ),
      ),
    );
    if (escolha == null || !mounted) return;

    if (escolha.grupoId != null) {
      final grupo = grupos.firstWhere((g) => g.id == escolha.grupoId);
      if (!grupo.metaIds.contains(meta.id)) {
        await _agrupamentoRepository.salvar(grupo.copyWith(metaIds: [...grupo.metaIds, meta.id]));
      }
    } else if (escolha.meta != null) {
      final nome = await showDialog<String>(context: context, builder: (_) => const _NomeGrupoDialog(nomeInicial: ''));
      if (nome == null || nome.trim().isEmpty) return;
      await _agrupamentoRepository.salvar(MetaAgrupamento(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        nome: nome.trim(),
        metaIds: [meta.id, escolha.meta!.id],
      ));
    }
    await _carregar();
  }

  Future<void> _desagruparMeta(MetaFinanceira meta) async {
    final grupos = await _agrupamentoRepository.buscarTodos();
    final pertencentes = grupos.where((g) => g.metaIds.contains(meta.id)).toList();
    if (pertencentes.isEmpty) return;
    final escolha = await showDialog<_DesagrupamentoEscolha>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Desagrupar meta'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              const Text('Escolha o grupo e se quer remover apenas esta meta ou o grupo inteiro.'),
              const SizedBox(height: 12),
              ...pertencentes.map((g) => ListTile(
                leading: const Icon(Icons.link_rounded),
                title: Text(g.nome),
                subtitle: Text('${g.metaIds.length} metas'),
                onTap: () => showDialog<String>(
                  context: dialogContext,
                  builder: (c) => AlertDialog(
                    title: Text(g.nome),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(c, 'cancelar'), child: const Text('Cancelar')),
                      TextButton(onPressed: () => Navigator.pop(c, 'meta'), child: const Text('Remover só esta meta')),
                      FilledButton(onPressed: () => Navigator.pop(c, 'grupo'), child: const Text('Excluir grupo')),
                    ],
                  ),
                ).then((op) {
                  if (op == 'meta') Navigator.pop(dialogContext, _DesagrupamentoEscolha(g.id, false));
                  if (op == 'grupo') Navigator.pop(dialogContext, _DesagrupamentoEscolha(g.id, true));
                }),
              )),
            ],
          ),
        ),
      ),
    );
    if (escolha == null) return;
    final grupo = pertencentes.firstWhere((g) => g.id == escolha.grupoId);
    if (escolha.excluirGrupo) {
      await _agrupamentoRepository.excluir(grupo.id);
    } else {
      final ids = grupo.metaIds.where((id) => id != meta.id).toList();
      if (ids.length < 2) {
        await _agrupamentoRepository.excluir(grupo.id);
      } else {
        await _agrupamentoRepository.salvar(grupo.copyWith(metaIds: ids));
      }
    }
    await _carregar();
  }


  Future<void> _renomearGrupo(String grupoId, String nomeAtual) async {
    final nome = await showDialog<String>(context: context, builder: (_) => _NomeGrupoDialog(nomeInicial: nomeAtual));
    if (nome == null || nome.trim().isEmpty) return;
    final grupo = (await _agrupamentoRepository.buscarTodos()).firstWhere((g) => g.id == grupoId);
    await _agrupamentoRepository.salvar(grupo.copyWith(nome: nome.trim()));
    await _carregar();
  }

  Future<void> _desagruparGrupo(String grupoId) async {
    await _agrupamentoRepository.excluir(grupoId);
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
    for (final grupo in await _agrupamentoRepository.buscarTodos()) {
      if (!grupo.metaIds.contains(meta.id)) continue;
      final ids = grupo.metaIds.where((id) => id != meta.id).toList();
      if (ids.length < 2) {
        await _agrupamentoRepository.excluir(grupo.id);
      } else {
        await _agrupamentoRepository.salvar(grupo.copyWith(metaIds: ids));
      }
    }
    await _carregar();
  }

  Future<void> _registrarAporte(MetaFinanceira meta) async {
    final contas = await _contaRepository.buscarTodas();
    if (!mounted) return;
    final deposito = await showDialog<MetaDeposito>(
      context: context,
      builder: (_) => _RegistrarDepositoDialog(meta: meta, contas: contas, usuario: _usuario, parceiro: _parceiro),
    );
    if (deposito == null) return;
    try {
      await _depositoRepository.salvar(deposito);
      FinanceiroNotifier.bump();
      await _sincronizarAcumulado(meta.id);
      await _carregar();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível adicionar o depósito.')),
      );
    }
  }

  Future<void> _sincronizarAcumulado(String metaId) async {
    final metas = await _repository.buscarTodas();
    final grupos = await _agrupamentoRepository.buscarTodos();
    final encontrados = metas.where((item) => item.id == metaId).toList();
    final meta = encontrados.isEmpty ? null : encontrados.first;
    if (meta == null) return;

    final total = await _depositoRepository.totalDaMeta(metaId);
    await _repository.salvar(meta.copyWith(acumulado: total));
  }

  Future<void> _mostrarDepositos(MetaFinanceira meta) async {
    final depositos = await _depositoRepository.buscarDaMeta(meta.id);
    final totais = <String, double>{};
    for (final deposito in depositos.where((item) => item.isAporte)) {
      final pessoa = _nomePessoa(deposito.pessoa);
      totais[pessoa] = (totais[pessoa] ?? 0) + deposito.valor;
    }

    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => _DepositosSheet(
        meta: meta,
        depositos: depositos,
        totais: totais,
        usuario: _usuario,
        parceiro: _parceiro,
        nomePessoa: _nomePessoa,
        onExcluir: (deposito) async {
          await _depositoRepository.excluir(deposito.id);
          FinanceiroNotifier.bump();
          await _sincronizarAcumulado(meta.id);
          if (!sheetContext.mounted) return;
          Navigator.of(sheetContext).pop();
          if (!mounted) return;
          await _carregar();
        },
      ),
    );
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
                      if (_grupos.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _GruposMetas(metas: _metas, grupos: _grupos),
                      ],
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
                            onAgrupar: () => _agruparMeta(meta),
                            onDesagrupar: () => _desagruparMeta(meta),
                            agrupada: _grupos.any((g) => g.metaIds.contains(meta.id)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

class _DesagrupamentoEscolha {
  final String grupoId;
  final bool excluirGrupo;
  const _DesagrupamentoEscolha(this.grupoId, this.excluirGrupo);
}

class _AgrupamentoEscolha {
  final MetaFinanceira? meta;
  final String? grupoId;
  final String? grupoNome;
  const _AgrupamentoEscolha._({this.meta, this.grupoId, this.grupoNome});
  factory _AgrupamentoEscolha.individual(MetaFinanceira meta) => _AgrupamentoEscolha._(meta: meta);
  factory _AgrupamentoEscolha.grupo(String id, String nome) => _AgrupamentoEscolha._(grupoId: id, grupoNome: nome);
}

class _GruposMetas extends StatelessWidget {
  final List<MetaFinanceira> metas;
  final List<MetaAgrupamento> grupos;

  const _GruposMetas({required this.metas, required this.grupos});

  @override
  Widget build(BuildContext context) {
    if (grupos.isEmpty) return const SizedBox.shrink();

    final gruposComMetas = grupos.map((grupo) {
      final itens = metas.where((m) => grupo.metaIds.contains(m.id)).toList();
      return (grupo: grupo, itens: itens);
    }).where((e) => e.itens.isNotEmpty).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Metas agrupadas', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            const Text("Para separar apenas uma meta, use o botão 'Desagrupar' na própria meta abaixo.", style: TextStyle(fontSize: 12)),
            const SizedBox(height: 10),
            ...gruposComMetas.map((entry) {
              final itens = entry.itens;
              final grupo = entry.grupo;
              final total = itens.fold<double>(0, (s, item) => s + item.acumulado);
              final objetivo = itens.fold<double>(0, (s, item) => s + item.objetivo);
              final nome = grupo.nome;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(child: Icon(Icons.link_rounded)),
                  title: Text(nome, style: const TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: Text('${itens.length} metas • ${Formatters.moeda(total)} de ${Formatters.moeda(objetivo)}'),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(Formatters.moeda(total), style: const TextStyle(fontWeight: FontWeight.w900)),
                  PopupMenuButton<String>(
                    onSelected: (op) async {
                      if (op == 'renomear') {
                        final state = context.findAncestorStateOfType<_MetasPageState>();
                        if (state != null) await state._renomearGrupo(grupo.id, nome);
                      } else if (op == 'desagrupar') {
                        final state = context.findAncestorStateOfType<_MetasPageState>();
                        if (state != null) await state._desagruparGrupo(grupo.id);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'renomear', child: Text('Renomear grupo')),
                      PopupMenuItem(value: 'desagrupar', child: Text('Desagrupar...')),
                    ],
                  ),
                ]),
                ),
              );
            }),
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
  final VoidCallback onAgrupar;
  final VoidCallback onDesagrupar;
  final bool agrupada;

  const _MetaCard({
    required this.meta,
    required this.onAporte,
    required this.onEditar,
    required this.onExcluir,
    required this.onDetalhes,
    required this.onAgrupar,
    required this.onDesagrupar,
    this.agrupada = false,
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
                        '${meta.conjunta ? 'Meta conjunta' : 'Meta individual'} • ${prazo == null ? 'Sem prazo definido' : 'Prazo: $prazo'}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (opcao) {
                    if (opcao == 'editar') onEditar();
                    if (opcao == 'excluir') onExcluir();
                    if (opcao == 'agrupar') onAgrupar();
                    if (opcao == 'desagrupar') onDesagrupar();
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'editar', child: Text('Editar')),
                    const PopupMenuItem(value: 'agrupar', child: Text('Agrupar com outra meta')),
                    if (agrupada) const PopupMenuItem(value: 'desagrupar', child: Text('Desagrupar meta')),
                    const PopupMenuItem(value: 'excluir', child: Text('Excluir')),
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
            if (agrupada) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: onDesagrupar,
                  icon: const Icon(Icons.link_off_rounded, size: 18),
                  label: const Text('Desagrupar esta meta'),
                ),
              ),
            ],
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
  final String usuario;
  final String parceiro;
  final String Function(String) nomePessoa;
  final Future<void> Function(MetaDeposito) onExcluir;

  const _DepositosSheet({
    required this.meta,
    required this.depositos,
    required this.totais,
    required this.usuario,
    required this.parceiro,
    required this.nomePessoa,
    required this.onExcluir,
  });

  @override
  Widget build(BuildContext context) {
    // O total acumulado considera aportes + rendimentos.
    final total = depositos.fold<double>(0, (s, item) => s + item.valor);
    // A divisão entre Gabriel e Natália considera somente aportes.
    final aportes = depositos.where((item) => item.isAporte).fold<double>(0, (s, item) => s + item.valor);
    final rendimentos = depositos.where((item) => item.isRendimento).fold<double>(0, (s, item) => s + item.valor);
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
                Expanded(child: _PessoaTotal(nome: usuario, valor: totais[usuario] ?? 0, total: aportes)),
                if (meta.conjunta) ...[
                  const SizedBox(width: 12),
                  Expanded(child: _PessoaTotal(nome: parceiro, valor: totais[parceiro] ?? 0, total: aportes)),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _ResumoValor(titulo: 'Aportes', valor: Formatters.moeda(aportes))),
                Expanded(child: _ResumoValor(titulo: 'Rendeu', valor: Formatters.moeda(rendimentos), alinhadoDireita: true)),
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
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final deposito = depositos[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        child: Text(deposito.isRendimento ? 'R' : deposito.pessoa.substring(0, 1)),
                      ),
                      title: Text(
                        deposito.isRendimento ? 'Rendimento da meta' : nomePessoa(deposito.pessoa),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        '${DateFormat('dd/MM/yyyy • HH:mm', 'pt_BR').format(deposito.data)} • ${deposito.isRendimento ? 'Rendimento' : 'Aporte'}',
                      ),
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
                                  content: Text('${deposito.isRendimento ? 'Rendimento da meta' : nomePessoa(deposito.pessoa)} • ${Formatters.moeda(deposito.valor)}'),
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

class _NomeGrupoDialog extends StatefulWidget {
  final String nomeInicial;
  const _NomeGrupoDialog({required this.nomeInicial});
  @override State<_NomeGrupoDialog> createState() => _NomeGrupoDialogState();
}
class _NomeGrupoDialogState extends State<_NomeGrupoDialog> {
  late final TextEditingController _controller;
  @override void initState(){super.initState();_controller=TextEditingController(text:widget.nomeInicial);}
  @override void dispose(){_controller.dispose();super.dispose();}
  @override Widget build(BuildContext context)=>AlertDialog(
    title:const Text('Nome do agrupamento'),
    content:TextField(controller:_controller,decoration:const InputDecoration(labelText:'Nome',hintText:'Ex.: Apartamento')),
    actions:[TextButton(onPressed:()=>Navigator.of(context).pop(),child:const Text('Cancelar')),FilledButton(onPressed:()=>Navigator.of(context).pop(_controller.text.trim()),child:const Text('Agrupar'))],
  );
}

class _RegistrarDepositoDialog extends StatefulWidget {
  final MetaFinanceira meta;
  final List<dynamic> contas;
  final String usuario;
  final String parceiro;
  const _RegistrarDepositoDialog({required this.meta, required this.contas, required this.usuario, required this.parceiro});
  @override State<_RegistrarDepositoDialog> createState()=>_RegistrarDepositoDialogState();
}
class _RegistrarDepositoDialogState extends State<_RegistrarDepositoDialog> {
  final _formKey=GlobalKey<FormState>();
  late final TextEditingController _valor;
  late String _pessoa;
  String _tipo='aporte';
  int? _contaId;
  @override void initState(){super.initState();_valor=TextEditingController();_pessoa=widget.usuario;}
  @override void dispose(){_valor.dispose();super.dispose();}
  double _parse(String s)=>double.tryParse(s.replaceAll('.','').replaceAll(',','.'))??double.nan;
  void _salvar(){
    if(!_formKey.currentState!.validate()) return;
    final agora=DateTime.now();
    Navigator.of(context).pop(MetaDeposito(
      id:agora.microsecondsSinceEpoch.toString(),metaId:widget.meta.id,
      pessoa:_tipo=='rendeu'?'Meta':_pessoa,valor:_parse(_valor.text),data:agora,
      descricao:_tipo=='rendeu'?'Rendimento da meta':'Aporte na meta',origem:'manual',tipo:_tipo,
      contaId:_tipo=='aporte'?_contaId:null,
    ));
  }
  @override Widget build(BuildContext context){
    final bottom=MediaQuery.viewInsetsOf(context).bottom;
    return AlertDialog(
      insetPadding:const EdgeInsets.symmetric(horizontal:24,vertical:24),
      title:const Text('Adicionar depósito'),
      content:SingleChildScrollView(padding:EdgeInsets.only(bottom:bottom),child:Form(key:_formKey,child:Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.start,children:[
        const Text('Natureza do valor',style:TextStyle(fontWeight:FontWeight.w700)),const SizedBox(height:8),
        SegmentedButton<String>(segments:const[ButtonSegment(value:'aporte',label:Text('Aporte')),ButtonSegment(value:'rendeu',label:Text('Rendeu'))],selected:{_tipo},onSelectionChanged:(s)=>setState(()=>_tipo=s.first)),
        if(_tipo=='aporte')...[
          if (widget.meta.conjunta) ...[
            const SizedBox(height:12),const Text('Quem fez o aporte?',style:TextStyle(fontWeight:FontWeight.w700)),const SizedBox(height:10),
            SegmentedButton<String>(segments:[ButtonSegment(value:widget.usuario,label:Text(widget.usuario)),ButtonSegment(value:widget.parceiro,label:Text(widget.parceiro))],selected:{_pessoa},onSelectionChanged:(s)=>setState(()=>_pessoa=s.first)),
            const SizedBox(height:16),
          ],
          DropdownButtonFormField<int>(initialValue:widget.contas.any((c)=>c.id==_contaId)?_contaId:null,decoration:const InputDecoration(labelText:'Conta de origem'),items:widget.contas.map<DropdownMenuItem<int>>((c)=>DropdownMenuItem(value:c.id,child:Text(c.nome))).toList(),onChanged:(v)=>setState(()=>_contaId=v),validator:(v)=>v==null?'Selecione a conta de origem.':null),
        ] else ...[
          const SizedBox(height:12),Text('Rendimento pertence à própria meta e não reduz nenhuma conta.',style:Theme.of(context).textTheme.bodySmall),
        ],
        const SizedBox(height:16),TextFormField(controller:_valor,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:const InputDecoration(labelText:'Valor',prefixText:'R\$ ',hintText:'0,00'),validator:(v)=>_parse(v??'').isFinite&&_parse(v??'')>0?null:'Informe um valor maior que zero.'),
      ]))),
      actions:[TextButton(onPressed:()=>Navigator.of(context).pop(),child:const Text('Cancelar')),FilledButton(onPressed:_salvar,child:const Text('Adicionar'))],
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
            Text('${percentual.toStringAsFixed(1)}% dos aportes', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _MetaFormSheet extends StatefulWidget {
  final MetaFinanceira? meta;
  final double historicoGabriel;
  final double historicoNatalia;
  final double historicoRendimento;

  const _MetaFormSheet({this.meta, this.historicoGabriel = 0, this.historicoNatalia = 0, this.historicoRendimento = 0});

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
  bool _conjunta = false;
  String _usuario = 'Gabriel';
  String _parceiro = 'Natália';
  List<MetaAgrupamento> _grupos = [];
  late final TextEditingController _gabrielInicial;
  late final TextEditingController _nataliaInicial;
  late final TextEditingController _rendimentoInicial;

  @override
  void initState() {
    super.initState();
    final meta = widget.meta;
    SharedPreferences.getInstance().then((prefs) {
      if (!mounted) return;
      setState(() {
        _usuario = prefs.getString('horizonte_nome_usuario_v1') ?? 'Gabriel';
        _parceiro = prefs.getString('horizonte_nome_parceiro_v1') ?? 'Natália';
      });
    });
    _nome = TextEditingController(text: meta?.nome ?? '');
    _objetivo = TextEditingController(
      text: meta == null ? '' : meta.objetivo.toStringAsFixed(2).replaceAll('.', ','),
    );
    _acumulado = TextEditingController(
      text: meta == null ? '' : meta.acumulado.toStringAsFixed(2).replaceAll('.', ','),
    );
    _prazo = meta?.prazo;
    _cor = meta?.cor ?? _cor;
    _conjunta = meta?.conjunta ?? false;
    _gabrielInicial = TextEditingController(text: widget.historicoGabriel > 0 ? widget.historicoGabriel.toStringAsFixed(2).replaceAll('.', ',') : '');
    _nataliaInicial = TextEditingController(text: widget.historicoNatalia > 0 ? widget.historicoNatalia.toStringAsFixed(2).replaceAll('.', ',') : '');
    _rendimentoInicial = TextEditingController(text: widget.historicoRendimento > 0 ? widget.historicoRendimento.toStringAsFixed(2).replaceAll('.', ',') : '');
  }

  @override
  void dispose() {
    _nome.dispose();
    _objetivo.dispose();
    _acumulado.dispose();
    _gabrielInicial.dispose(); _nataliaInicial.dispose(); _rendimentoInicial.dispose();
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
      acumulado: widget.meta == null ? 0 : _valor(_acumulado.text),
      conjunta: _conjunta,
      saldoInicialGabriel: _valor(_gabrielInicial.text),
      saldoInicialNatalia: _conjunta ? _valor(_nataliaInicial.text) : 0,
      rendimentoInicial: _valor(_rendimentoInicial.text),
      grupoId: widget.meta?.grupoId,
      grupoNome: widget.meta?.grupoNome,
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
              SwitchListTile.adaptive(contentPadding: EdgeInsets.zero, title: const Text('Meta conjunta'), subtitle: Text(_conjunta ? '$_usuario e $_parceiro podem aportar na mesma meta.' : 'Meta individual.'), value: _conjunta, onChanged: (v) => setState(() => _conjunta = v)),
              const SizedBox(height: 8),
                const Text('Saldo que já existia antes do Horizonte', style: TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                const Text('Esses valores são históricos e não saem de nenhuma conta atual.'),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: TextFormField(controller: _gabrielInicial, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: _usuario, prefixText: 'R\$ '))),
                  if (_conjunta) ...[
                    const SizedBox(width: 10),
                    Expanded(child: TextFormField(controller: _nataliaInicial, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: _parceiro, prefixText: 'R\$ '))),
                  ],
                ]),
                const SizedBox(height: 10),
                TextFormField(controller: _rendimentoInicial, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Rendimento já acumulado', prefixText: 'R\$ ')),
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
