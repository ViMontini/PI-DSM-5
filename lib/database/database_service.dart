import 'package:despesa_digital/database/divida_db.dart';
import 'package:despesa_digital/database/meta_db.dart';
import 'package:despesa_digital/database/movimentacao_db.dart';
import 'package:despesa_digital/database/saldo_db.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initialize();
    return _database!;
  }

  Future<String> get fullPath async {
    const name = 'dd.db';
    final path = await getDatabasesPath();
    return join(path, name);
  }

  Future<Database> _initialize() async {
    final path = await fullPath;
    var database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await createMeta(db, version);
        await createDivida(db, version);
        await createMovi(db, version);
        await createSaldo(db, version);
      },
      singleInstance: true,
    );
    return database;
  }

  Future<void> createMeta(Database database, int version) async => await MetaDB().createTable(database);
  Future<void> createDivida(Database database, int version) async => await DividaDB().createTable(database);
  Future<void> createMovi(Database database, int version) async => await MovimentacaoDB().createTable(database);
  Future<void> createSaldo(Database database, int version) async => await SaldoDB().createTable(database);
}