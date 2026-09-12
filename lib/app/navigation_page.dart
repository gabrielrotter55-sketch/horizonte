import 'package:flutter/material.dart';

import '../features/dashboard/dashboard_page.dart';
import '../features/lancamentos/pages/lancamentos_page.dart';
import '../features/lancamentos/pages/novo_lancamento_page.dart';
import '../features/contas/pages/nova_transferencia_page.dart';
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

  final List<Widget> _pages = [
    const DashboardPage(),
    LancamentosPage(),
    const InvestimentosPage(),
    const MetasPage(),
    const ConfiguracoesPage(),
  ];

  Future<void> _abrirNovaMovimentacao() async {
    final resultado = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              8,
              20,
              24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Nova movimentação',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFFEE2E2),
                    child: Icon(
                      Icons.arrow_upward,
                      color: Colors.red,
                    ),
                  ),
                  title: const Text('Despesa'),
                  subtitle: const Text(
                    'Registrar uma compra ou pagamento.',
                  ),
                  onTap: () {
                    Navigator.pop(
                      context,
                      'despesa',
                    );
                  },
                ),

                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFDCFCE7),
                    child: Icon(
                      Icons.arrow_downward,
                      color: Colors.green,
                    ),
                  ),
                  title: const Text('Receita'),
                  subtitle: const Text(
                    'Registrar salário, PIX ou outra entrada.',
                  ),
                  onTap: () {
                    Navigator.pop(
                      context,
                      'receita',
                    );
                  },
                ),

                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFEDE9FE),
                    child: Icon(
                      Icons.swap_horiz,
                      color: Colors.deepPurple,
                    ),
                  ),
                  title: const Text('Transferência'),
                  subtitle: const Text(
                    'Mover dinheiro entre suas contas.',
                  ),
                  onTap: () {
                    Navigator.pop(
                      context,
                      'transferencia',
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || resultado == null) {
      return;
    }

    if (resultado == 'transferencia') {
      final atualizado = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const NovaTransferenciaPage(),
        ),
      );

      if (atualizado == true && mounted) {
        setState(() {});
      }

      return;
    }

    final atualizado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NovoLancamentoPage(),
      ),
    );

    if (atualizado == true && mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirNovaMovimentacao,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
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