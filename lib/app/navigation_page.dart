import 'package:flutter/material.dart';

import '../features/configuracoes/configuracoes_page.dart';
import '../features/contas/pages/nova_transferencia_page.dart';
import '../features/dashboard/dashboard_page.dart';
import '../features/investimentos/investimentos_page.dart';
import '../features/lancamentos/pages/lancamentos_page.dart';
import '../features/lancamentos/pages/novo_lancamento_page.dart';
import '../features/metas/metas_page.dart';
import '../features/metas/guardar_meta_page.dart';
import '../services/theme_controller.dart';

class NavigationPage extends StatefulWidget {
  final ThemeController? themeController;

  const NavigationPage({super.key, this.themeController});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  int _currentIndex = 0;
  final ValueNotifier<int> _dashboardRefreshNotifier = ValueNotifier<int>(0);

  late final List<Widget> _pages = [
    DashboardPage(refreshNotifier: _dashboardRefreshNotifier),
    LancamentosPage(),
    const InvestimentosPage(),
    const MetasPage(),
    ConfiguracoesPage(themeController: widget.themeController),
  ];

  @override
  void dispose() {
    _dashboardRefreshNotifier.dispose();
    super.dispose();
  }

  void _selecionarPagina(int index) {
    setState(() => _currentIndex = index);
    if (index == 0) {
      _dashboardRefreshNotifier.value++;
    }
  }

  Future<void> _abrirNovaMovimentacao() async {
    final resultado = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        final alturaMaxima = MediaQuery.sizeOf(sheetContext).height * 0.78;
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: alturaMaxima),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                children: [
                const Text(
                  'Nova movimentação',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFFEE2E2),
                    child: Icon(Icons.arrow_upward_rounded, color: Colors.red),
                  ),
                  title: const Text('Despesa'),
                  subtitle: const Text('Registrar uma compra ou pagamento.'),
                  onTap: () => Navigator.pop(sheetContext, 'despesa'),
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFDCFCE7),
                    child: Icon(Icons.arrow_downward_rounded, color: Colors.green),
                  ),
                  title: const Text('Receita'),
                  subtitle: const Text('Registrar salário, PIX ou outra entrada.'),
                  onTap: () => Navigator.pop(sheetContext, 'receita'),
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFEDE9FE),
                    child: Icon(Icons.swap_horiz_rounded, color: Colors.deepPurple),
                  ),
                  title: const Text('Transferência'),
                  subtitle: const Text('Mover dinheiro entre suas contas.'),
                  onTap: () => Navigator.pop(sheetContext, 'transferencia'),
                ),
                ListTile(leading: const CircleAvatar(backgroundColor: Color(0xFFFEF3C7), child: Icon(Icons.flag_outlined, color: Colors.orange)), title: const Text('Guardar na Meta'), subtitle: const Text('Separar dinheiro para uma meta.'), onTap: () => Navigator.pop(sheetContext, 'meta')),
                ListTile(leading: const CircleAvatar(backgroundColor: Color(0xFFDCFCE7), child: Icon(Icons.show_chart_rounded, color: Colors.green)), title: const Text('Investir'), subtitle: const Text('Abrir seus investimentos.'), onTap: () => Navigator.pop(sheetContext, 'investir')),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (!mounted || resultado == null) return;

    if (resultado == 'meta') {
      await Navigator.push(context, MaterialPageRoute(builder: (_) => const GuardarNaMetaPage()));
      if (mounted) { _dashboardRefreshNotifier.value++; setState(() {}); }
      return;
    }
    if (resultado == 'investir') {
      await Navigator.push(context, MaterialPageRoute(builder: (_) => const InvestimentosPage()));
      if (mounted) { _dashboardRefreshNotifier.value++; setState(() {}); }
      return;
    }

    if (resultado == 'transferencia') {
      final atualizado = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const NovaTransferenciaPage()),
      );
      if (atualizado == true && mounted) {
        _dashboardRefreshNotifier.value++;
        setState(() {});
      }
      return;
    }

    final atualizado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NovoLancamentoPage(
          receitaInicial: resultado == 'receita',
        ),
      ),
    );
    if (atualizado == true && mounted) {
      _dashboardRefreshNotifier.value++;
      setState(() {});
    }
  }

  Widget _navItem(int index, IconData icon, IconData selectedIcon, String label) {
    final selected = _currentIndex == index;
    return Expanded(child: InkWell(onTap: () => _selecionarPagina(index), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(selected ? selectedIcon : icon, color: selected ? Theme.of(context).colorScheme.primary : null), const SizedBox(height: 2), Text(label, style: TextStyle(fontSize: 11, color: selected ? Theme.of(context).colorScheme.primary : null, fontWeight: selected ? FontWeight.w700 : null))])));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      floatingActionButton: FloatingActionButton(
        heroTag: 'navigation_fab',
        onPressed: _abrirNovaMovimentacao,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 7,
        child: SizedBox(height: 64, child: Row(children: [
          _navItem(0, Icons.home_outlined, Icons.home, 'Início'),
          _navItem(1, Icons.receipt_long_outlined, Icons.receipt_long, 'Lançamentos'),
          const SizedBox(width: 56),
          _navItem(3, Icons.flag_outlined, Icons.flag, 'Metas'),
          _navItem(4, Icons.settings_outlined, Icons.settings, 'Config.'),
        ])),
      )
    );
  }
}
