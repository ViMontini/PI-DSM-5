import 'gemini_service.dart';

class Categorizer {
  static Future<String> categorize(String descricao) async {
    try {
      final result = await GeminiService().classifyText(descricao);
      return result;
    } catch (e) {
      print('Erro ao categorizar a movimentação: $e');
      return 'Desconhecido';
    }
  }
}