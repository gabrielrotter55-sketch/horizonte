import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/meta_agrupamento.dart';
import 'meta_repository.dart';

class MetaAgrupamentoRepository {
  static const _key = 'horizonte_meta_agrupamentos_v2';

  Future<List<MetaAgrupamento>> buscarTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    final atuais = raw == null || raw.trim().isEmpty
        ? <MetaAgrupamento>[]
        : (jsonDecode(raw) as List<dynamic>)
            .whereType<Map<String, dynamic>>()
            .map(MetaAgrupamento.fromMap)
            .toList();

    // Migra grupos antigos (grupoId/grupoNome) para a estrutura que permite
    // uma mesma meta participar de mais de um agrupamento.
    final metas = await MetaRepository().buscarTodas();
    final antigos = <String, List<String>>{};
    final nomes = <String, String>{};
    for (final meta in metas) {
      if (meta.grupoId == null) continue;
      antigos.putIfAbsent(meta.grupoId!, () => []).add(meta.id);
      nomes[meta.grupoId!] = meta.grupoNome ?? 'Grupo';
    }
    var alterou = false;
    for (final entry in antigos.entries) {
      if (!atuais.any((g) => g.id == entry.key)) {
        atuais.add(MetaAgrupamento(id: entry.key, nome: nomes[entry.key] ?? 'Grupo', metaIds: entry.value));
        alterou = true;
      }
    }
    if (alterou) await _persistir(atuais);
    return atuais;
  }

  Future<void> salvar(MetaAgrupamento grupo) async {
    final grupos = await buscarTodos();
    final i = grupos.indexWhere((g) => g.id == grupo.id);
    if (i >= 0) grupos[i] = grupo; else grupos.add(grupo);
    await _persistir(grupos);
  }

  Future<void> excluir(String id) async {
    final grupos = await buscarTodos();
    grupos.removeWhere((g) => g.id == id);
    await _persistir(grupos);
  }

  Future<void> _persistir(List<MetaAgrupamento> grupos) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(grupos.map((g) => g.toMap()).toList()));
  }
}
