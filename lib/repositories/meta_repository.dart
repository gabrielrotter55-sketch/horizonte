import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/meta_financeira.dart';
import 'meta_deposito_repository.dart';

class MetaRepository {
  static const _key = 'horizonte_metas_v1';

  Future<List<MetaFinanceira>> buscarTodas() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.trim().isEmpty) return [];

    try {
      final lista = jsonDecode(raw) as List<dynamic>;
      final metas = lista
          .whereType<Map<String, dynamic>>()
          .map(MetaFinanceira.fromMap)
          .toList();
      metas.sort((a, b) => a.criadoEm.compareTo(b.criadoEm));
      return metas;
    } catch (_) {
      return [];
    }
  }

  Future<void> salvar(MetaFinanceira meta) async {
    final metas = await buscarTodas();
    final index = metas.indexWhere((item) => item.id == meta.id);
    if (index >= 0) {
      metas[index] = meta;
    } else {
      metas.add(meta);
    }
    await _salvarLista(metas);
  }

  Future<void> excluir(String id) async {
    final depositos = MetaDepositoRepository();
    await depositos.excluirPorMeta(id);
    final metas = await buscarTodas();
    metas.removeWhere((item) => item.id == id);
    await _salvarLista(metas);
  }

  Future<void> _salvarLista(List<MetaFinanceira> metas) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(metas.map((meta) => meta.toMap()).toList()),
    );
  }
}
