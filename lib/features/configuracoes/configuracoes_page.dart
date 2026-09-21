
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/theme_controller.dart';
import '../categorias/pages/categorias_page.dart';
import '../compromissos/compromissos_page.dart';
import '../contas/pages/contas_page.dart';
import '../cartoes/pages/cartoes_page.dart';
import '../faturas/pages/faturas_page.dart';
import '../investimentos/investimentos_page.dart';
import '../patrimonio_fisico/patrimonio_fisico_page.dart';
import '../metas/metas_page.dart';
import 'importar_planilha_page.dart';

class ConfiguracoesPage extends StatefulWidget {
  final ThemeController? themeController;

  const ConfiguracoesPage({super.key, this.themeController});

  @override
  State<ConfiguracoesPage> createState() => _ConfiguracoesPageState();
}

class _ConfiguracoesPageState extends State<ConfiguracoesPage> {
  static const _nomeKey = 'horizonte_nome_usuario_v1';
  String _nome = 'Gabriel';

  @override
  void initState() {
    super.initState();
    _carregarNome();
  }

  Future<void> _carregarNome() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) setState(() => _nome = prefs.getString(_nomeKey) ?? 'Gabriel');
  }

  void _abrir(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  Future<void> _editarNome() async {
    final controller = TextEditingController(text: _nome);
    final valor = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seu nome'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Nome'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Salvar')),
        ],
      ),
    );
    if (valor == null || valor.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nomeKey, valor);
    if (mounted) setState(() => _nome = valor);
  }

  Future<void> _selecionarTema() async {
    final controller = widget.themeController;
    if (controller == null) return;

    final escolha = await showModalBottomSheet<HorizonteThemePreference>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Modo de exibição', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              RadioGroup<HorizonteThemePreference>(
                groupValue: controller.preference,
                onChanged: (value) => Navigator.pop(context, value),
                child: Column(
                  children: [
                    for (final item in HorizonteThemePreference.values)
                      RadioListTile<HorizonteThemePreference>(
                        value: item,
                        title: Text(_nomeTema(item)),
                        subtitle: Text(_descricaoTema(item)),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (escolha != null) {
      await controller.setPreference(escolha);
      if (mounted) setState(() {});
    }
  }

  String _nomeTema(HorizonteThemePreference item) {
    switch (item) {
      case HorizonteThemePreference.system:
        return 'Automático';
      case HorizonteThemePreference.light:
        return 'Claro';
      case HorizonteThemePreference.dark:
        return 'Escuro';
    }
  }

  String _descricaoTema(HorizonteThemePreference item) {
    switch (item) {
      case HorizonteThemePreference.system:
        return 'Segue a configuração do celular.';
      case HorizonteThemePreference.light:
        return 'Interface clara durante todo o dia.';
      case HorizonteThemePreference.dark:
        return 'Interface escura e confortável para a noite.';
    }
  }

  String _temaAtual() {
    final controller = widget.themeController;
    if (controller == null) return 'Sistema';
    return _nomeTema(controller.preference);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          Text('Olá, $_nome', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
          const SizedBox(height: 5),
          Text('Personalize o Horizonte para funcionar do seu jeito.', style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 24),

          const _SecaoTitulo('Personalização'),
          _ConfiguracaoTile(
            icon: Icons.palette_outlined,
            title: 'Modo de exibição',
            subtitle: _temaAtual(),
            onTap: _selecionarTema,
          ),
          _ConfiguracaoTile(
            icon: Icons.person_outline_rounded,
            title: 'Perfil',
            subtitle: 'Nome exibido no aplicativo: $_nome',
            onTap: _editarNome,
          ),

          const SizedBox(height: 22),
          const _SecaoTitulo('Organização financeira'),
          _ConfiguracaoTile(
            icon: Icons.event_note_outlined,
            title: 'Contas e compromissos',
            subtitle: 'Mensais, anuais e esporádicos.',
            onTap: () => _abrir(context, const CompromissosPage()),
          ),
          _ConfiguracaoTile(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Contas',
            subtitle: 'Saldos iniciais, contas e transferências.',
            onTap: () => _abrir(context, ContasPage()),
          ),
          _ConfiguracaoTile(
            icon: Icons.credit_card_outlined,
            title: 'Cartões',
            subtitle: 'Limites, fechamento e vencimento.',
            onTap: () => _abrir(context, CartoesPage()),
          ),
          _ConfiguracaoTile(
            icon: Icons.receipt_long_outlined,
            title: 'Faturas',
            subtitle: 'Consulte e pague faturas de cartão.',
            onTap: () => _abrir(context, FaturasPage()),
          ),
          _ConfiguracaoTile(
            icon: Icons.category_outlined,
            title: 'Categorias',
            subtitle: 'Receitas e despesas.',
            onTap: () => _abrir(context, CategoriasPage()),
          ),
          _ConfiguracaoTile(
            icon: Icons.flag_outlined,
            title: 'Metas',
            subtitle: 'Acompanhe objetivos e depósitos.',
            onTap: () => _abrir(context, const MetasPage()),
          ),
          _ConfiguracaoTile(
            icon: Icons.show_chart_rounded,
            title: 'Investimentos',
            subtitle: 'Carteira, instituições e cotação USD.',
            onTap: () => _abrir(context, const InvestimentosPage()),
          ),
          _ConfiguracaoTile(
            icon: Icons.home_work_outlined,
            title: 'Patrimônio físico',
            subtitle: 'Moto, carro, imóvel e financiamentos.',
            onTap: () => _abrir(context, const PatrimonioFisicoPage()),
          ),

          const SizedBox(height: 22),
          const _SecaoTitulo('Dados'),
          _ConfiguracaoTile(
            icon: Icons.table_chart_outlined,
            title: 'Importar planilha',
            subtitle: 'Traga seu histórico financeiro do Excel.',
            onTap: () => _abrir(context, const ImportarPlanilhaPage()),
          ),
          Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.currency_exchange_rounded)),
              title: const Text('Moeda principal'),
              subtitle: const Text('BRL • Real brasileiro'),
            ),
          ),

          const SizedBox(height: 22),
          const _SecaoTitulo('Sobre'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        child: Icon(Icons.auto_graph_rounded, color: Theme.of(context).colorScheme.onPrimaryContainer),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(child: Text('Horizonte', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
                      Text('V2.0', style: Theme.of(context).textTheme.labelLarge),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text('Clareza financeira sem culpa. Um painel pessoal para contas, compromissos, metas, investimentos e patrimônio.'),
                  const SizedBox(height: 12),
                  Text('Dados financeiros armazenados localmente no aparelho.', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SecaoTitulo extends StatelessWidget {
  final String texto;
  const _SecaoTitulo(this.texto);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(texto, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
      );
}

class _ConfiguracaoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _ConfiguracaoTile({required this.icon, required this.title, required this.subtitle, this.onTap});

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: CircleAvatar(child: Icon(icon)),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text(subtitle),
          trailing: onTap == null ? null : const Icon(Icons.chevron_right_rounded),
          onTap: onTap,
        ),
      );
}
