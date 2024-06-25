import 'package:sqflite/sqflite.dart';
import '../model/divida.dart';
import 'database_service.dart';

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
    "num_parcela_paga" INTEGER NOT NULL DEFAULT 0,
    "valor_parcela" REAL NOT NULL,
    "status" INTEGER NOT NULL,
    PRIMARY KEY ("id" autoincrement)
    );""");
  }

  Future<int> create({required String titulo, required double valor_total, required String data_inicio, required String data_vencimento,
    required int num_parcela,  required double num_parcela_paga, required double valor_parcela, required int status}) async {
    final database = await DatabaseService().database;
    return await database.rawInsert(
      '''INSERT INTO $tableName (titulo, valor_total, data_inicio, data_vencimento, num_parcela, num_parcela_paga, valor_parcela, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?)''',
      [titulo, valor_total, data_inicio, data_vencimento, num_parcela, num_parcela_paga, valor_parcela, status],
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
    int? num_parcela, int? num_parcela_paga, double? valor_parcela, int? status}) async {
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
        'num_parcela_paga': num_parcela,
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

  Future<List<Divida>> fetchByDatas(String data) async {
    final database = await DatabaseService().database;
    final dividas = await database.rawQuery(
      '''SELECT * FROM $tableName WHERE data_inicio <= ? AND data_vencimento >= ?''', [data, data],
    );
    return dividas.map((divida) => Divida.fromSqfliteDatabase(divida)).toList();
  }

  Future<Map<String, dynamic>> getPaymentDetails(int id) async {
    final database = await DatabaseService().database;
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    final result = await database.rawQuery(
      '''SELECT data FROM movimentacoes WHERE divida_id = ? AND data >= ? AND data <= ? ORDER BY data DESC LIMIT 1''',
      [id, firstDayOfMonth.toIso8601String(), lastDayOfMonth.toIso8601String()],
    );

    if (result.isNotEmpty) {
      return {
        'paymentMade': true,
        'paymentDate': DateTime.parse(result.first['data'] as String),
      };
    } else {
      return {
        'paymentMade': false,
        'paymentDate': null,
      };
    }
  }

}
