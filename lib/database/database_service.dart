import 'package:despesa_digital/database/saldo_db.dart';
import 'package:despesa_digital/database/user_db.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'conta_db.dart';
import 'divida_db.dart';
import 'meta_db.dart';
import 'movi_db.dart';

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
        await createUser(db, version);
        await createMeta(db, version);
        await createDivida(db, version);
        await createMovi(db, version);
        await createMoviAuSal(db, version);
        await createMoviDiSal(db, version);
        await createMoviGuaMeta(db, version);
        await createMoviPagCon(db, version);
        await deleteMoviAuSal(db, version);
        await deleteMoviDiSal(db, version);
        await deleteMoviGuaMeta(db, version);
        await deleteMoviPagCon(db, version);
        await deleteMoviPagDiv(db, version);
        await createMoviPagDiv(db, version);
        await createSaldo(db, version);
        await createSaldo1(db, version);
        await createGasto(db, version);
      },
      singleInstance: true,
    );
    return database;
  }

  Future<void> createUser(Database database, int version) async => await UserDB().createUser(database);
  Future<void> createMeta(Database database, int version) async => await MetaDB().createTable(database);
  Future<void> createDivida(Database database, int version) async => await DividaDB().createTable(database);
  Future<void> createMovi(Database database, int version) async => await MovimentacaoDB().createTable(database);
  Future<void> createMoviAuSal(Database database, int version) async => await MovimentacaoDB().createMoviAuSal(database);
  Future<void> createMoviDiSal(Database database, int version) async => await MovimentacaoDB().createMoviDiSal(database);
  Future<void> createMoviGuaMeta(Database database, int version) async => await MovimentacaoDB().createMoviGuaMeta(database);
  Future<void> createMoviPagCon(Database database, int version) async => await MovimentacaoDB().createMoviPagCon(database);
  Future<void> deleteMoviPagCon(Database database, int version) async => await MovimentacaoDB().deleteMoviPagCon(database);
  Future<void> deleteMoviAuSal(Database database, int version) async => await MovimentacaoDB().deleteMoviAuSal(database);
  Future<void> deleteMoviDiSal(Database database, int version) async => await MovimentacaoDB().deleteMoviDiSal(database);
  Future<void> deleteMoviGuaMeta(Database database, int version) async => await MovimentacaoDB().deleteMoviGuaMeta(database);
  Future<void> createMoviPagDiv(Database database, int version) async => await MovimentacaoDB().createMoviPagDiv(database);
  Future<void> deleteMoviPagDiv(Database database, int version) async => await MovimentacaoDB().deleteMoviPagDiv(database);
  Future<void> createSaldo(Database database, int version) async => await SaldoDB().createTable(database);
  Future<void> createSaldo1(Database database, int version) async => await SaldoDB().createSaldo(database);
  Future<void> createGasto(Database database, int version) async => await ContaDB().createTable(database);
}