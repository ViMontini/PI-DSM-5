import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:despesa_digital/database/database_service.dart';
import 'package:sqflite/sqflite.dart';


class SyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> checkConnectivityAndSync(Database db) async {
    var connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult != ConnectivityResult.none) {
      await syncToFirestore(db);
    } else {
      print("Sem conexão com a internet. Sincronização pendente.");
    }
  }

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Funções de sincronização para cada tabela

  // 1. Sincronizar a tabela "usuario" para o Firestore
  Future<void> syncUsuarioToFirestore(Database db) async {
    List<Map<String, dynamic>> unsyncedUsuarios = await db.query('usuario', where: 'status_sync = ?', whereArgs: [0]);
    for (var usuario in unsyncedUsuarios) {
      await firestore.collection('usuarios').add(usuario);
      await db.update('usuario', {'status_sync': 1}, where: 'id = ?', whereArgs: [usuario['id']]);
    }
  }

  // 2. Sincronizar a tabela "saldo" para o Firestore
  Future<void> syncSaldoToFirestore(Database db) async {
    List<Map<String, dynamic>> unsyncedSaldos = await db.query('saldo', where: 'status_sync = ?', whereArgs: [0]);
    for (var saldo in unsyncedSaldos) {
      await firestore.collection('saldos').add(saldo);
      await db.update('saldo', {'status_sync': 1}, where: 'id = ?', whereArgs: [saldo['id']]);
    }
  }

  // 3. Sincronizar a tabela "movimentacao" para o Firestore
  Future<void> syncMovimentacaoToFirestore(Database db) async {
    List<Map<String, dynamic>> unsyncedMovimentacoes = await db.query('movimentacao', where: 'status_sync = ?', whereArgs: [0]);
    for (var movimentacao in unsyncedMovimentacoes) {
      await firestore.collection('movimentacoes').add(movimentacao);
      await db.update('movimentacao', {'status_sync': 1}, where: 'id = ?', whereArgs: [movimentacao['id']]);
    }
  }

  // 4. Sincronizar a tabela "meta" para o Firestore
  Future<void> syncMetaToFirestore(Database db) async {
    List<Map<String, dynamic>> unsyncedMetas = await db.query('meta', where: 'status_sync = ?', whereArgs: [0]);
    for (var meta in unsyncedMetas) {
      await firestore.collection('metas').add(meta);
      await db.update('meta', {'status_sync': 1}, where: 'id = ?', whereArgs: [meta['id']]);
    }
  }

  // 5. Sincronizar a tabela "divida" para o Firestore
  Future<void> syncDividaToFirestore(Database db) async {
    List<Map<String, dynamic>> unsyncedDividas = await db.query('divida', where: 'status_sync = ?', whereArgs: [0]);
    for (var divida in unsyncedDividas) {
      await firestore.collection('dividas').add(divida);
      await db.update('divida', {'status_sync': 1}, where: 'id = ?', whereArgs: [divida['id']]);
    }
  }

  // 6. Sincronizar a tabela "conta" para o Firestore
  Future<void> syncContaToFirestore(Database db) async {
    List<Map<String, dynamic>> unsyncedContas = await db.query('conta', where: 'status_sync = ?', whereArgs: [0]);
    for (var conta in unsyncedContas) {
      await firestore.collection('contas').add(conta);
      await db.update('conta', {'status_sync': 1}, where: 'id = ?', whereArgs: [conta['id']]);
    }
  }

  // 7. Sincronizar a tabela "carteira" para o Firestore
  Future<void> syncCarteiraToFirestore(Database db) async {
    List<Map<String, dynamic>> unsyncedCarteiras = await db.query('carteira', where: 'status_sync = ?', whereArgs: [0]);
    for (var carteira in unsyncedCarteiras) {
      await firestore.collection('carteiras').add(carteira);
      await db.update('carteira', {'status_sync': 1}, where: 'id = ?', whereArgs: [carteira['id']]);
    }
  }

  // Funções para sincronizar todas as tabelas para o Firestore
  Future<void> syncToFirestore(Database db) async {
    await syncUsuarioToFirestore(db);
    await syncSaldoToFirestore(db);
    await syncMovimentacaoToFirestore(db);
    await syncMetaToFirestore(db);
    await syncDividaToFirestore(db);
    await syncContaToFirestore(db);
    await syncCarteiraToFirestore(db);
  }

  // Funções para buscar dados do Firestore para o SQLite
  Future<void> fetchUsuariosFromFirestore(Database db) async {
    final querySnapshot = await firestore.collection('usuarios').get();
    for (var doc in querySnapshot.docs) {
      await db.insert('usuario', doc.data(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<void> fetchSaldosFromFirestore(Database db) async {
    final querySnapshot = await firestore.collection('saldos').get();
    for (var doc in querySnapshot.docs) {
      await db.insert('saldo', doc.data(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<void> fetchMovimentacoesFromFirestore(Database db) async {
    final querySnapshot = await firestore.collection('movimentacoes').get();
    for (var doc in querySnapshot.docs) {
      await db.insert('movimentacao', doc.data(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<void> fetchMetasFromFirestore(Database db) async {
    final querySnapshot = await firestore.collection('metas').get();
    for (var doc in querySnapshot.docs) {
      await db.insert('meta', doc.data(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<void> fetchDividasFromFirestore(Database db) async {
    final querySnapshot = await firestore.collection('dividas').get();
    for (var doc in querySnapshot.docs) {
      await db.insert('divida', doc.data(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<void> fetchContasFromFirestore(Database db) async {
    final querySnapshot = await firestore.collection('contas').get();
    for (var doc in querySnapshot.docs) {
      await db.insert('conta', doc.data(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<void> fetchCarteirasFromFirestore(Database db) async {
    final querySnapshot = await firestore.collection('carteiras').get();
    for (var doc in querySnapshot.docs) {
      await db.insert('carteira', doc.data(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<void> syncFromFirestore(Database db) async {
    await fetchUsuariosFromFirestore(db);
    await fetchSaldosFromFirestore(db);
    await fetchMovimentacoesFromFirestore(db);
    await fetchMetasFromFirestore(db);
    await fetchDividasFromFirestore(db);
    await fetchContasFromFirestore(db);
    await fetchCarteirasFromFirestore(db);
  }
}

