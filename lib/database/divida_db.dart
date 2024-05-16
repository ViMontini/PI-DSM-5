import 'package:sqflite/sqflite.dart';
import 'package:despesa_digital/database/database_service.dart';
import 'package:despesa_digital/model/divida.dart';
import 'package:intl/intl.dart';

class DividaDB {
  final tableName = 'dividas';

  Future<void> createTable(Database database) async {
    await database.execute("""CREATE TABLE IF NOT EXISTS $tableName (
    "id" INTEGER NOT NULL, 
    "titulo" TEXT NOT NULL,
    "valor_total" REAL NOT NULL,
    "valor_pago" REAL NOT NULL DEFAULT 0,
    "data_inicio" TEXT NOT NULL, 
    "data_vencimento" TEXT NOT NULL,
    "num_parcela" INTEGER NOT NULL,
    "valor_parcela" REAL NOT NULL,
    "status" INTEGER NOT NULL,
    PRIMARY KEY ("id" autoincrement)
    );""");
  }

  Future<int> create({required String titulo, required double valor_total, required String data_inicio, required String data_vencimento,
  required int num_parcela, required double valor_parcela, required int status}) async {
    final database = await DatabaseService().database;
    return await database.rawInsert(
      '''INSERT INTO $tableName (titulo, valor_total, data_inicio, data_vencimento, num_parcela, valor_parcela, status) VALUES (?, ?, ?, ?, ?, ?, ?)''',
      [titulo, valor_total, data_inicio, data_vencimento, num_parcela, valor_parcela, status],
    );
  }

  Future<List<Divida>> fetchAll() async {
    final database = await DatabaseService().database;
    final dividas = await database.rawQuery(
        '''Select * from $tableName ''');
    return dividas.map((divida) => Divida.fromSqfliteDatabase(divida)).toList();
  }

  Future<Divida> fetchById(int id) async {
    final database = await DatabaseService().database;
    final dividas = await database.rawQuery('''SELECT * from $tableName WHERE id = ?''', [id]);
    return Divida.fromSqfliteDatabase(dividas.first);
  }

  Future<int> update({required int id, String? titulo, double? valor_total, double? valor_pago, String? data_inicio, String? data_vencimento,
    int? num_parcela, double? valor_parcela, int? status}) async {
    final database = await DatabaseService().database;
    return await database.update(
      tableName,
      {
        if (titulo != null) 'titulo': titulo,
        'valor_total': valor_total,
        'valor_pago': valor_pago,
        'data_inicio': data_inicio,
        'data_vencimento': data_vencimento,
        'num_parcela': num_parcela,
        'valor_parcela': valor_parcela,
        'status': status,
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