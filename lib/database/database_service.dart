import 'package:despesa_digital/database/divida_db.dart';
import 'package:despesa_digital/database/meta_db.dart';
import 'package:despesa_digital/database/movimentacao_db.dart';
import 'package:despesa_digital/database/saldo_db.dart';
import 'package:despesa_digital/database/gasto_db.dart';
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
        await createMoviAuSal(db, version);
        await createMoviDiSal(db, version);
        await createMoviGuaMeta(db, version);
        await createMoviPagDiv(db, version);
        await createSaldo(db, version);
        await createSaldo1(db, version);
        await createGasto(db, version);
      },
      singleInstance: true,
    );
    return database;
  }

  Future<void> createMeta(Database database, int version) async => await MetaDB().createTable(database);
  Future<void> createDivida(Database database, int version) async => await DividaDB().createTable(database);
  Future<void> createMovi(Database database, int version) async => await MovimentacaoDB().createTable(database);
  Future<void> createMoviAuSal(Database database, int version) async => await MovimentacaoDB().createMoviAuSal(database);
  Future<void> createMoviDiSal(Database database, int version) async => await MovimentacaoDB().createMoviDiSal(database);
  Future<void> createMoviGuaMeta(Database database, int version) async => await MovimentacaoDB().createMoviGuaMeta(database);
  Future<void> createMoviPagDiv(Database database, int version) async => await MovimentacaoDB().createMoviPagDiv(database);
  Future<void> createSaldo(Database database, int version) async => await SaldoDB().createTable(database);
  Future<void> createSaldo1(Database database, int version) async => await SaldoDB().createSaldo(database);
  Future<void> createGasto(Database database, int version) async => await GastoDB().createTable(database);
}