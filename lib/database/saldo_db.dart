import 'package:sqflite/sqflite.dart';
import 'package:despesa_digital/database/database_service.dart';
import 'package:despesa_digital/model/saldo.dart';
import 'package:intl/intl.dart';

class SaldoDB{

  final tableName = 'saldo';

  Future<void> createTable(Database database) async {
    await database.execute("""CREATE TABLE IF NOT EXISTS $tableName (
    "id" INTEGER NOT NULL, 
    "saldo" REAL NOT NULL,
    PRIMARY KEY ("id" autoincrement)
    );
  """);
  }

  Future<void> createSaldo(Database database) async {
    await database.execute("""INSERT INTO $tableName (saldo) VALUES (0.0);;
  """);
  }

  Future<int> create({required double saldo}) async {
    final database = await DatabaseService().database;
    return await database.rawInsert(
      '''INSERT INTO $tableName (titulo) VALUES (?)''',
      [saldo],
    );
  }

  Future<List<Saldo>> fetchAll() async {
    final database = await DatabaseService().database;
    final saldos = await database.rawQuery(
        '''Select * from $tableName ''');
    return saldos.map((saldo) => Saldo.fromSqfliteDatabase(saldo)).toList();
  }

  Future<int> update({required int id, required double saldo}) async {
    final database = await DatabaseService().database;
    return await database.update(
      tableName,
      {
        'saldo': saldo,
      },
      where: 'id = ?',
      conflictAlgorithm: ConflictAlgorithm.rollback,
      whereArgs: [id],
    );
  }

  Future<void> delete(int id) async {
    final database = await DatabaseService().database;
    await database.rawDelete('''DELETE FROM $tableName WHERE id = ? ''', [id]);
  }

}