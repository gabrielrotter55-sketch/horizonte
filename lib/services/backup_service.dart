import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/app_database.dart';
import '../database/database_service.dart';

class BackupService {
  static const formatVersion = 1;
  final _db = DatabaseService.instance.database;

  Future<BackupSummary> summary() async {
    final prefs = await SharedPreferences.getInstance();
    return BackupSummary(
      contas: await _db.select(_db.contas).get().then((v) => v.length),
      categorias: await _db.select(_db.categorias).get().then((v) => v.length),
      lancamentos: await _db.select(_db.lancamentos).get().then((v) => v.length),
      cartoes: await _db.select(_db.cartoes).get().then((v) => v.length),
      faturas: await _db.select(_db.faturas).get().then((v) => v.length),
      pagamentosFaturas: await _db.select(_db.pagamentosFaturas).get().then((v) => v.length),
      transferencias: await _db.select(_db.transferencias).get().then((v) => v.length),
      preferencias: prefs.getKeys().length,
    );
  }

  Future<String?> criarBackup() async {
    final prefs = await SharedPreferences.getInstance();
    final payload = <String, dynamic>{
      'formatVersion': formatVersion,
      'app': 'Horizonte',
      'createdAt': DateTime.now().toIso8601String(),
      'database': {
        'contas': (await _db.select(_db.contas).get()).map((r) => _jsonRow(r.toJson())).toList(),
        'categorias': (await _db.select(_db.categorias).get()).map((r) => _jsonRow(r.toJson())).toList(),
        'cartoes': (await _db.select(_db.cartoes).get()).map((r) => _jsonRow(r.toJson())).toList(),
        'lancamentos': (await _db.select(_db.lancamentos).get()).map((r) => _jsonRow(r.toJson())).toList(),
        'faturas': (await _db.select(_db.faturas).get()).map((r) => _jsonRow(r.toJson())).toList(),
        'pagamentosFaturas': (await _db.select(_db.pagamentosFaturas).get()).map((r) => _jsonRow(r.toJson())).toList(),
        'transferencias': (await _db.select(_db.transferencias).get()).map((r) => _jsonRow(r.toJson())).toList(),
      },
      'preferences': {for (final key in prefs.getKeys()) key: prefs.get(key)},
    };

    final bytes = Uint8List.fromList(utf8.encode(jsonEncode(payload)));
    final fileName = 'Horizonte_Backup_${_timestamp(DateTime.now())}.hzbackup';
    final uri = await FilePicker.saveFile(
      dialogTitle: 'Salvar backup do Horizonte',
      fileName: fileName,
      type: FileType.custom,
      allowedExtensions: const ['hzbackup'],
      bytes: bytes,
    );
    return uri?.toString();
  }

  Future<BackupSummary?> restaurarBackup() async {
    final file = await FilePicker.pickFile(
      dialogTitle: 'Selecionar backup do Horizonte',
      type: FileType.custom,
      allowedExtensions: const ['hzbackup'],
    );
    if (file == null) return null;
    final bytes = await file.readAsBytes();
    final decoded = jsonDecode(utf8.decode(bytes));
    if (decoded is! Map<String, dynamic> || decoded['app'] != 'Horizonte' || decoded['formatVersion'] != formatVersion) {
      throw const FormatException('Arquivo de backup inválido ou incompatível.');
    }

    final database = decoded['database'];
    final preferences = decoded['preferences'];
    if (database is! Map<String, dynamic> || preferences is! Map<String, dynamic>) {
      throw const FormatException('Estrutura do backup inválida.');
    }

    await _db.transaction(() async {
      await _db.delete(_db.pagamentosFaturas).go();
      await _db.delete(_db.faturas).go();
      await _db.delete(_db.lancamentos).go();
      await _db.delete(_db.transferencias).go();
      await _db.delete(_db.cartoes).go();
      await _db.delete(_db.categorias).go();
      await _db.delete(_db.contas).go();

      for (final row in _rows(database, 'contas')) {
        await _db.into(_db.contas).insert(_conta(row));
      }
      for (final row in _rows(database, 'categorias')) {
        await _db.into(_db.categorias).insert(_categoria(row));
      }
      for (final row in _rows(database, 'cartoes')) {
        await _db.into(_db.cartoes).insert(_cartao(row));
      }
      for (final row in _rows(database, 'lancamentos')) {
        await _db.into(_db.lancamentos).insert(_lancamento(row));
      }
      for (final row in _rows(database, 'faturas')) {
        await _db.into(_db.faturas).insert(_fatura(row));
      }
      for (final row in _rows(database, 'pagamentosFaturas')) {
        await _db.into(_db.pagamentosFaturas).insert(_pagamento(row));
      }
      for (final row in _rows(database, 'transferencias')) {
        await _db.into(_db.transferencias).insert(_transferencia(row));
      }
    });

    final prefs = await SharedPreferences.getInstance();
    for (final key in prefs.getKeys().toList()) {
      await prefs.remove(key);
    }
    for (final entry in preferences.entries) {
      final value = entry.value;
      if (value is String) await prefs.setString(entry.key, value);
      else if (value is bool) await prefs.setBool(entry.key, value);
      else if (value is int) await prefs.setInt(entry.key, value);
      else if (value is double) await prefs.setDouble(entry.key, value);
      else if (value is List) await prefs.setStringList(entry.key, value.map((e) => e.toString()).toList());
    }
    return summary();
  }

  List<Map<String, dynamic>> _rows(Map<String, dynamic> database, String key) =>
      (database[key] as List<dynamic>? ?? const []).whereType<Map<String, dynamic>>().toList();

  Map<String, dynamic> _jsonRow(Map<String, dynamic> row) => {for (final e in row.entries) e.key: e.value is DateTime ? (e.value as DateTime).toIso8601String() : e.value};

  ContasCompanion _conta(Map<String, dynamic> r) => ContasCompanion.insert(
        id: Value(_int(r['id'])), nome: _str(r['nome']), saldoInicial: _double(r['saldoInicial']), tipo: _str(r['tipo']));
  CategoriasCompanion _categoria(Map<String, dynamic> r) => CategoriasCompanion.insert(
        id: Value(_int(r['id'])), nome: _str(r['nome']), icone: _str(r['icone']), cor: _int(r['cor']), receita: _bool(r['receita']));
  CartoesCompanion _cartao(Map<String, dynamic> r) => CartoesCompanion.insert(
        id: Value(_int(r['id'])), nome: _str(r['nome']), limite: _double(r['limite']), fechamento: _int(r['fechamento']), vencimento: _int(r['vencimento']));
  LancamentosCompanion _lancamento(Map<String, dynamic> r) => LancamentosCompanion.insert(
        id: Value(_int(r['id'])), descricao: _str(r['descricao']), valor: _double(r['valor']), receita: _bool(r['receita']), data: _date(r['data']), categoriaId: _int(r['categoriaId']), contaId: Value(_nullableInt(r['contaId'])), cartaoId: Value(_nullableInt(r['cartaoId'])), origem: Value(_str(r['origem'], fallback: 'manual')));
  FaturasCompanion _fatura(Map<String, dynamic> r) => FaturasCompanion.insert(
        id: Value(_int(r['id'])), cartaoId: _int(r['cartaoId']), mesReferencia: _int(r['mesReferencia']), anoReferencia: _int(r['anoReferencia']), paga: Value(_bool(r['paga'])), dataPagamento: Value(_nullableDate(r['dataPagamento'])));
  PagamentosFaturasCompanion _pagamento(Map<String, dynamic> r) => PagamentosFaturasCompanion.insert(
        id: Value(_int(r['id'])), faturaId: _int(r['faturaId']), contaId: Value(_nullableInt(r['contaId'])), valor: _double(r['valor']), data: _date(r['data']));
  TransferenciasCompanion _transferencia(Map<String, dynamic> r) => TransferenciasCompanion.insert(
        id: Value(_int(r['id'])), contaOrigemId: _int(r['contaOrigemId']), contaDestinoId: _int(r['contaDestinoId']), valor: _double(r['valor']), data: _date(r['data']), descricao: _str(r['descricao']));

  int _int(dynamic v) => (v as num?)?.toInt() ?? 0;
  int? _nullableInt(dynamic v) => v == null ? null : _int(v);
  double _double(dynamic v) => (v as num?)?.toDouble() ?? 0;
  bool _bool(dynamic v) => v == true;
  String _str(dynamic v, {String fallback = ''}) => v?.toString() ?? fallback;
  DateTime _date(dynamic v) => DateTime.tryParse(v?.toString() ?? '') ?? DateTime.now();
  DateTime? _nullableDate(dynamic v) => v == null ? null : DateTime.tryParse(v.toString());
  String _timestamp(DateTime d) => '${d.year}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}_${d.hour.toString().padLeft(2, '0')}${d.minute.toString().padLeft(2, '0')}${d.second.toString().padLeft(2, '0')}';
}

class BackupSummary {
  final int contas, categorias, lancamentos, cartoes, faturas, pagamentosFaturas, transferencias, preferencias;
  const BackupSummary({required this.contas, required this.categorias, required this.lancamentos, required this.cartoes, required this.faturas, required this.pagamentosFaturas, required this.transferencias, required this.preferencias});
  int get total => contas + categorias + lancamentos + cartoes + faturas + pagamentosFaturas + transferencias + preferencias;
}
