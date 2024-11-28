import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sqflite/sqflite.dart';
import '../model/movimentacao.dart';
import 'database_service.dart';

class MovimentacaoDB {
  final tableName = 'movimentacao';

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
    "status_sync" INTEGER NOT NULL DEFAULT 0,
    "estornado" INTEGER NOT NULL DEFAULT 0,
    PRIMARY KEY ("id" autoincrement),
    FOREIGN KEY ("meta_id") REFERENCES "meta" ("id"),
    FOREIGN KEY ("conta_id") REFERENCES "conta" ("id"),
    FOREIGN KEY ("divida_id") REFERENCES "divida" ("id")
    );
  """);
  }

  Future<void> createMoviDiSal(Database database) async {
    await database.execute("""
    CREATE TRIGGER diminuir_saldo AFTER INSERT ON $tableName
     WHEN NEW.tipo = 0
    BEGIN
      UPDATE saldo SET saldo = saldo - NEW.valor, status_sync = 0;
    END;
  """);
  }

  Future<void> deleteMoviDiSal(Database database) async {
    await database.execute("""
    CREATE TRIGGER diminuir_saldo_del AFTER DELETE ON $tableName
    WHEN OLD.tipo = 0
    BEGIN
      UPDATE saldo SET saldo = saldo + OLD.valor, status_sync = 0;
    END;
  """);
  }

  Future<void> createMoviAuSal(Database database) async {
    await database.execute("""
    CREATE TRIGGER aumentar_saldo AFTER INSERT ON $tableName
    WHEN NEW.tipo = 1
    BEGIN
      UPDATE saldo SET saldo = saldo + NEW.valor, status_sync = 0;
    END;

  """);
  }

  Future<void> deleteMoviAuSal(Database database) async {
    await database.execute("""
    CREATE TRIGGER aumentar_saldo_del AFTER DELETE ON $tableName
    WHEN OLD.tipo = 1
    BEGIN
      UPDATE saldo SET saldo = saldo - OLD.valor, status_sync = 0;
    END;
  """);
  }

  Future<void> createMoviGuaMeta(Database database) async {
    await database.execute("""
    CREATE TRIGGER guardar_saldo_meta AFTER INSERT ON $tableName
    WHEN NEW.tipo = 2
    BEGIN
      UPDATE saldo SET saldo = saldo - NEW.valor, status_sync = 0;
      UPDATE meta SET valor_guardado = valor_guardado + NEW.valor, status_sync = 0 WHERE id = NEW.meta_id;
    END;
  """);
  }

  Future<void> deleteMoviGuaMeta(Database database) async {
    await database.execute("""
    CREATE TRIGGER guardar_saldo_meta_del AFTER DELETE ON $tableName
    WHEN OLD.tipo = 2
    BEGIN
      UPDATE saldo 
      SET saldo = saldo + OLD.valor, 
        status_sync = 0;

      UPDATE meta 
      SET valor_guardado = CASE 
                           WHEN (valor_guardado - OLD.valor) >= 0 THEN (valor_guardado - OLD.valor) 
                           ELSE 0 
                        END,
        status_sync = 0 
      WHERE id = OLD.meta_id;
    END;
  """);
  }

  Future<void> createMoviPagCon(Database database) async {
    await database.execute("""
    CREATE TRIGGER pagamento_conta AFTER INSERT ON $tableName
    WHEN NEW.tipo = 3
    BEGIN
      UPDATE saldo SET saldo = saldo - NEW.valor, status_sync = 0;
    END;
  """);
  }

  Future<void> deleteMoviPagCon(Database database) async {
    await database.execute("""
    CREATE TRIGGER pagamento_conta_del AFTER DELETE ON $tableName
    WHEN OLD.tipo = 3
    BEGIN
      UPDATE saldo SET saldo = saldo + OLD.valor, status_sync = 0;
    END;
  """);
  }

  Future<void> createMoviPagDiv(Database database) async {
    await database.execute("""
    CREATE TRIGGER pagamento_divida AFTER INSERT ON $tableName
    WHEN NEW.tipo = 4
    BEGIN
      UPDATE saldo SET saldo = saldo - NEW.valor, status_sync = 0;
      UPDATE divida SET num_parcela_paga = num_parcela_paga + 1, status_sync = 0 WHERE id = NEW.divida_id;
    END;
  """);
  }

  Future<void> deleteMoviPagDiv(Database database) async {
    await database.execute("""
    CREATE TRIGGER pagamento_divida_del AFTER DELETE ON $tableName
    WHEN OLD.tipo = 4
    BEGIN
      UPDATE saldo SET saldo = saldo + OLD.valor, status_sync = 0;
      UPDATE divida SET num_parcela_paga = num_parcela_paga - 1, status_sync = 0 WHERE id = OLD.divida_id;
    END;
  """);
  }

  Future<void> createMoviAuCart(Database database) async {
    await database.execute("""
    CREATE TRIGGER guardar_saldo_carteira_add AFTER INSERT ON $tableName
    WHEN NEW.tipo = 5
    BEGIN
      UPDATE saldo SET saldo = saldo - NEW.valor, status_sync = 0;
      UPDATE carteira SET saldo = saldo + NEW.valor, status_sync = 0 WHERE carteira.id = 1;
    END;
  """);
  }

  Future<void> deleteMoviAuCart(Database database) async {
    await database.execute("""
    CREATE TRIGGER guardar_saldo_carteira_del AFTER DELETE ON $tableName
    WHEN OLD.tipo = 5
    BEGIN
      UPDATE saldo SET saldo = saldo + OLD.valor, status_sync = 0;
      UPDATE carteira SET saldo = saldo - OLD.valor, status_sync = 0 WHERE carteira.id = 1;
    END;
  """);
  }

  Future<void> createMoviDiCart(Database database) async {
    await database.execute("""
    CREATE TRIGGER retirar_saldo_carteira_add AFTER INSERT ON $tableName
    WHEN NEW.tipo = 6
    BEGIN
      UPDATE saldo SET saldo = saldo + NEW.valor, status_sync = 0;
      UPDATE carteira SET saldo = saldo - NEW.valor, status_sync = 0 WHERE carteira.id = 1;
    END;
  """);
  }

  Future<void> deleteMoviDiCart(Database database) async {
    await database.execute("""
    CREATE TRIGGER retirar_saldo_carteira_del AFTER DELETE ON $tableName
    WHEN OLD.tipo = 6
    BEGIN
      UPDATE saldo SET saldo = saldo - OLD.valor, status_sync = 0;
      UPDATE carteira SET saldo = saldo + OLD.valor, status_sync = 0 WHERE carteira.id = 1;
    END;
  """);
  }

    Future<void> createMoviDiMeta(Database database) async {
      await database.execute("""
    CREATE TRIGGER retirar_saldo_meta_add AFTER INSERT ON $tableName
    WHEN NEW.tipo = 7
    BEGIN
      UPDATE saldo SET saldo = saldo + NEW.valor, status_sync = 0;
      UPDATE meta SET valor_guardado = valor_guardado - NEW.valor, status_sync = 0 WHERE id = NEW.meta_id;
    END;
  """);
  }
    Future<void> deleteMoviDiMeta(Database database) async {
      await database.execute("""
    CREATE TRIGGER retirar_saldo_meta_del AFTER DELETE ON $tableName
    WHEN OLD.tipo = 7
    BEGIN
      UPDATE saldo 
      SET saldo = saldo - OLD.valor, 
        status_sync = 0;

      UPDATE meta 
      SET valor_guardado = CASE 
                           WHEN (valor_guardado + OLD.valor) >= 0 THEN (valor_guardado + OLD.valor) 
                           ELSE 0 
                        END,
        status_sync = 0 
      WHERE id = OLD.meta_id;
   END;
  """);
    }

  Future<void> estornoMovimentacao(Database database) async {
    await database.execute('''
    CREATE TRIGGER IF NOT EXISTS trigger_estorno_movimentacao
    AFTER UPDATE ON movimentacao
    FOR EACH ROW
    WHEN NEW.estornado = 1 AND OLD.estornado = 0
    BEGIN
        -- Atualiza o saldo total
        UPDATE saldo
        SET saldo = saldo + 
            CASE 
                WHEN OLD.tipo IN (0, 3, 4, 5) THEN OLD.valor -- Ajusta saldo para despesas, contas, dívidas e carteira
                WHEN OLD.tipo IN (1, 6, 7) THEN -OLD.valor -- Ajusta saldo para receitas e depósitos
                ELSE 0 -- Nenhum ajuste para outros tipos
            END;

        -- Atualiza parcelas pagas da dívida
        UPDATE divida
        SET num_parcela_paga = num_parcela_paga - 1
        WHERE id = OLD.divida_id AND num_parcela_paga > 0;
    END;
  ''');
  }

  void create({
    required String data,
    required int tipo,
    required double valor,
    required String categoria,
    String? descricao,
  }) async {
    final database = await DatabaseService().database;

    // Insere os dados no banco
    await database.rawInsert(
      '''INSERT INTO $tableName (data, tipo, valor, categoria, descricao) VALUES (?, ?, ?, ?, ?)''',
      [data, tipo, valor, categoria, descricao],
    );

  }

  Future<int> create2({
    required String data,
    required int tipo,
    required double valor,
    required String categoria,
    String? descricao,
    required int meta_id,
  }) async {
    final database = await DatabaseService().database;

    // Insere os dados no banco
    int result = await database.rawInsert(
      '''INSERT INTO $tableName (data, tipo, valor, categoria, descricao, meta_id) VALUES (?, ?, ?, ?, ?, ?)''',
      [data, tipo, valor, categoria, descricao, meta_id],
    );



    return result;
  }

  Future<int> create3({
    required String data,
    required int tipo,
    required double valor,
    required String categoria,
    String? descricao,
    required int conta_id,
  }) async {
    final database = await DatabaseService().database;

    // Insere os dados no banco
    int result = await database.rawInsert(
      '''INSERT INTO $tableName (data, tipo, valor, categoria, descricao, conta_id) VALUES (?, ?, ?, ?, ?, ?)''',
      [data, tipo, valor, categoria, descricao, conta_id],
    );

    return result;
  }

  Future<int> create4({
    required String data,
    required int tipo,
    required double valor,
    required String categoria,
    String? descricao,
    required int divida_id,
  }) async {
    final database = await DatabaseService().database;

    // Insere os dados no banco
    int result = await database.rawInsert(
      '''INSERT INTO $tableName (data, tipo, valor, categoria, descricao, divida_id) VALUES (?, ?, ?, ?, ?, ?)''',
      [data, tipo, valor, categoria, descricao, divida_id],
    );

    return result;
  }

  Future<List<Movimentacao>> fetchAllAsc() async {
    final database = await DatabaseService().database;
    final movis = await database.rawQuery(
        '''Select * from $tableName ORDER BY id asc''');
    return movis.map((movi) => Movimentacao.fromSqfliteDatabase(movi)).toList();
  }

  Future<List<Movimentacao>> fetchAllDesc() async {
    final database = await DatabaseService().database;
    final movis = await database.rawQuery(
        '''Select * from $tableName ORDER BY id desc''');
    return movis.map((movi) => Movimentacao.fromSqfliteDatabase(movi)).toList();
  }

  Future<List<Movimentacao>> fetchAllAsc2({int? limit}) async {
    final database = await DatabaseService().database;

    // Construção da query com suporte a limite
    final query = '''
      SELECT * FROM movimentacao 
      ORDER BY id desc 
      ${limit != null ? 'LIMIT $limit' : ''}
    ''';

    final result = await database.rawQuery(query);

    return result.map((row) => Movimentacao.fromSqfliteDatabase(row)).toList();
  }

  Future<Movimentacao> fetchById(int id) async {
    final database = await DatabaseService().database;
    final movis = await database.rawQuery('''SELECT * from $tableName WHERE id = ?''', [id]);
    return Movimentacao.fromSqfliteDatabase(movis.first);
  }

  void update({required int id, String? data, int? tipo, double? valor, String? categoria, String? descricao}) async {
    final database = await DatabaseService().database;
    await database.update(
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

  void delete(int id) async {
    final database = await DatabaseService().database;
    await database.rawDelete('''DELETE FROM $tableName WHERE id = ? ''', [id]);
  }

  Future<List<Movimentacao>> fetchByData(String data) async {
    final database = await DatabaseService().database;
    final movis = await database.rawQuery('''SELECT * from $tableName WHERE data = ?''', [data]);
    return movis.map((movi) => Movimentacao.fromSqfliteDatabase(movi)).toList();
  }

  Future<List<Movimentacao>> fetchByDateRange(String startDate, String endDate) async {
    final db = await DatabaseService().database;
    final List<Map<String, dynamic>> maps = await db.query(
      'movimentacao',
      where: 'data BETWEEN ? AND ?',
      whereArgs: [startDate, endDate],
    );
    return List.generate(maps.length, (i) => Movimentacao.fromSqfliteDatabase(maps[i]));
  }

  Future<List<Movimentacao>> fetchByFilters(String startDate, String endDate, List<int> selectedTypes) async {
    final db = await DatabaseService().database;
    String typesCondition = selectedTypes.isNotEmpty
        ? 'AND tipo IN (${selectedTypes.join(',')})'
        : '';

    final List<Map<String, dynamic>> maps = await db.rawQuery('''
    SELECT * FROM movimentacao
    WHERE data BETWEEN ? AND ?
    $typesCondition
    ORDER BY data DESC
  ''', [startDate, endDate]);

    return List.generate(maps.length, (i) {
      return Movimentacao.fromSqfliteDatabase(maps[i]);
    });
  }

  Future<List<Movimentacao>> fetchByCategory(String categoria) async {
    final db = await DatabaseService().database;
    final result = await db.query(
      'movimentacao',
      where: 'categoria = ?',
      whereArgs: [categoria],
    );
    return result.map((row) => Movimentacao.fromSqfliteDatabase(row)).toList();
  }

  Future<void> updateCategory(int id, String novaCategoria) async {
    final db = await DatabaseService().database;
    await db.update(
      'movimentacao',
      {'categoria': novaCategoria},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> marcarComoEstornado(int movimentacaoId) async {
    final database = await DatabaseService().database;

    // Atualiza o status para estornado
    await database.update(
      'movimentacao',
      {'estornado': 1},
      where: 'id = ?',
      whereArgs: [movimentacaoId],
    );
  }


  Future<void> realizarEstorno(int movimentacaoId) async {
    final database = await DatabaseService().database;

    try {
      // Buscar a movimentação específica
      final result = await database.query(
        'movimentacao',
        columns: ['id', 'estornado', 'tipo'],
        where: 'id = ?',
        whereArgs: [movimentacaoId],
      );

      // Verificar se a movimentação foi encontrada
      if (result.isEmpty) {
        throw Exception('Movimentação não encontrada.');
      }

      final movimentacao = result.first;

      // Verificar se a movimentação já foi estornada
      if (movimentacao['estornado'] == 1) {
        throw Exception('Movimentação já foi estornada anteriormente.');
      }

      // Verificar tipos que não podem ser estornados
      final tipoNaoPermitido = [2, 5, 6, 7];
      if (tipoNaoPermitido.contains(movimentacao['tipo'])) {
        throw Exception('Estorno não permitido para este tipo de movimentação.');
      }

      // Atualizar o registro para marcar como estornado
      await database.update(
        'movimentacao',
        {'estornado': 1},
        where: 'id = ?',
        whereArgs: [movimentacaoId],
      );

      print('Estorno realizado com sucesso.');
    } catch (e) {
      print('Erro ao realizar estorno: $e');
      throw Exception('Não foi possível realizar o estorno.');
    }
  }


}
