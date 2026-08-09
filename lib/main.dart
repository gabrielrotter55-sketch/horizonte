import 'package:flutter/material.dart';

import 'app/app.dart';
import 'database/database_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o banco
  DatabaseService.instance.database;

  runApp(const HorizonteApp());
}