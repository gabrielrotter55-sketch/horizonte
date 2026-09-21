import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/patrimonio_fisico.dart';

class PatrimonioFisicoRepository {
  static const _key = 'horizonte_patrimonio_fisico_v1';

  Future<List<PatrimonioFisico>> buscarTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.trim().isEmpty) return [];

    try {
      final lista = jsonDecode(raw) as List<dynamic>;
      final itens = lista
          .whereType<Map<String, dynamic>>()
          .map(PatrimonioFisico.fromMap)
          .toList();
      itens.sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
      return itens;
    } catch (_) {
      return [];
    }
  }

  Future<void> salvar(PatrimonioFisico item) async {
    final itens = await buscarTodos();
    final index = itens.indexWhere((value) => value.id == item.id);
    if (index >= 0) {
      itens[index] = item;
    } else {
      itens.add(item);
    }
    await _persistir(itens);
  }

  Future<void> excluir(String id) async {
    final itens = await buscarTodos();
    itens.removeWhere((item) => item.id == id);
    await _persistir(itens);
  }

  Future<double> patrimonioLiquidoTotal() async {
    final itens = await buscarTodos();
    return itens.fold<double>(
      0,
      (total, item) => total + item.patrimonioLiquido,
    );
  }

  Future<void> _persistir(List<PatrimonioFisico> itens) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(itens.map((item) => item.toMap()).toList()),
    );
  }
}
