import 'package:flutter/material.dart';

import '../features/dashboard/dashboard_page.dart';
import '../features/lancamentos/pages/lancamentos_page.dart';
import '../features/investimentos/investimentos_page.dart';
import '../features/metas/metas_page.dart';
import '../features/configuracoes/configuracoes_page.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  int _currentIndex = 0;

  final ValueNotifier<int> _dashboardRefreshNotifier =
      ValueNotifier<int>(0);

  late final List<Widget> _pages = [
    DashboardPage(
      refreshNotifier: _dashboardRefreshNotifier,
    ),
    LancamentosPage(),
    const InvestimentosPage(),
    const MetasPage(),
    const ConfiguracoesPage(),
  ];

  @override
  void dispose() {
    _dashboardRefreshNotifier.dispose();
    super.dispose();
  }

  void _selecionarPagina(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (index == 0) {
      _dashboardRefreshNotifier.value++;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _selecionarPagina,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Lançamentos',
          ),
          NavigationDestination(
            icon: Icon(Icons.show_chart_outlined),
            selectedIcon: Icon(Icons.show_chart),
            label: 'Investimentos',
          ),
          NavigationDestination(
            icon: Icon(Icons.flag_outlined),
            selectedIcon: Icon(Icons.flag),
            label: 'Metas',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Configurações',
          ),
        ],
      ),
    );
  }
}
