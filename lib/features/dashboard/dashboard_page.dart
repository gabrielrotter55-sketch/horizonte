
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../../database/app_database.dart';
import '../../database/database_service.dart';
import '../../models/compromisso.dart';
import '../../repositories/compromisso_repository.dart';
import '../../repositories/beneficio_repository.dart';
import '../../repositories/meta_repository.dart';
import '../../models/meta_financeira.dart';
import '../../repositories/conta_repository.dart';
import '../../repositories/lancamento_repository.dart';
import '../../repositories/patrimonio_repository.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/utils/formatters.dart';
import '../cartoes/pages/cartoes_page.dart';
import '../faturas/pages/faturas_page.dart';
import '../contas/pages/contas_page.dart';
import '../categorias/pages/categorias_page.dart';
import '../compromissos/compromissos_page.dart';
import '../investimentos/investimentos_page.dart';
import '../lancamentos/pages/lancamentos_page.dart';
import '../metas/metas_page.dart';
import '../patrimonio/patrimonio_page.dart';
import '../patrimonio/vr_page.dart';

class DashboardPage extends StatefulWidget {
  final ValueNotifier<int>? refreshNotifier;

  const DashboardPage({super.key, this.refreshNotifier});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _contas = ContaRepository(DatabaseService.instance.database);
  final _lancamentos = LancamentoRepository(DatabaseService.instance.database);
  final _patrimonio = PatrimonioRepository();
  final _compromissos = CompromissoRepository();
  final _beneficios = BeneficioRepository();
  final _metas = MetaRepository();

  late Future<_DashboardData> _future;
  String _nomeUsuario = 'Gabriel';

  @override
  void initState() {
    super.initState();
    _future = _carregar();
    _carregarNomeUsuario();
    widget.refreshNotifier?.addListener(_refreshRequested);
  }

  @override
  void dispose() {
    widget.refreshNotifier?.removeListener(_refreshRequested);
    super.dispose();
  }


  Future<void> _carregarNomeUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) setState(() => _nomeUsuario = prefs.getString('horizonte_nome_usuario_v1') ?? 'Gabriel');
  }

  void _refreshRequested() {
    if (mounted) _atualizar();
  }

  Future<_DashboardData> _carregar() async {
    final agora = DateTime.now();
    final contas = await _contas.buscarTodas();
    final saldoAtual = await _contas.patrimonioTotal();
    final patrimonio = await _patrimonio.resumo();
    final vr = await _beneficios.resumoMes(referencia: agora);
    final metas = await _metas.buscarTodas();
    final apartamento = metas.where((m) => m.nome.toLowerCase().contains('apartamento')).toList();
    final metaApartamento = apartamento.isEmpty ? null : apartamento.first;
    final resumo = await _lancamentos.resumoMensal(mes: agora.month, ano: agora.year);
    final lancamentos = await _lancamentos.buscarTodas();
    lancamentos.sort((a, b) => b.data.compareTo(a.data));
    final proximo = await _compromissos.proximo();

    return _DashboardData(
      saldoAtual: saldoAtual,
      patrimonioTotal: patrimonio.total,
      patrimonioFinanceiro: patrimonio.financeiro,
      patrimonioInvestimentos: patrimonio.investimentos,
      patrimonioFgts: patrimonio.fgts,
      patrimonioFisico: patrimonio.fisico,
      patrimonioBeneficios: patrimonio.beneficios,
      patrimonioMetas: patrimonio.metas,
      vrSaldo: vr.saldoAtual,
      metaApartamento: metaApartamento,
      receitas: resumo.receitas,
      despesas: resumo.despesas,
      taxaEconomia: resumo.taxaEconomia,
      quantidadeContas: contas.length,
      quantidadeLancamentos: lancamentos.length,
      ultimos: lancamentos.take(4).toList(),
      proximoCompromisso: proximo,
    );
  }

  void _atualizar() {
    if (!mounted) return;
    final future = _carregar();
    setState(() {
      _future = future;
    });
  }

  String _saudacao() {
    final hora = DateTime.now().hour;
    if (hora < 12) return 'Bom dia';
    if (hora < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  Future<void> _abrir(Widget page) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    if (mounted) _atualizar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Horizonte')),
      body: FutureBuilder<_DashboardData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('Não foi possível carregar o Dashboard.\n\n${snapshot.error}', textAlign: TextAlign.center),
            ));
          }
          final d = snapshot.data!;
          final resultado = d.receitas - d.despesas;

          return RefreshIndicator(
            onRefresh: () async { _atualizar(); },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
              children: [
                Text('${_saudacao()}, $_nomeUsuario 👋', style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text('Clareza financeira sem culpa.', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 18),

                _SaldoAtualCard(saldo: d.saldoAtual, quantidadeContas: d.quantidadeContas, onTap: () => _abrir(ContasPage())),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(child: _MetricCard(
                      title: 'Resultado do mês',
                      value: '${resultado >= 0 ? '+' : ''}${Formatters.moeda(resultado)}',
                      subtitle: '${Formatters.moeda(d.receitas)} receitas',
                      icon: Icons.trending_up_rounded,
                      positive: resultado >= 0,
                    )),
                    const SizedBox(width: 10),
                    Expanded(child: _MetricCard(
                      title: 'Despesas',
                      value: Formatters.moeda(d.despesas),
                      subtitle: '${(d.taxaEconomia * 100).round()}% de economia',
                      icon: Icons.arrow_upward_rounded,
                      positive: false,
                    )),
                  ],
                ),
                const SizedBox(height: 12),

                _CompromissoDashboardCard(
                  item: d.proximoCompromisso,
                  onTap: () => _abrir(const CompromissosPage()),
                ),
                const SizedBox(height: 12),

                _PatrimonioCompacto(
                  total: d.patrimonioTotal,
                  onTap: () => _abrir(const PatrimonioPage()),
                ),
                const SizedBox(height: 10),
                _PatrimonioDetalhado(data: d),
                const SizedBox(height: 10),
                _BeneficioCard(saldo: d.vrSaldo, onAbrir: () => _abrir(const VrPage())),
                const SizedBox(height: 10),
                if (d.metaApartamento != null) _ApartamentoCard(meta: d.metaApartamento!),
                const SizedBox(height: 18),

                const Text('Resumo do mês', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                _ResumoMensalCard(
                  receitas: d.receitas,
                  despesas: d.despesas,
                  resultado: resultado,
                  taxaEconomia: d.taxaEconomia,
                ),
                const SizedBox(height: 18),

                const Text('Acesso rápido', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _QuickAction(icon: Icons.account_balance_outlined, label: 'Contas', onTap: () => _abrir(ContasPage()))),
                    const SizedBox(width: 8),
                    Expanded(child: _QuickAction(icon: Icons.receipt_long_outlined, label: 'Lançamentos', onTap: () => _abrir(LancamentosPage()))),
                    const SizedBox(width: 8),
                    Expanded(child: _QuickAction(icon: Icons.credit_card_outlined, label: 'Cartões', onTap: () => _abrir(CartoesPage()))),
                    const SizedBox(width: 8),
                    Expanded(child: _QuickAction(icon: Icons.receipt_outlined, label: 'Faturas', onTap: () => _abrir(const FaturasPage()))),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _QuickAction(icon: Icons.category_outlined, label: 'Categorias', onTap: () => _abrir(CategoriasPage()))),
                    const SizedBox(width: 8),
                    Expanded(child: _QuickAction(icon: Icons.show_chart_rounded, label: 'Investimentos', onTap: () => _abrir(const InvestimentosPage()))),
                    const SizedBox(width: 8),
                    Expanded(child: _QuickAction(icon: Icons.flag_outlined, label: 'Metas', onTap: () => _abrir(const MetasPage()))),
                    const SizedBox(width: 8),
                    Expanded(child: _QuickAction(icon: Icons.account_balance_rounded, label: 'FGTS', onTap: () => _abrir(const FgtsPage()))),
                  ],
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    const Expanded(child: Text('Últimos lançamentos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
                    TextButton(onPressed: () => _abrir(LancamentosPage()), child: const Text('Ver todos')),
                  ],
                ),
                const SizedBox(height: 6),
                if (d.ultimos.isEmpty)
                  const Card(child: Padding(padding: EdgeInsets.all(18), child: Text('Nenhum lançamento registrado ainda.')))
                else
                  ...d.ultimos.map((item) => _LancamentoMini(item: item)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SaldoAtualCard extends StatelessWidget {
  final double saldo;
  final int quantidadeContas;
  final VoidCallback onTap;
  const _SaldoAtualCard({required this.saldo, required this.quantidadeContas, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final positivo = saldo >= 0;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withValues(alpha: .82),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(26),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.account_balance_wallet_outlined, color: Colors.white70, size: 20),
          SizedBox(width: 8),
          Text('Saldo atual', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 8),
        Text(Formatters.moeda(saldo), style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
        const SizedBox(height: 5),
        Text(
          positivo
              ? '$quantidadeContas ${quantidadeContas == 1 ? 'conta' : 'contas'} disponíveis'
              : 'Saldo negativo nas contas',
          style: TextStyle(color: positivo ? Colors.white70 : Colors.white),
        ),
          ]),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title, value, subtitle;
  final IconData icon;
  final bool positive;
  const _MetricCard({required this.title, required this.value, required this.subtitle, required this.icon, required this.positive});

  @override
  Widget build(BuildContext context) {
    final cor = positive ? AppColors.success : AppColors.danger;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon, size: 18, color: cor),
            const SizedBox(width: 6),
            Expanded(child: Text(title, style: Theme.of(context).textTheme.bodySmall)),
          ]),
          const SizedBox(height: 8),
          Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: cor)),
          const SizedBox(height: 3),
          Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall),
        ]),
      ),
    );
  }
}

class _CompromissoDashboardCard extends StatelessWidget {
  final Compromisso? item;
  final VoidCallback onTap;
  const _CompromissoDashboardCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (item == null) {
      return Card(
        child: ListTile(
          onTap: onTap,
          leading: CircleAvatar(
            backgroundColor: AppColors.success.withValues(alpha: .12),
            child: const Icon(Icons.check_rounded, color: AppColors.success),
          ),
          title: const Text('Nenhum compromisso próximo', style: TextStyle(fontWeight: FontWeight.w800)),
          subtitle: const Text('Você está em dia por enquanto.'),
          trailing: const Icon(Icons.chevron_right_rounded),
        ),
      );
    }

    final hoje = DateTime.now();
    final dataBase = DateTime(hoje.year, hoje.month, hoje.day);
    final dataItem = DateTime(item!.data.year, item!.data.month, item!.data.day);
    final dias = dataItem.difference(dataBase).inDays;
    final vencido = dias < 0;
    final cor = vencido ? AppColors.danger : (dias <= 3 ? Colors.orange : Theme.of(context).colorScheme.primary);

    String prazo;
    if (vencido) {
      prazo = 'Vencido';
    } else if (dias == 0) {
      prazo = 'Vence hoje';
    } else if (dias == 1) {
      prazo = 'Vence amanhã';
    } else {
      prazo = 'Vence em $dias dias';
    }

    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: cor.withValues(alpha: .12),
          child: Icon(Icons.event_note_outlined, color: cor),
        ),
        title: Text('Próximo compromisso', style: Theme.of(context).textTheme.bodySmall),
        subtitle: Text(item!.descricao, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(Formatters.moeda(item!.valor), style: const TextStyle(fontWeight: FontWeight.w900)),
            Text(prazo, style: TextStyle(fontSize: 11, color: cor, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _PatrimonioCompacto extends StatelessWidget {
  final double total;
  final VoidCallback onTap;
  const _PatrimonioCompacto({required this.total, required this.onTap});

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          onTap: onTap,
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Icon(Icons.insights_outlined, color: Theme.of(context).colorScheme.primary),
          ),
          title: const Text('Patrimônio total', style: TextStyle(fontWeight: FontWeight.w700)),
          subtitle: const Text('Contas + metas + investimentos + patrimônio físico'),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(Formatters.moeda(total), style: const TextStyle(fontWeight: FontWeight.w900)),
              const Icon(Icons.chevron_right_rounded, size: 18),
            ],
          ),
        ),
      );
}


class _PatrimonioDetalhado extends StatelessWidget {
  final _DashboardData data;
  const _PatrimonioDetalhado({required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Composição do patrimônio', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
            const SizedBox(height: 12),
            _linha('Dinheiro em contas', data.patrimonioFinanceiro),
            _linha('Investimentos', data.patrimonioInvestimentos),
            _linha('FGTS', data.patrimonioFgts),
            _linha('VR / benefícios', data.patrimonioBeneficios),
            _linha('Metas', data.patrimonioMetas),
            _linha('Patrimônio físico líquido', data.patrimonioFisico),
            const Divider(height: 18),
            _linha('Total', data.patrimonioTotal, destaque: true),
            const SizedBox(height: 6),
            Text('Metas representam dinheiro já separado e, por isso, entram no patrimônio sem duplicar o saldo das contas.', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _linha(String nome, double valor, {bool destaque = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [
      Expanded(child: Text(nome, style: TextStyle(fontWeight: destaque ? FontWeight.w800 : FontWeight.w500))),
      Text(Formatters.moeda(valor), style: TextStyle(fontWeight: destaque ? FontWeight.w900 : FontWeight.w700)),
    ]),
  );
}

class _BeneficioCard extends StatelessWidget {
  final double saldo;
  final VoidCallback onAbrir;
  const _BeneficioCard({required this.saldo, required this.onAbrir});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          const Icon(Icons.card_giftcard_outlined),
          const SizedBox(width: 8),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('VR Flash', style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(Formatters.moeda(saldo), style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
            const SizedBox(height: 2),
            Text('Saldo atual • carteira de benefício', style: Theme.of(context).textTheme.bodySmall),
          ])),
          IconButton(tooltip: 'Abrir VR', onPressed: onAbrir, icon: const Icon(Icons.chevron_right_rounded)),
        ]),
      ),
    );
  }
}

class _ApartamentoCard extends StatelessWidget {
  final MetaFinanceira meta;
  const _ApartamentoCard({required this.meta});

  @override
  Widget build(BuildContext context) {
    final progresso = meta.progresso;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Row(children: [Icon(Icons.home_outlined), SizedBox(width: 8), Text('Apartamento', style: TextStyle(fontWeight: FontWeight.w800))]),
          const SizedBox(height: 8),
          Row(children: [
            Text(Formatters.moeda(meta.acumulado), style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
            const Spacer(),
            Text('de ${Formatters.moeda(meta.objetivo)}'),
          ]),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: progresso, minHeight: 7),
          const SizedBox(height: 6),
          const Text('Reserva de dinheiro: os aportes saem das contas, rendimentos aumentam a meta e o saldo da meta entra no patrimônio.'),
        ]),
      ),
    );
  }
}

class _ResumoMensalCard extends StatelessWidget {
  final double receitas;
  final double despesas;
  final double resultado;
  final double taxaEconomia;

  const _ResumoMensalCard({
    required this.receitas,
    required this.despesas,
    required this.resultado,
    required this.taxaEconomia,
  });

  @override
  Widget build(BuildContext context) {
    final positivo = resultado >= 0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(child: _item('Receitas', receitas, AppColors.success)),
            const SizedBox(width: 8),
            Expanded(child: _item('Despesas', despesas, AppColors.danger)),
            const SizedBox(width: 8),
            Expanded(child: _item('Resultado', resultado, positivo ? AppColors.success : AppColors.danger, prefix: true)),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Economia', style: Theme.of(context).textTheme.labelSmall),
                const SizedBox(height: 4),
                Text('${(taxaEconomia * 100).round()}%', style: const TextStyle(fontWeight: FontWeight.w900)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _item(String label, double value, Color color, {bool prefix = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11)),
        const SizedBox(height: 4),
        Text(
          '${prefix && value >= 0 ? '+' : ''}${Formatters.moeda(value)}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontWeight: FontWeight.w900, color: color, fontSize: 12),
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
            child: Column(children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 6),
              Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
            ]),
          ),
        ),
      );
}

class _LancamentoMini extends StatelessWidget {
  final Lancamento item;
  const _LancamentoMini({required this.item});

  @override
  Widget build(BuildContext context) {
    final positivo = item.receita;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: (positivo ? AppColors.success : AppColors.danger).withValues(alpha: .12),
          child: Icon(
            positivo ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
            color: positivo ? AppColors.success : AppColors.danger,
          ),
        ),
        title: Text(item.descricao, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(DateFormat('dd/MM/yyyy', 'pt_BR').format(item.data)),
        trailing: Text(
          '${positivo ? '+' : '-'}${Formatters.moeda(item.valor)}',
          style: TextStyle(fontWeight: FontWeight.w800, color: positivo ? AppColors.success : AppColors.danger),
        ),
      ),
    );
  }
}

class _DashboardData {
  final double saldoAtual;
  final double patrimonioTotal;
  final double patrimonioFinanceiro;
  final double patrimonioInvestimentos;
  final double patrimonioFgts;
  final double patrimonioFisico;
  final double patrimonioBeneficios;
  final double patrimonioMetas;
  final double vrSaldo;
  final MetaFinanceira? metaApartamento;
  final double receitas;
  final double despesas;
  final double taxaEconomia;
  final int quantidadeContas;
  final int quantidadeLancamentos;
  final List<Lancamento> ultimos;
  final Compromisso? proximoCompromisso;

  const _DashboardData({
    required this.saldoAtual,
    required this.patrimonioTotal,
    required this.patrimonioFinanceiro,
    required this.patrimonioInvestimentos,
    required this.patrimonioFgts,
    required this.patrimonioFisico,
    required this.patrimonioBeneficios,
    required this.patrimonioMetas,
    required this.vrSaldo,
    required this.metaApartamento,
    required this.receitas,
    required this.despesas,
    required this.taxaEconomia,
    required this.quantidadeContas,
    required this.quantidadeLancamentos,
    required this.ultimos,
    required this.proximoCompromisso,
  });
}
