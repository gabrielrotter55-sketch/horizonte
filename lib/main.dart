import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/app.dart';
import 'database/database_service.dart';
import 'repositories/categoria_repository.dart';
import 'repositories/investimento_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('pt_BR');

  // Inicializa o banco e garante uma base útil de categorias recorrentes.
  final database = DatabaseService.instance.database;
  await CategoriaRepository(database).garantirCategoriasDeReceitaPadrao();
  await InvestimentoRepository().garantirCarteiraAtual();

  runApp(const HorizonteApp());
}
