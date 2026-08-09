import 'package:drift/drift.dart';

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

class Lancamentos extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get descricao => text()();

  RealColumn get valor => real()();

  BoolColumn get receita => boolean()();

  DateTimeColumn get data => dateTime()();

  IntColumn get categoriaId => integer()();

  IntColumn get contaId => integer()();

  IntColumn get cartaoId => integer().nullable()();
}

class Faturas extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get cartaoId => integer()();

  IntColumn get mesReferencia => integer()();

  IntColumn get anoReferencia => integer()();

  BoolColumn get paga =>
      boolean().withDefault(const Constant(false))();

  DateTimeColumn get dataPagamento => dateTime().nullable()();
}