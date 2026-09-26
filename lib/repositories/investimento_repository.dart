import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/investimento.dart';

class InvestimentoRepository {
  static const _key = 'horizonte_investimentos_v2';
  static const _legacyKey = 'horizonte_investimentos_v1';
  static const _usdKey = 'horizonte_cotacao_usd_v1';
  static const _seedKey = 'horizonte_carteira_inicial_v1';

  Future<List<Investimento>> buscarTodas() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key) ?? prefs.getString(_legacyKey);
    if (raw == null || raw.trim().isEmpty) return [];

    try {
      final lista = jsonDecode(raw) as List<dynamic>;
      final investimentos = lista
          .whereType<Map<String, dynamic>>()
          .map(Investimento.fromMap)
          .toList();
      investimentos.sort((a, b) => b.data.compareTo(a.data));
      return investimentos;
    } catch (_) {
      return [];
    }
  }

  Future<void> salvar(Investimento investimento) async {
    final lista = await buscarTodas();
    final index = lista.indexWhere((item) => item.id == investimento.id);
    if (index >= 0) {
      lista[index] = investimento;
    } else {
      lista.add(investimento);
    }
    await _persistir(lista);
  }

  Future<void> excluir(String id) async {
    final lista = await buscarTodas();
    lista.removeWhere((item) => item.id == id);
    await _persistir(lista);
  }

  Future<void> garantirCarteiraAtual() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_seedKey) == true) return;

    final atual = await buscarTodas();
    if (atual.isNotEmpty && !atual.every((item) => item.id.startsWith('planilha-'))) {
      await prefs.setBool(_seedKey, true);
      return;
    }
    if (atual.isNotEmpty) return;

    final agora = DateTime(2026, 9, 20);
    final itens = <Investimento>[
      _item('WEGE3', 'WEGE3', 'Ações', 'Nubank', 'BRL', 4, 42.34, 51.65, agora),
      _item('BBAS3', 'BBAS3', 'Ações', 'Nubank', 'BRL', 7, 22.52, 23.16, agora),
      _item('PETR4', 'PETR4', 'Ações', 'Nubank', 'BRL', 3, 30.81, 48.47, agora),
      _item('EGIE3', 'EGIE3', 'Ações', 'Nubank', 'BRL', 4, 29.03, 30.54, agora),
      _item('RADL3', 'RADL3', 'Ações', 'Nubank', 'BRL', 6, 21.94, 20.35, agora),
      _item('GRND3', 'GRND3', 'Ações', 'Nubank', 'BRL', 28, 4.42, 3.67, agora),
      _item('LEVE3', 'LEVE3', 'Ações', 'Nubank', 'BRL', 3, 28.49, 32.85, agora),
      _item('KLBN11', 'KLBN11', 'Ações', 'Nubank', 'BRL', 5, 19.84, 19.14, agora),
      _item('ITSA3', 'ITSA3', 'Ações', 'Nubank', 'BRL', 5, 9.94, 14.12, agora),
      _item('ABEV3', 'ABEV3', 'Ações', 'Nubank', 'BRL', 4, 11.37, 15.37, agora),
      _item('GARE11', 'GARE11', 'FIIs', 'Nubank', 'BRL', 22, 8.50, 8.42, agora),
      _item('VGHF11', 'VGHF11', 'FIIs', 'Nubank', 'BRL', 31, 7.01, 5.06, agora),
      _item('CPTS11', 'CPTS11', 'FIIs', 'Nubank', 'BRL', 21, 7.46, 7.41, agora),
      _item('HGLG11', 'HGLG11', 'FIIs', 'Nubank', 'BRL', 1, 158.62, 147.90, agora),
      _item('MXRF11', 'MXRF11', 'FIIs', 'Nubank', 'BRL', 15, 9.59, 9.09, agora),
      _item('GGRC11', 'GGRC11', 'FIIs', 'Nubank', 'BRL', 15, 9.74, 9.02, agora),
      _item('VGIA11', 'VGIA11', 'FIIs', 'Nubank', 'BRL', 15, 8.98, 8.78, agora),
      _item('XPCA11', 'XPCA11', 'FIIs', 'Nubank', 'BRL', 17, 7.00, 7.39, agora),
      _item('BTCI11', 'BTCI11', 'FIIs', 'Nubank', 'BRL', 15, 8.82, 8.37, agora),
      _item('XPML11', 'XPML11', 'FIIs', 'Nubank', 'BRL', 1, 96.53, 98.55, agora),
      _item('GOOGLE', 'GOOGL', 'Stocks', 'Nomad', 'USD', 0.12, 313.47, 349.64, agora),
      _item('META', 'META', 'Stocks', 'Nomad', 'USD', 0.03, 640.03, 670.96, agora),
      _item('COST', 'COST', 'Stocks', 'Nomad', 'USD', 0.02, 918.66, 896.33, agora),
      _item('NU', 'NU', 'Stocks', 'Nomad', 'USD', 1.05, 11.68, 13.73, agora),
      _item('AAPL', 'AAPL', 'Stocks', 'Nomad', 'USD', 0.02, 223.66, 334.61, agora),
      _item('INTR', 'INTR', 'Stocks', 'Nomad', 'USD', 1.04, 4.99, 5.38, agora),
      _item('IVV', 'IVV', 'ETFs internacionais', 'Nomad', 'USD', 0.07, 683.20, 764.92, agora),
      _item('TFLO', 'TFLO', 'ETFs internacionais', 'Nomad', 'USD', 0.94, 50.50, 50.62, agora),
      _item('BTC', 'BTC', 'Criptomoedas', 'Binance', 'BRL', 0.0008948, 385691.84, 416747.32, agora),
      _item('Reserva de oportunidade', '', 'Reserva de oportunidade', 'Mercado Pago', 'BRL', 1, 263.36, 263.36, agora),
    ];

    for (final item in itens) {
      await salvar(item);
    }
    await prefs.setBool(_seedKey, true);
  }

  Investimento _item(
    String nome,
    String ticker,
    String tipo,
    String instituicao,
    String moeda,
    double quantidade,
    double precoMedio,
    double precoAtual,
    DateTime data,
  ) {
    return Investimento(
      id: 'investidor10-${ticker.isEmpty ? nome : ticker}',
      nome: nome,
      ticker: ticker,
      tipo: tipo,
      instituicao: instituicao,
      moeda: moeda,
      quantidade: quantidade,
      precoMedio: precoMedio,
      precoAtual: precoAtual,
      valorInvestido: quantidade * precoMedio,
      valorAtual: quantidade * precoAtual,
      data: data,
      origem: 'investidor10',
    );
  }

  Future<double> cotacaoDolar() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_usdKey) ?? 5.30;
  }

  Future<void> salvarCotacaoDolar(double valor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_usdKey, valor);
  }

  Future<void> _persistir(List<Investimento> lista) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(lista.map((item) => item.toMap()).toList()),
    );
  }
}
