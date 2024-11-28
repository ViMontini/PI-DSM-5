import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';
import 'database_service.dart';

class CarteiraDB {
  final tableName = 'carteira';

  // Criação da tabela carteira com saldo e data de última atualização
  Future<void> createTable(Database database) async {
    await database.execute('''CREATE TABLE IF NOT EXISTS $tableName (
      "id" INTEGER PRIMARY KEY AUTOINCREMENT,
      "saldo" REAL NOT NULL DEFAULT 0.0,
      "ultima_atualizacao" TEXT,
      "status_sync" INTEGER NOT NULL DEFAULT 0
    );''');
  }

  // Cria a carteira única com saldo inicial e data de última atualização
  Future<void> create(Database database, {required double saldo}) async {
    await database.insert(
      tableName,
      {
        'saldo': saldo,
        'ultima_atualizacao': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Adiciona um valor ao saldo da carteira e atualiza a data de última atualização
  Future<void> addSaldo(double valor) async {
    final database = await DatabaseService().database;
    await database.rawUpdate('''
      UPDATE $tableName 
      SET saldo = saldo + ?, ultima_atualizacao = ? 
      WHERE id = 1
    ''', [
      valor,
      DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())
    ]);
  }

  // Subtrai um valor do saldo da carteira e atualiza a data de última atualização
  Future<void> subtractSaldo(double valor) async {
    final database = await DatabaseService().database;
    await database.rawUpdate('''
      UPDATE $tableName 
      SET saldo = saldo - ?, ultima_atualizacao = ? 
      WHERE id = 1
    ''', [
      valor,
      DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())
    ]);
  }

  // Obter saldo atual da carteira
  Future<double> obterSaldo() async {
    final database = await DatabaseService().database;
    final result = await database.query(
        tableName,
        where: 'id = ?',
        whereArgs: [1]
    );
    if (result.isNotEmpty) {
      return result.first['saldo'] as double;
    } else {
      throw Exception("Carteira não encontrada");
    }
  }
}
