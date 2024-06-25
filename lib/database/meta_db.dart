import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';

import '../model/meta.dart';
import 'database_service.dart';

class MetaDB{
  final tableName = 'metas';

  Future<void> createTable(Database database) async {
    await database.execute("""CREATE TABLE IF NOT EXISTS $tableName (
    "id" INTEGER NOT NULL, 
    "titulo" TEXT NOT NULL,
    "descricao" TEXT,
    "valor_total" REAL NOT NULL,
    "valor_guardado" REAL NOT NULL DEFAULT 0, 
    "data_limite" TEXT DEFAULT (strftime('%d/%m/%Y', 'now')),
    PRIMARY KEY ("id" autoincrement)
    );""");
  }

  Future<int> create({required String titulo, String? descricao, required double valor_total, String? data_limite}) async {
    final database = await DatabaseService().database;
    return await database.rawInsert(
      '''INSERT INTO $tableName (titulo, descricao, valor_total, data_limite) VALUES (?, ?, ?, ?)''',
      [titulo, descricao, valor_total, data_limite],
    );
  }

  Future<List<Meta>> fetchAll() async {
    final database = await DatabaseService().database;
    final metas = await database.rawQuery(
        '''Select * from $tableName ''');
    return metas.map((meta) => Meta.fromSqfliteDatabase(meta)).toList();
  }

  Future<Meta> fetchById(int id) async {
    final database = await DatabaseService().database;
    final meta = await database.rawQuery('''SELECT * from $tableName WHERE id = ?''', [id]);
    return Meta.fromSqfliteDatabase(meta.first);
  }

  Future<int> update({required int id, String? titulo, String? descricao, double? valor_total, double? valor_guardado, DateFormat? data_limite}) async {
    final database = await DatabaseService().database;
    return await database.update(
      tableName,
      {
        if (titulo != null) 'titulo': titulo,
        'descricao': descricao,
        'valor_total': valor_total,
        'valor_guardado': valor_guardado,
        'data_limite': data_limite,
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