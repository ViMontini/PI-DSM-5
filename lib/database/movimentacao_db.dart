import 'package:sqflite/sqflite.dart';
import 'package:despesa_digital/database/database_service.dart';
import 'package:despesa_digital/model/movimentacao.dart';

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
    "meta_id" INTEGER,
    "conta_id" INTEGER,
    "divida_id" INTEGER,
    PRIMARY KEY ("id" autoincrement),
    FOREIGN KEY ("meta_id") REFERENCES "metas" ("id"),
    FOREIGN KEY ("conta_id") REFERENCES "gasto_fixo" ("id"),
    FOREIGN KEY ("divida_id") REFERENCES "dividas" ("id")
    );
  """);
  }

  Future<void> createMoviAuSal(Database database) async {
    await database.execute("""
    CREATE TRIGGER aumentar_saldo AFTER INSERT ON $tableName
    WHEN NEW.tipo = 1
    BEGIN
        UPDATE saldo SET saldo = saldo + NEW.valor;
    END;
  """);
  }

  Future<void> createMoviDiSal(Database database) async {
    await database.execute("""
    CREATE TRIGGER diminuir_saldo AFTER INSERT ON $tableName
    WHEN NEW.tipo = 0
    BEGIN
        UPDATE saldo SET saldo = saldo - NEW.valor;
    END;
  """);
  }

  Future<void> createMoviGuaMeta(Database database) async {
    await database.execute("""
    CREATE TRIGGER guardar_saldo_meta AFTER INSERT ON $tableName
    WHEN NEW.tipo = 2
    BEGIN
        UPDATE saldo SET saldo = saldo - NEW.valor;

        UPDATE metas SET valor_guardado = valor_guardado + NEW.valor WHERE id = NEW.meta_id;
    END;
  """);
  }

  Future<void> createMoviPagDiv(Database database) async {
    await database.execute("""
    CREATE TRIGGER pagamento_divida AFTER INSERT ON $tableName
    WHEN NEW.tipo = 4
    BEGIN
        UPDATE saldo SET saldo = saldo - NEW.valor;

        UPDATE dividas SET num_parcela_paga = num_parcela_paga + 1 WHERE id = NEW.divida_id;
    END;
  """);
  }

  Future<int> create({required String data, required int tipo, required double valor, required String categoria, String? descricao}) async {
    final database = await DatabaseService().database;
    return await database.rawInsert(
      '''INSERT INTO $tableName (data, tipo, valor, categoria, descricao) VALUES (?, ?, ?, ?, ?)''',
      [data, tipo, valor, categoria, descricao],
    );
  }

  Future<int> create2({required String data, required int tipo, required double valor, required String categoria, String? descricao, required int meta_id}) async {
    final database = await DatabaseService().database;
    return await database.rawInsert(
      '''INSERT INTO $tableName (data, tipo, valor, categoria, descricao, meta_id) VALUES (?, ?, ?, ?, ?, ?)''',
      [data, tipo, valor, categoria, descricao, meta_id],
    );
  }

  Future<int> create3({required String data, required int tipo, required double valor, required String categoria, String? descricao, required int conta_id}) async {
    final database = await DatabaseService().database;
    return await database.rawInsert(
      '''INSERT INTO $tableName (data, tipo, valor, categoria, descricao, conta_id) VALUES (?, ?, ?, ?, ?, ?)''',
      [data, tipo, valor, categoria, descricao, conta_id],
    );
  }

  Future<int> create4({required String data, required int tipo, required double valor, required String categoria, String? descricao, required int divida_id}) async {
    final database = await DatabaseService().database;
    return await database.rawInsert(
      '''INSERT INTO $tableName (data, tipo, valor, categoria, descricao, divida_id) VALUES (?, ?, ?, ?, ?, ?)''',
      [data, tipo, valor, categoria, descricao, divida_id],
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

  Future<int> update({required int id, String? data, int? tipo, double? valor, String? categoria, String? descricao}) async {
    final database = await DatabaseService().database;
    return await database.update(
      tableName,
      {
        'data': data,
        'tipo': tipo,
        'valor': valor,
        'categoria': categoria,
        'descricao': descricao,
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

  Future<List<Movimentacao>> fetchByData(String data) async {
    final database = await DatabaseService().database;
    final movis = await database.rawQuery('''SELECT * from $tableName WHERE data = ?''', [data]);
    return movis.map((movi) => Movimentacao.fromSqfliteDatabase(movi)).toList();
  }

}
