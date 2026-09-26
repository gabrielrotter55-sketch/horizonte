
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/compromisso.dart';

class CompromissoRepository {
  static const _key = 'horizonte_compromissos_v1';

  Future<List<Compromisso>> buscarTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.trim().isEmpty) return [];

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      final lista = decoded
          .whereType<Map<String, dynamic>>()
          .map(Compromisso.fromMap)
          .where((item) => item.valor > 0)
          .toList();
      lista.sort((a, b) => a.data.compareTo(b.data));
      return lista;
    } catch (_) {
      return [];
    }
  }

  Future<void> salvar(Compromisso item) async {
    final lista = await buscarTodos();
    final index = lista.indexWhere((e) => e.id == item.id);
    if (index >= 0) {
      lista[index] = item;
    } else {
      lista.add(item);
    }
    await _persistir(lista);
  }

  Future<void> excluir(String id) async {
    final lista = await buscarTodos();
    lista.removeWhere((e) => e.id == id);
    await _persistir(lista);
  }

  Future<Compromisso?> buscarPorId(String id) async {
    final lista = await buscarTodos();
    for (final item in lista) {
      if (item.id == id) return item;
    }
    return null;
  }

  Future<List<Compromisso>> proximos({int limite = 3}) async {
    final agora = DateTime.now();
    final lista = (await buscarTodos())
        .where((e) => e.status == StatusCompromisso.pendente)
        .where((e) => !e.data.isBefore(DateTime(agora.year, agora.month, agora.day)))
        .toList();
    lista.sort((a, b) => a.data.compareTo(b.data));
    return lista.take(limite).toList();
  }

  Future<Compromisso?> proximo() async {
    final agora = DateTime.now();
    final lista = (await buscarTodos())
        .where((e) => e.status == StatusCompromisso.pendente)
        .toList();

    if (lista.isEmpty) return null;

    // Mostra também vencidos: são mais urgentes que qualquer compromisso futuro.
    lista.sort((a, b) {
      final aPast = a.data.isBefore(DateTime(agora.year, agora.month, agora.day));
      final bPast = b.data.isBefore(DateTime(agora.year, agora.month, agora.day));
      if (aPast != bPast) return aPast ? -1 : 1;
      return a.data.compareTo(b.data);
    });
    return lista.first;
  }

  Future<void> marcarComoPago(String id, DateTime dataPagamento) async {
    final atual = await buscarPorId(id);
    if (atual == null) return;

    if (atual.recorrente) {
      final proximaData = _proximaData(atual.data, atual.tipo);
      await salvar(
        atual.copyWith(
          data: proximaData,
          status: StatusCompromisso.pendente,
          pagoEm: dataPagamento,
        ),
      );
    } else {
      await salvar(
        atual.copyWith(
          status: StatusCompromisso.pago,
          pagoEm: dataPagamento,
        ),
      );
    }
  }

  DateTime _proximaData(DateTime data, TipoCompromisso tipo) {
    if (tipo == TipoCompromisso.mensal) {
      final proximoMes = DateTime(data.year, data.month + 1, 1);
      final ultimoDia = DateTime(proximoMes.year, proximoMes.month + 1, 0).day;
      return DateTime(proximoMes.year, proximoMes.month, mathMin(data.day, ultimoDia));
    }

    return DateTime(data.year + 1, data.month, data.day);
  }

  Future<void> _persistir(List<Compromisso> lista) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(lista.map((e) => e.toMap()).toList()),
    );
  }
}

int mathMin(int a, int b) => a < b ? a : b;
