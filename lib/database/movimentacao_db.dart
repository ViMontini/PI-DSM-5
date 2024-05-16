import 'package:sqflite/sqflite.dart';
import 'package:despesa_digital/database/database_service.dart';
import 'package:despesa_digital/model/movimentacao.dart';
import 'package:intl/intl.dart';

class MovimentacaoDB {
  final tableName = 'movimentacoes';

  Future<void> createTable(Database database) async {
    await database.execute("""CREATE TABLE IF NOT EXISTS $tableName (
    "id" INTEGER NOT NULL, 
    "data" TEXT NOT NULL,
    "tipo" INTEGER NOT NULL,
    "valor" REAL NOT NULL,
    "categoria" TEXT NOT NULL,
    "descricao" TEXT, 
    "recorrente" INTEGER NOT NULL,
    PRIMARY KEY ("id" autoincrement)
    );""");
  }

  Future<int> create({required String data, required int tipo, required double valor, required String categoria, String? descricao, required int recorrente}) async {
    final database = await DatabaseService().database;
    return await database.rawInsert(
      '''INSERT INTO $tableName (data, tipo, valor, categoria, descricao, recorrente) VALUES (?, ?, ?, ?, ?, ?)''',
      [data, tipo, valor, categoria, descricao, recorrente],
    );
  }

  Future<List<Movimentacao>> fetchAll() async {
    final database = await DatabaseService().database;
    final movis = await database.rawQuery(
        '''Select * from $tableName ''');
    return movis.map((movi) => Movimentacao.fromSqfliteDatabase(movi)).toList();
  }

  Future<Movimentacao> fetchById(int id) async {
    final database = await DatabaseService().database;
    final movis = await database.rawQuery('''SELECT * from $tableName WHERE id = ?''', [id]);
    return Movimentacao.fromSqfliteDatabase(movis.first);
  }

  Future<int> update({required int id, String? data, int? tipo, double? valor, String? categoria, String? descricao, int? recorrente}) async {
    final database = await DatabaseService().database;
    return await database.update(
      tableName,
      {
        'data': data,
        'tipo': tipo,
        'valor': valor,
        'categoria': categoria,
        'descricao': descricao,
        'recorrente': recorrente,
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

  Future<Movimentacao> fetchByData(String data) async {
    final database = await DatabaseService().database;
    final movis = await database.rawQuery('''SELECT * from $tableName WHERE data = ?''', [data]);
    return Movimentacao.fromSqfliteDatabase(movis.first);
  }

}