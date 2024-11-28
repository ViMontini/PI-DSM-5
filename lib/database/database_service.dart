import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:despesa_digital/database/carteira_db.dart';
import 'package:despesa_digital/database/saldo_db.dart';
import 'package:despesa_digital/database/user_db.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'conta_db.dart';
import 'divida_db.dart';
import 'meta_db.dart';
import 'movi_db.dart';

class DatabaseService {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initialize();
    return _database!;
  }

  Future<String> get fullPath async {
    const name = 'dd.db';
    final path = await getDatabasesPath();
    return join(path, name);
  }

  Future<bool> isConnectedToInternet() async {
    try {
      // Verifica se está conectado a Wi-Fi ou dados móveis
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return false;
      }

      // Tenta fazer uma conexão com um endpoint externo
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } catch (e) {
      print('Erro ao verificar conectividade: $e');
    }
    return false;
  }

  // Método de sincronização na inicialização do aplicativo
  Future<void> syncDataOnStart() async {
    final db = await database;

    // Verifica se há conexão com a internet
    bool isConnected = await isConnectedToInternet();
    if (!isConnected) {
      print('Sem conexão com a internet. Sincronização adiada.');
      return; // Não realiza a sincronização sem internet
    }

    try {
      // Sincronizar os dados de carteira e saldo individualmente
      await syncCarteiraToFirestore(db);
      await syncSaldoToFirestore(db);
      await syncUsuarioToFirestore(db);
      await syncMovimentacaoToFirestore(db);
      await syncMetaToFirestore(db);
      await syncDividaToFirestore(db);
      await syncContaToFirestore(db);

      // Sincronizar os dados das demais tabelas
      await syncCarteiraFromFirestore(db);
      await syncSaldoFromFirestore(db);
      await syncUsuarioFromFirestore(db);
      await syncMovimentacaoFromFirestore(db);
      await syncMetaFromFirestore(db);
      await syncDividaFromFirestore(db);
      await syncContaFromFirestore(db);

      print('Sincronização concluída com sucesso.');
    } catch (e) {
      print('Erro durante a sincronização: $e');
    }
  }

  // Método de sincronização na inicialização do aplicativo
  Future<void> syncMoviToFB() async {
    if (await isConnectedToInternet()) {
      try {
        final db = await database;
        await syncMovimentacaoToFirestore(db);
        await syncSaldoToFirestore2(db);
        print('syncMoviToFB concluído com sucesso.');
      } catch (e) {
        print('Erro em syncMoviToFB: $e');
      }
    } else {
      print('Sem conexão com a internet. Sincronização adiada: syncMoviToFB');
    }
  }

  Future<void> syncMoviDividaToFB() async {
    if (await isConnectedToInternet()) {
      try {
        final db = await database;
        await syncMovimentacaoToFirestore(db);
        await syncDividaToFirestore(db);
        await syncSaldoToFirestore2(db);
        print('syncMoviDividaToFB concluído com sucesso.');
      } catch (e) {
        print('Erro em syncMoviDividaToFB: $e');
      }
    } else {
      print('Sem conexão com a internet. Sincronização adiada: syncMoviDividaToFB');
    }
  }

  Future<void> syncMoviContaToFB() async {
    if (await isConnectedToInternet()) {
      try {
        final db = await database;
        await syncMovimentacaoToFirestore(db);
        await syncContaToFirestore(db);
        await syncSaldoToFirestore2(db);
        print('syncMoviContaToFB concluído com sucesso.');
      } catch (e) {
        print('Erro em syncMoviContaToFB: $e');
      }
    } else {
      print('Sem conexão com a internet. Sincronização adiada: syncMoviContaToFB');
    }
  }

  Future<void> syncMoviMetaToFB() async {
    if (await isConnectedToInternet()) {
      try {
        final db = await database;
        await syncMovimentacaoToFirestore(db);
        await syncMetaToFirestore(db);
        await syncSaldoToFirestore2(db);
        print('syncMoviMetaToFB concluído com sucesso.');
      } catch (e) {
        print('Erro em syncMoviMetaToFB: $e');
      }
    } else {
      print('Sem conexão com a internet. Sincronização adiada: syncMoviMetaToFB');
    }
  }

  Future<void> syncMoviCarteToFB() async {
    if (await isConnectedToInternet()) {
      try {
        final db = await database;
        await syncMovimentacaoToFirestore(db);
        await syncCarteiraToFirestore(db);
        await syncSaldoToFirestore2(db);
        print('syncMoviCarteToFB concluído com sucesso.');
      } catch (e) {
        print('Erro em syncMoviCarteToFB: $e');
      }
    } else {
      print('Sem conexão com a internet. Sincronização adiada: syncMoviCarteToFB');
    }
  }

  Future<void> syncUserToFB() async {
    if (await isConnectedToInternet()) {
      try {
        final db = await database;
        await syncUsuarioToFirestore(db);
        print('syncUserToFB concluído com sucesso.');
      } catch (e) {
        print('Erro em syncUserToFB: $e');
      }
    } else {
      print('Sem conexão com a internet. Sincronização adiada: syncUserToFB');
    }
  }

  Future<void> syncMetaToFB() async {
    if (await isConnectedToInternet()) {
      try {
        final db = await database;
        await syncMetaToFirestore(db);
        print('syncMetaToFB concluído com sucesso.');
      } catch (e) {
        print('Erro em syncMetaToFB: $e');
      }
    } else {
      print('Sem conexão com a internet. Sincronização adiada: syncMetaToFB');
    }
  }

  Future<void> syncDividaToFB() async {
    if (await isConnectedToInternet()) {
      try {
        final db = await database;
        await syncDividaToFirestore(db);
        print('syncDividaToFB concluído com sucesso.');
      } catch (e) {
        print('Erro em syncDividaToFB: $e');
      }
    } else {
      print('Sem conexão com a internet. Sincronização adiada: syncDividaToFB');
    }
  }

  Future<void> syncContaToFB() async {
    if (await isConnectedToInternet()) {
      try {
        final db = await database;
        await syncContaToFirestore(db);
        print('syncContaToFB concluído com sucesso.');
      } catch (e) {
        print('Erro em syncContaToFB: $e');
      }
    } else {
      print('Sem conexão com a internet. Sincronização adiada: syncContaToFB');
    }
  }

  Future<void> syncMoviDeleteToFB() async {
    if (await isConnectedToInternet()) {
      try {
        final db = await database;
        await syncMovimentacaoToFirestore(db);
        await syncSaldoToFirestore2(db);
        await syncDividaToFirestore(db);
        await syncContaToFirestore(db);
        await syncMetaToFirestore(db);
        await syncCarteiraToFirestore(db);
        print('syncMoviDeleteToFB concluído com sucesso.');
      } catch (e) {
        print('Erro em syncMoviDeleteToFB: $e');
      }
    } else {
      print('Sem conexão com a internet. Sincronização adiada: syncMoviDeleteToFB');
    }
  }

  // Sincronização da tabela usuario para o Firestore
  Future<void> syncUsuarioToFirestore(Database db) async {
    final firestore = FirebaseFirestore.instance;

    // Consulta para obter registros com `status_sync = 0`
    List<Map<String, dynamic>> unsyncedData = await db.query(
        'usuario',
        where: 'status_sync = 0'
    );

    for (var item in unsyncedData) {
      try {
        // Sincroniza o registro com o Firestore usando o ID como documento
        await firestore.collection('usuarios').doc(item['id'].toString()).set(item);

        // Atualize o `status_sync` para `1` após sincronizar com sucesso
        await db.update(
            'usuario',
            {'status_sync': 1},  // Muda status_sync para 1, indicando sincronizado
            where: 'id = ?',
            whereArgs: [item['id']]
        );

      } catch (e) {
        print("Erro ao sincronizar o item com ID ${item['id']}: $e");
        // Se houver um erro, não atualize o status_sync, assim ele permanece para tentativa futura
      }
    }
  }

  Future<void> syncSaldoToFirestore(Database db) async {
    final firestore = FirebaseFirestore.instance;

    try {
      // Consulta para obter registros com `status_sync = 0`
      List<Map<String, dynamic>> unsyncedData = await db.query(
        'saldo',
        where: 'status_sync = 0',
      );

      for (var item in unsyncedData) {
        try {
          // Sincroniza o registro com o Firestore usando o ID como documento
          await firestore.collection('saldos').doc(item['id'].toString()).set(item);

          // Atualize o `status_sync` para `1` após sincronizar com sucesso
          await db.update(
            'saldo',
            {'status_sync': 1}, // Muda status_sync para 1, indicando sincronizado
            where: 'id = ?',
            whereArgs: [item['id']],
          );
        } catch (e) {
          print("Erro ao sincronizar o item com ID ${item['id']}: $e");
          // Se houver um erro, não atualize o status_sync, assim ele permanece para tentativa futura
        }
      }
    } catch (e) {
      print('Erro ao consultar saldo para sincronização: $e');
    }
  }

  Future<void> syncSaldoToFirestore2(Database db) async {
    final firestore = FirebaseFirestore.instance;

    try {
      // Aguarda um pequeno atraso para dar tempo à trigger de atualizar o saldo no banco
      await Future.delayed(Duration(milliseconds: 1000));

      // Consulta para obter registros com `status_sync = 0`
      List<Map<String, dynamic>> unsyncedData = await db.query(
        'saldo',
        where: 'status_sync = 0',
      );

      for (var item in unsyncedData) {
        try {
          // Sincroniza o registro com o Firestore usando o ID como documento
          await firestore.collection('saldos').doc(item['id'].toString()).set(item);

          // Atualize o `status_sync` para `1` após sincronizar com sucesso
          await db.update(
            'saldo',
            {'status_sync': 1}, // Muda status_sync para 1, indicando sincronizado
            where: 'id = ?',
            whereArgs: [item['id']],
          );
        } catch (e) {
          print("Erro ao sincronizar o item com ID ${item['id']}: $e");
          // Se houver um erro, não atualize o status_sync, assim ele permanece para tentativa futura
        }
      }
    } catch (e) {
      print('Erro ao consultar saldo para sincronização: $e');
    }
  }


  Future<void> syncMovimentacaoToFirestore(Database db) async {
    final firestore = FirebaseFirestore.instance;

    // Consulta para obter registros com `status_sync = 0`
    List<Map<String, dynamic>> unsyncedData = await db.query(
        'movimentacao',
        where: 'status_sync = 0'
    );

    for (var item in unsyncedData) {
      try {
        // Sincroniza o registro com o Firestore usando o ID como documento
        await firestore.collection('movimentacoes').doc(item['id'].toString()).set(item);

        // Atualize o `status_sync` para `1` após sincronizar com sucesso
        await db.update(
            'movimentacao',
            {'status_sync': 1},  // Muda status_sync para 1, indicando sincronizado
            where: 'id = ?',
            whereArgs: [item['id']]
        );

      } catch (e) {
        print("Erro ao sincronizar o item com ID ${item['id']}: $e");
        // Se houver um erro, não atualize o status_sync, assim ele permanece para tentativa futura
      }
    }
  }

  Future<void> syncMetaToFirestore(Database db) async {
    final firestore = FirebaseFirestore.instance;

    // Consulta para obter registros com `status_sync = 0`
    List<Map<String, dynamic>> unsyncedData = await db.query(
        'meta',
        where: 'status_sync = 0'
    );

    for (var item in unsyncedData) {
      try {
        // Sincroniza o registro com o Firestore usando o ID como documento
        await firestore.collection('metas').doc(item['id'].toString()).set(item);

        // Atualize o `status_sync` para `1` após sincronizar com sucesso
        await db.update(
            'meta',
            {'status_sync': 1},  // Muda status_sync para 1, indicando sincronizado
            where: 'id = ?',
            whereArgs: [item['id']]
        );

      } catch (e) {
        print("Erro ao sincronizar o item com ID ${item['id']}: $e");
        // Se houver um erro, não atualize o status_sync, assim ele permanece para tentativa futura
      }
    }
  }

  Future<void> syncDividaToFirestore(Database db) async {
    final firestore = FirebaseFirestore.instance;

    // Consulta para obter registros com `status_sync = 0`
    List<Map<String, dynamic>> unsyncedData = await db.query(
        'divida',
        where: 'status_sync = 0'
    );

    for (var item in unsyncedData) {
      try {
        // Sincroniza o registro com o Firestore usando o ID como documento
        await firestore.collection('dividas').doc(item['id'].toString()).set(item);

        // Atualize o `status_sync` para `1` após sincronizar com sucesso
        await db.update(
            'divida',
            {'status_sync': 1},  // Muda status_sync para 1, indicando sincronizado
            where: 'id = ?',
            whereArgs: [item['id']]
        );

      } catch (e) {
        print("Erro ao sincronizar o item com ID ${item['id']}: $e");
        // Se houver um erro, não atualize o status_sync, assim ele permanece para tentativa futura
      }
    }
  }

  Future<void> syncContaToFirestore(Database db) async {
    final firestore = FirebaseFirestore.instance;

    // Consulta para obter registros com `status_sync = 0`
    List<Map<String, dynamic>> unsyncedData = await db.query(
        'conta',
        where: 'status_sync = 0'
    );

    for (var item in unsyncedData) {
      try {
        // Sincroniza o registro com o Firestore usando o ID como documento
        await firestore.collection('contas').doc(item['id'].toString()).set(item);

        // Atualize o `status_sync` para `1` após sincronizar com sucesso
        await db.update(
            'conta',
            {'status_sync': 1},  // Muda status_sync para 1, indicando sincronizado
            where: 'id = ?',
            whereArgs: [item['id']]
        );

      } catch (e) {
        print("Erro ao sincronizar o item com ID ${item['id']}: $e");
        // Se houver um erro, não atualize o status_sync, assim ele permanece para tentativa futura
      }
    }
  }

  Future<void> syncCarteiraToFirestore(Database db) async {
    final firestore = FirebaseFirestore.instance;

    // Consulta para obter registros com `status_sync = 0`
    List<Map<String, dynamic>> unsyncedData = await db.query(
        'carteira',
        where: 'status_sync = 0'
    );

    for (var item in unsyncedData) {
      try {
        // Sincroniza o registro com o Firestore usando o ID como documento
        await firestore.collection('carteiras').doc(item['id'].toString()).set(item);

        // Atualize o `status_sync` para `1` após sincronizar com sucesso
        await db.update(
            'carteira',
            {'status_sync': 1},  // Muda status_sync para 1, indicando sincronizado
            where: 'id = ?',
            whereArgs: [item['id']]
        );

      } catch (e) {
        print("Erro ao sincronizar o item com ID ${item['id']}: $e");
        // Se houver um erro, não atualize o status_sync, assim ele permanece para tentativa futura
      }
    }
  }

  // Sincronização das tabelas para o Firestore
  Future<void> syncToFirestore(Database db) async {
    await syncUsuarioToFirestore(db);
    await syncSaldoToFirestore(db);
    await syncMovimentacaoToFirestore(db);
    await syncMetaToFirestore(db);
    await syncDividaToFirestore(db);
    await syncContaToFirestore(db);
    await syncCarteiraToFirestore(db);
  }

  Future<void> syncUsuarioFromFirestore(Database db) async {
    final firestore = FirebaseFirestore.instance;

    // Obter todos os documentos da coleção 'usuarios' no Firestore
    QuerySnapshot<Map<String, dynamic>> snapshot = await firestore.collection('usuarios').get();

    for (var doc in snapshot.docs) {
      Map<String, dynamic> data = doc.data();

      // Verificar se o usuário já existe no SQLite
      List<Map<String, dynamic>> existingUser = await db.query(
        'usuario',
        where: 'id = ?',
        whereArgs: [data['id']],
      );

      if (existingUser.isEmpty) {
        // Inserir o usuário no SQLite se ele ainda não existir
        await db.insert('usuario', data);
      } else {
        // Atualizar o usuário no SQLite se ele já existir
        await db.update(
          'usuario',
          data,
          where: 'id = ?',
          whereArgs: [data['id']],
        );
      }
    }
  }

  Future<void> syncSaldoFromFirestore(Database db) async {
    final firestore = FirebaseFirestore.instance;

    // Obter todos os documentos da coleção 'saldos' no Firestore
    QuerySnapshot<Map<String, dynamic>> snapshot = await firestore.collection('saldos').get();

    for (var doc in snapshot.docs) {
      Map<String, dynamic> data = doc.data();

      // Verificar se o saldo já existe no SQLite
      List<Map<String, dynamic>> existingSaldo = await db.query(
        'saldo',
        where: 'id = ?',
        whereArgs: [data['id']],
      );

      if (existingSaldo.isEmpty) {
        // Inserir o saldo no SQLite se ele ainda não existir
        await db.insert('saldo', data);
      } else {
        // Atualizar o saldo no SQLite se ele já existir
        await db.update(
          'saldo',
          data,
          where: 'id = ?',
          whereArgs: [data['id']],
        );
      }
    }
  }

  Future<void> syncMovimentacaoFromFirestore(Database db) async {
    final firestore = FirebaseFirestore.instance;

    // Obter todos os documentos da coleção 'movimentacoes' no Firestore
    QuerySnapshot<Map<String, dynamic>> snapshot = await firestore.collection('movimentacoes').get();

    for (var doc in snapshot.docs) {
      Map<String, dynamic> data = doc.data();

      // Verificar se o movimentacao já existe no SQLite
      List<Map<String, dynamic>> existingSaldo = await db.query(
        'movimentacao',
        where: 'id = ?',
        whereArgs: [data['id']],
      );

      if (existingSaldo.isEmpty) {
        // Inserir o movimentacao no SQLite se ele ainda não existir
        await db.insert('movimentacao', data);
      } else {
        // Atualizar o movimentacao no SQLite se ele já existir
        await db.update(
          'movimentacao',
          data,
          where: 'id = ?',
          whereArgs: [data['id']],
        );
      }
    }
  }

  Future<void> syncMetaFromFirestore(Database db) async {
    final firestore = FirebaseFirestore.instance;

    // Obter todos os documentos da coleção 'metas' no Firestore
    QuerySnapshot<Map<String, dynamic>> snapshot = await firestore.collection('metas').get();

    for (var doc in snapshot.docs) {
      Map<String, dynamic> data = doc.data();

      // Verificar se o meta já existe no SQLite
      List<Map<String, dynamic>> existingSaldo = await db.query(
        'meta',
        where: 'id = ?',
        whereArgs: [data['id']],
      );

      if (existingSaldo.isEmpty) {
        // Inserir o meta no SQLite se ele ainda não existir
        await db.insert('meta', data);
      } else {
        // Atualizar o meta no SQLite se ele já existir
        await db.update(
          'meta',
          data,
          where: 'id = ?',
          whereArgs: [data['id']],
        );
      }
    }
  }

  Future<void> syncDividaFromFirestore(Database db) async {
    final firestore = FirebaseFirestore.instance;

    // Obter todos os documentos da coleção 'dividas' no Firestore
    QuerySnapshot<Map<String, dynamic>> snapshot = await firestore.collection('dividas').get();

    for (var doc in snapshot.docs) {
      Map<String, dynamic> data = doc.data();

      // Verificar se o divida já existe no SQLite
      List<Map<String, dynamic>> existingSaldo = await db.query(
        'divida',
        where: 'id = ?',
        whereArgs: [data['id']],
      );

      if (existingSaldo.isEmpty) {
        // Inserir o divida no SQLite se ele ainda não existir
        await db.insert('divida', data);
      } else {
        // Atualizar o divida no SQLite se ele já existir
        await db.update(
          'divida',
          data,
          where: 'id = ?',
          whereArgs: [data['id']],
        );
      }
    }
  }

  Future<void> syncContaFromFirestore(Database db) async {
    final firestore = FirebaseFirestore.instance;

    // Obter todos os documentos da coleção 'contas' no Firestore
    QuerySnapshot<Map<String, dynamic>> snapshot = await firestore.collection('contas').get();

    for (var doc in snapshot.docs) {
      Map<String, dynamic> data = doc.data();

      // Verificar se o conta já existe no SQLite
      List<Map<String, dynamic>> existingSaldo = await db.query(
        'conta',
        where: 'id = ?',
        whereArgs: [data['id']],
      );

      if (existingSaldo.isEmpty) {
        // Inserir o conta no SQLite se ele ainda não existir
        await db.insert('conta', data);
      } else {
        // Atualizar o conta no SQLite se ele já existir
        await db.update(
          'conta',
          data,
          where: 'id = ?',
          whereArgs: [data['id']],
        );
      }
    }
  }

  Future<void> syncCarteiraFromFirestore(Database db) async {
    final firestore = FirebaseFirestore.instance;

    // Obter todos os documentos da coleção 'carteiras' no Firestore
    QuerySnapshot<Map<String, dynamic>> snapshot = await firestore.collection('carteiras').get();

    for (var doc in snapshot.docs) {
      Map<String, dynamic> data = doc.data();

      // Verificar se o carteira já existe no SQLite
      List<Map<String, dynamic>> existingSaldo = await db.query(
        'carteira',
        where: 'id = ?',
        whereArgs: [data['id']],
      );

      if (existingSaldo.isEmpty) {
        // Inserir o carteira no SQLite se ele ainda não existir
        await db.insert('carteira', data);
      } else {
        // Atualizar o carteira no SQLite se ele já existir
        await db.update(
          'carteira',
          data,
          where: 'id = ?',
          whereArgs: [data['id']],
        );
      }
    }
  }

  // Funções para baixar dados do Firestore para o SQLite
  Future<void> syncFromFirestore(Database db) async {
    await syncUsuarioFromFirestore(db);
    await syncSaldoFromFirestore(db);
    await syncMovimentacaoFromFirestore(db);
    await syncMetaFromFirestore(db);
    await syncDividaFromFirestore(db);
    await syncContaFromFirestore(db);
    await syncCarteiraFromFirestore(db);
  }

  Future<void> checkAndCreateBalanceAndWallet() async {
    final db = await database;

    // Verificar se a carteira e o saldo já existem
    final saldoExists = (await db.query('saldo')).isNotEmpty;
    final carteiraExists = (await db.query('carteira')).isNotEmpty;

    // Se o saldo não existe, crie um registro inicial
    if (!saldoExists) {
      await db.insert('saldo', {'valor': 0.0, 'status_sync': 0});
    }

    // Se a carteira não existe, crie um registro inicial
    if (!carteiraExists) {
      await db.insert('carteira', {'saldo': 0.0, 'status_sync': 0});
    }
  }


  Future<void> loadBalanceAndWalletFromFirestore(Database db) async {
    final firestore = FirebaseFirestore.instance;

    final saldoDoc = await firestore.collection('saldo').doc('unique_saldo_id').get();
    if (saldoDoc.exists) {
      await db.update('saldo', {'saldo': saldoDoc.data()?['saldo'], 'status_sync': 1});
    }

    final carteiraDoc = await firestore.collection('carteira').doc('unique_carteira_id').get();
    if (carteiraDoc.exists) {
      await db.update('carteira', {'saldo': carteiraDoc.data()?['saldo'], 'status_sync': 1});
    }
  }


  Future<Database> _initialize() async {
    final path = await fullPath;
    var database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await createUser(db, version);
        await createMeta(db, version);
        await deleteMeta(db, version);
        await createDivida(db, version);
        await updateStatus(db, version);
        await createMovi(db, version);
        await createMoviAuSal(db, version);
        await createMoviDiSal(db, version);
        await createMoviGuaMeta(db, version);
        await createMoviPagCon(db, version);
        await deleteMoviAuSal(db, version);
        await deleteMoviDiSal(db, version);
        await deleteMoviGuaMeta(db, version);
        await deleteMoviPagCon(db, version);
        await deleteMoviPagDiv(db, version);
        await createMoviPagDiv(db, version);
        await createMoviAuCart(db, version);
        await deleteMoviAuCart(db, version);
        await createMoviDiCart(db, version);
        await deleteMoviDiCart(db, version);
        await createMoviDiMeta(db, version);
        await deleteMoviDiMeta(db, version);
        await estornoMovimentacao(db, version);
        await createSaldo(db, version);
        await createSaldo1(db, version);
        await createGasto(db, version);
        await createCarteira(db, version);
        await createCarteiraEntry(db, version);
      },
      singleInstance: true,
    );
    return database;
  }

  Future<void> createUser(Database database, int version) async => await UserDB().createUser(database);
  Future<void> createMeta(Database database, int version) async => await MetaDB().createTable(database);
  Future<void> deleteMeta(Database database, int version) async => await MetaDB().deleteMeta(database);
  Future<void> createDivida(Database database, int version) async => await DividaDB().createTable(database);
  Future<void> updateStatus(Database database, int version) async => await DividaDB().updateStatus(database);
  Future<void> createMovi(Database database, int version) async => await MovimentacaoDB().createTable(database);
  Future<void> createMoviAuSal(Database database, int version) async => await MovimentacaoDB().createMoviAuSal(database);
  Future<void> createMoviDiSal(Database database, int version) async => await MovimentacaoDB().createMoviDiSal(database);
  Future<void> createMoviGuaMeta(Database database, int version) async => await MovimentacaoDB().createMoviGuaMeta(database);
  Future<void> createMoviPagCon(Database database, int version) async => await MovimentacaoDB().createMoviPagCon(database);
  Future<void> deleteMoviPagCon(Database database, int version) async => await MovimentacaoDB().deleteMoviPagCon(database);
  Future<void> deleteMoviAuSal(Database database, int version) async => await MovimentacaoDB().deleteMoviAuSal(database);
  Future<void> deleteMoviDiSal(Database database, int version) async => await MovimentacaoDB().deleteMoviDiSal(database);
  Future<void> deleteMoviGuaMeta(Database database, int version) async => await MovimentacaoDB().deleteMoviGuaMeta(database);
  Future<void> createMoviPagDiv(Database database, int version) async => await MovimentacaoDB().createMoviPagDiv(database);
  Future<void> deleteMoviPagDiv(Database database, int version) async => await MovimentacaoDB().deleteMoviPagDiv(database);
  Future<void> createMoviAuCart(Database database, int version) async => await MovimentacaoDB().createMoviAuCart(database);
  Future<void> deleteMoviAuCart(Database database, int version) async => await MovimentacaoDB().deleteMoviAuCart(database);
  Future<void> createMoviDiCart(Database database, int version) async => await MovimentacaoDB().createMoviDiCart(database);
  Future<void> deleteMoviDiCart(Database database, int version) async => await MovimentacaoDB().deleteMoviDiCart(database);
  Future<void> createMoviDiMeta(Database database, int version) async => await MovimentacaoDB().createMoviDiMeta(database);
  Future<void> deleteMoviDiMeta(Database database, int version) async => await MovimentacaoDB().deleteMoviDiMeta(database);
  Future<void> estornoMovimentacao(Database database, int version) async => await MovimentacaoDB().estornoMovimentacao(database);
  Future<void> createSaldo(Database database, int version) async => await SaldoDB().createTable(database);
  Future<void> createSaldo1(Database database, int version) async => await SaldoDB().createSaldo(database);
  Future<void> createGasto(Database database, int version) async => await ContaDB().createTable(database);
  Future<void> createCarteira(Database database, int version) async => await CarteiraDB().createTable(database);

  // Função para criar o saldo inicial da carteira
  Future<void> createCarteiraEntry(Database database, int version) async {
    final result = await database.query('carteira');
    if (result.isEmpty) {
      await CarteiraDB().create(database, saldo: 0.0);
    }
  }

}