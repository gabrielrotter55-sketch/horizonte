import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Contas,
    Categorias,
    Cartoes,
    Lancamentos,
    Faturas,
    PagamentosFaturas,
    Transferencias,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.createTable(lancamentos);
        }

        if (from < 4) {
          await m.createTable(faturas);
        }

        if (from < 5) {
          await m.createTable(pagamentosFaturas);
        }

        if (from < 6) {
          await m.createTable(transferencias);
        }
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir =
        await getApplicationDocumentsDirectory();

    final file = File(
      p.join(dir.path, 'horizonte.db'),
    );

    return NativeDatabase(file);
  });
}