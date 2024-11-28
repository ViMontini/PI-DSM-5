import 'package:connectivity_plus/connectivity_plus.dart';

import '../database/database_service.dart';
import '../database/movi_db.dart';
import 'gemini_service.dart';

var connectivityResult = Connectivity().checkConnectivity();
DatabaseService databaseService = DatabaseService();

class Categorizer {
  static Future<String> categorize(String descricao) async {
    try {
      final result = await GeminiService().classifyText(descricao);
      print('Categoria: $result');
      return result;
    } catch (e) {
      print('Erro ao categorizar a movimentação: $e');
      return 'Desconhecido';
    }
  }

  static Future<void> recategorizarDesconhecidos() async {
    // Verifica a conexão com a internet
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      print('Sem conexão com a internet. Recategorização será feita depois.');
      return;
    }

    try {
      // Busca movimentações com a categoria "Desconhecido"
      final movimentacoes = await MovimentacaoDB().fetchByCategory('Desconhecido');
      if (movimentacoes.isEmpty) {
        print('Nenhuma movimentação desconhecida encontrada.');
        return;
      }

      // Percorre as movimentações e tenta recategorizar
      for (var movi in movimentacoes) {
        final novaCategoria = await Categorizer.categorize(movi.descricao ?? '');
        if (novaCategoria != 'Desconhecido') {
          await MovimentacaoDB().updateCategory(movi.id, novaCategoria);
          print('Movimentação ${movi.id} recategorizada para $novaCategoria');
        }
      }
      print('Recategorização concluída.');
    } catch (e) {
      print('Erro durante a recategorização: $e');
    }
  }
}