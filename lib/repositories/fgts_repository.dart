import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FgtsMovimentacao {
  final String id;
  final String tipo; // aporte | rendimento
  final double valor;
  final DateTime data;

  const FgtsMovimentacao({required this.id, required this.tipo, required this.valor, required this.data});

  Map<String, dynamic> toMap() => {'id': id, 'tipo': tipo, 'valor': valor, 'data': data.toIso8601String()};

  factory FgtsMovimentacao.fromMap(Map<String, dynamic> map) => FgtsMovimentacao(
        id: map['id']?.toString() ?? DateTime.now().microsecondsSinceEpoch.toString(),
        tipo: map['tipo']?.toString() ?? 'aporte',
        valor: (map['valor'] as num?)?.toDouble() ?? 0,
        data: DateTime.tryParse(map['data']?.toString() ?? '') ?? DateTime.now(),
      );
}

class FgtsSaldo {
  final double aportes;
  final double rendimentos;
  const FgtsSaldo({this.aportes = 0, this.rendimentos = 0});
  double get total => aportes + rendimentos;
  double get diamantest => aportes;
  double get lewa => rendimentos;
}

class FgtsRepository {
  static const _key = 'horizonte_fgts_v2';
  static const _legacyKey = 'horizonte_fgts_v1';
  static const _historicoKey = 'horizonte_fgts_historico_v1';

  Future<List<FgtsMovimentacao>> historico() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_historicoKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final lista = jsonDecode(raw) as List<dynamic>;
        return lista.whereType<Map<String, dynamic>>().map(FgtsMovimentacao.fromMap).where((m) => m.valor > 0).toList()
          ..sort((a, b) => b.data.compareTo(a.data));
      } catch (_) {}
    }
    return [];
  }

  Future<void> _salvarHistorico(List<FgtsMovimentacao> itens) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_historicoKey, jsonEncode(itens.map((e) => e.toMap()).toList()));
  }

  Future<FgtsSaldo> buscar() async {
    final prefs = await SharedPreferences.getInstance();
    final historicoAtual = await historico();
    if (historicoAtual.isNotEmpty) {
      return FgtsSaldo(
        aportes: historicoAtual.where((m) => m.tipo == 'aporte').fold<double>(0, (s, m) => s + m.valor),
        rendimentos: historicoAtual.where((m) => m.tipo == 'rendimento').fold<double>(0, (s, m) => s + m.valor),
      );
    }
    final raw = prefs.getString(_key);
    if (raw != null && raw.isNotEmpty) {
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        return FgtsSaldo(
          aportes: (map['aportes'] as num?)?.toDouble() ?? 0,
          rendimentos: (map['rendimentos'] as num?)?.toDouble() ?? 0,
        );
      } catch (_) {}
    }
    final legacy = prefs.getString(_legacyKey);
    if (legacy != null && legacy.isNotEmpty) {
      try {
        final map = jsonDecode(legacy) as Map<String, dynamic>;
        return FgtsSaldo(
          aportes: ((map['diamantest'] as num?)?.toDouble() ?? 0) + ((map['lewa'] as num?)?.toDouble() ?? 0),
        );
      } catch (_) {}
    }
    return const FgtsSaldo();
  }

  Future<void> salvar({double? aportes, double? rendimentos}) async {
    final atual = await buscar();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode({'aportes': aportes ?? atual.aportes, 'rendimentos': rendimentos ?? atual.rendimentos}));
  }

  Future<void> adicionarAporte(double valor) async {
    if (valor <= 0) return;
    await _garantirHistoricoMigrado();
    final itens = await historico();
    itens.add(FgtsMovimentacao(id: DateTime.now().microsecondsSinceEpoch.toString(), tipo: 'aporte', valor: valor, data: DateTime.now()));
    await _salvarHistorico(itens);
  }

  Future<void> adicionarRendimento(double valor) async {
    if (valor <= 0) return;
    await _garantirHistoricoMigrado();
    final itens = await historico();
    itens.add(FgtsMovimentacao(id: DateTime.now().microsecondsSinceEpoch.toString(), tipo: 'rendimento', valor: valor, data: DateTime.now()));
    await _salvarHistorico(itens);
  }

  Future<void> editarMovimentacao(FgtsMovimentacao movimento, {required String tipo, required double valor}) async {
    final itens = await historico();
    final index = itens.indexWhere((m) => m.id == movimento.id);
    if (index < 0 || valor <= 0) return;
    itens[index] = FgtsMovimentacao(id: movimento.id, tipo: tipo, valor: valor, data: movimento.data);
    await _salvarHistorico(itens);
  }

  Future<void> excluirMovimentacao(String id) async {
    final itens = await historico();
    itens.removeWhere((m) => m.id == id);
    await _salvarHistorico(itens);
  }

  Future<void> _garantirHistoricoMigrado() async {
    final atual = await historico();
    if (atual.isNotEmpty) return;
    final saldo = await buscar();
    if (saldo.total <= 0) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_historicoKey);
    if (raw != null) return;
    await _salvarHistorico([
      FgtsMovimentacao(id: 'legado-${DateTime.now().microsecondsSinceEpoch}', tipo: 'aporte', valor: saldo.aportes, data: DateTime.now()),
      if (saldo.rendimentos > 0) FgtsMovimentacao(id: 'legado-r-${DateTime.now().microsecondsSinceEpoch}', tipo: 'rendimento', valor: saldo.rendimentos, data: DateTime.now()),
    ]);
  }

  Future<void> substituir({required double diamantest, required double lewa}) async {
    await salvar(aportes: diamantest, rendimentos: lewa);
    await _salvarHistorico([
      if (diamantest > 0) FgtsMovimentacao(id: 'substituicao-g-${DateTime.now().microsecondsSinceEpoch}', tipo: 'aporte', valor: diamantest, data: DateTime.now()),
      if (lewa > 0) FgtsMovimentacao(id: 'substituicao-r-${DateTime.now().microsecondsSinceEpoch}', tipo: 'rendimento', valor: lewa, data: DateTime.now()),
    ]);
  }
}
