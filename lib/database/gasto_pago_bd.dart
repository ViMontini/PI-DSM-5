import 'package:sqflite/sqflite.dart';
import 'package:despesa_digital/database/database_service.dart';
import 'package:despesa_digital/model/gasto_fixo_pagamento.dart';

class gasto_pagoDB {

  final tableName = 'gasto_fixo_pagamentos';

  Future<void> createTable(Database database) async {
    await database.execute("""CREATE TABLE IF NOT EXISTS $tableName (
    "id" INTEGER NOT NULL, 
    "gf_id" INTEGER NOT NULL,
    "data_pag" TEXT NOT NULL,
    PRIMARY KEY ("id" autoincrement),
    FOREIGN KEY ("gf_id") REFERENCES "gasto_fixo" ("id")
    );""");
  }

  Future<int> create({required int gf_id, required String data_pag}) async {
    final database = await DatabaseService().database;
    return await database.rawInsert(
      '''INSERT INTO $tableName (gf_id, data_pag) VALUES (?, ?)''',
      [gf_id, data_pag],
    );
  }

  Future<List<GF_Pagamentos>> fetchAll() async {
    final database = await DatabaseService().database;
    final gastos = await database.rawQuery(
        '''Select * from $tableName ''');
    return gastos.map((gasto_pago) => GF_Pagamentos.fromSqfliteDatabase(gasto_pago)).toList();
  }

  Future<GF_Pagamentos> fetchById(int id) async {
    final database = await DatabaseService().database;
    final gastos = await database.rawQuery('''SELECT * from $tableName WHERE id = ?''', [id]);
    return GF_Pagamentos.fromSqfliteDatabase(gastos.first);
  }

  Future<int> update({required int id, required int gf_id, required String data_pag}) async {
    final database = await DatabaseService().database;
    return await database.update(
      tableName,
      {
        if (gf_id != null) 'gf_id': gf_id,
        'data_pag': data_pag,
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