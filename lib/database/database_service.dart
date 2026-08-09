import 'app_database.dart';

class DatabaseService {
  DatabaseService._();

  static final DatabaseService instance = DatabaseService._();

  final AppDatabase database = AppDatabase();
}