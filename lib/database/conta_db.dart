import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';
import '../model/conta.dart';
import 'database_service.dart';

class ContaDB {

  final tableName = 'conta';

  Future<void> createTable(Database database) async {
    await database.execute("""CREATE TABLE IF NOT EXISTS $tableName (
    "id" INTEGER NOT NULL, 
    "titulo" TEXT NOT NULL,
    "valor" REAL NOT NULL,
    "status_sync" INTEGER NOT NULL DEFAULT 0,
    PRIMARY KEY ("id" autoincrement)
    );""");
  }

  void create({required String titulo, required double valor}) async {
    final database = await DatabaseService().database;
    await database.rawInsert(
      '''INSERT INTO $tableName (titulo, valor) VALUES (?, ?)''',
      [titulo, valor],
    );
  }

  Future<List<Conta>> fetchAll() async {
    final database = await DatabaseService().database;
    final contas = await database.rawQuery(
        '''Select * from $tableName ''');
    return contas.map((conta) => Conta.fromSqfliteDatabase(conta)).toList();
  }

  Future<Conta> fetchById(int id) async {
    final database = await DatabaseService().database;
    final contas = await database.rawQuery('''SELECT * from $tableName WHERE id = ?''', [id]);
    return Conta.fromSqfliteDatabase(contas.first);
  }

  void update({required int id, String? titulo, double? valor}) async {
    final database = await DatabaseService().database;
     await database.update(
      tableName,
      {
        if (titulo != null) 'titulo': titulo,

        'valor': valor,
      },
      where: 'id = ?',
      conflictAlgorithm: ConflictAlgorithm.rollback,
      whereArgs: [id],
    );
  }

  void delete(int id) async {
    final database = await DatabaseService().database;
    await database.rawDelete('''DELETE FROM $tableName WHERE id = ? ''', [id]);
  }

  Future<bool> isPaymentMadeThisMonth(int contaId) async {
    final database = await DatabaseService().database;

    DateTime now = DateTime.now();
    String firstDayOfMonth = DateFormat('yyyy-MM-01').format(now);
    String lastDayOfMonth = DateFormat('yyyy-MM-${DateTime(now.year, now.month + 1, 0).day}').format(now);

    // Consulta apenas movimentações não estornadas
    List<Map<String, dynamic>> result = await database.rawQuery('''
    SELECT * FROM movimentacao
    WHERE conta_id = ? AND tipo = ? AND data BETWEEN ? AND ? AND estornado = 0
  ''', [contaId, 3, firstDayOfMonth, lastDayOfMonth]);

    return result.isNotEmpty;
  }

  Future<Map<String, dynamic>> getPaymentDetails(int id) async {
    final database = await DatabaseService().database;
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    final result = await database.rawQuery(
      '''SELECT data FROM movimentacao WHERE conta_id = ? AND estornado = 0 AND data >= ? AND data <= ? ORDER BY data DESC LIMIT 1''',
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

  Future<List<Conta>> fetchPendingContasForMonth() async {
    final database = await DatabaseService().database;
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1).toIso8601String();
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0).toIso8601String();

    final result = await database.rawQuery('''
    SELECT * FROM conta
    WHERE id NOT IN (
      SELECT conta_id FROM movimentacao
      WHERE DATE(data) BETWEEN DATE(?) AND DATE(?)
      AND conta_id IS NOT NULL
    )
  ''', [firstDayOfMonth, lastDayOfMonth]);

    return result.map((row) => Conta.fromSqfliteDatabase(row)).toList();
  }


}