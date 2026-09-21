import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/meta_deposito.dart';

class MetaDepositoRepository {
  static const _key = 'horizonte_meta_depositos_v1';

  Future<List<MetaDeposito>> buscarTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.trim().isEmpty) return [];

    try {
      final lista = jsonDecode(raw) as List<dynamic>;
      final depositos = lista
          .whereType<Map<String, dynamic>>()
          .map(MetaDeposito.fromMap)
          .where((item) => item.valor > 0)
          .toList();
      depositos.sort((a, b) => b.data.compareTo(a.data));
      return depositos;
    } catch (_) {
      return [];
    }
  }

  Future<List<MetaDeposito>> buscarDaMeta(String metaId) async {
    final todos = await buscarTodos();
    return todos.where((item) => item.metaId == metaId).toList();
  }

  Future<void> salvar(MetaDeposito deposito) async {
    final todos = await buscarTodos();
    final index = todos.indexWhere((item) => item.id == deposito.id);
    if (index >= 0) {
      todos[index] = deposito;
    } else {
      todos.add(deposito);
    }
    await _salvarLista(todos);
  }

  Future<void> excluir(String id) async {
    final todos = await buscarTodos();
    todos.removeWhere((item) => item.id == id);
    await _salvarLista(todos);
  }

  Future<void> excluirPorMeta(String metaId) async {
    final todos = await buscarTodos();
    todos.removeWhere((item) => item.metaId == metaId);
    await _salvarLista(todos);
  }

  Future<void> excluirPorOrigem(String origem) async {
    final todos = await buscarTodos();
    todos.removeWhere((item) => item.origem == origem);
    await _salvarLista(todos);
  }

  Future<double> totalDaMeta(String metaId) async {
    final depositos = await buscarDaMeta(metaId);
    return depositos.fold<double>(0, (total, item) => total + item.valor);
  }

  Future<Map<String, double>> totaisPorPessoa(String metaId) async {
    final depositos = await buscarDaMeta(metaId);
    final totais = <String, double>{};
    for (final deposito in depositos) {
      totais[deposito.pessoa] = (totais[deposito.pessoa] ?? 0) + deposito.valor;
    }
    return totais;
  }

  Future<void> _salvarLista(List<MetaDeposito> depositos) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(depositos.map((item) => item.toMap()).toList()),
    );
  }
}
