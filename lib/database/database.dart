import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

class Contas extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get nome => text()();

  RealColumn get saldoInicial => real()();

  TextColumn get tipo => text()();
}

class Categorias extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get nome => text()();

  TextColumn get icone => text()();

  IntColumn get cor => integer()();

  BoolColumn get receita => boolean()();
}

class Cartoes extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get nome => text()();

  RealColumn get limite => real()();

  IntColumn get fechamento => integer()();

  IntColumn get vencimento => integer()();
}

@DriftDatabase(
  tables: [
    Contas,
    Categorias,
    Cartoes,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();

    final file = File(
      p.join(dir.path, 'horizonte.db'),
    );

    return NativeDatabase(file);
  });
}