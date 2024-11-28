import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiServiceChat {
  final GenerativeModel _model = GenerativeModel(
    model: 'gemini-1.5-flash-latest', // Atualize para o modelo correto se necessário
    apiKey: 'AIzaSyCh-f-dnEzvhmllTo-Cfb_X713lCvPB16k', // Substitua pela sua chave de API
  );

  final List<Map<String, String>> conversationHistory = [];

  Future<String> handleFinanceQuestion(String text) async {
    try {
      bool isFirstQuestion = conversationHistory.isEmpty;
      conversationHistory.add({"sender": "Usuário", "message": text});

      String context = _buildContextWithHistory();

      String prompt = isFirstQuestion
          ? "Responda a pergunta de forma simples e direta sobre finanças: $text"
          : "Dado o contexto da conversa anterior: $context | Responda a nova pergunta: $text";

      final content = [
        Content.text(prompt)
      ];

      final response = await _model.generateContent(content);

      if (response.candidates.isNotEmpty) {
        String? generatedText = response.candidates.first.text;

        if (generatedText != null && generatedText.isNotEmpty) {
          generatedText = _sanitizeResponse(generatedText);  // Sanitiza o texto removendo símbolos indesejados
          conversationHistory.add({"sender": "IA", "message": generatedText});
          return generatedText;
        }
      }
      return 'Não foi possível gerar uma resposta para sua pergunta.';
    } catch (e) {
      print('Erro ao processar a pergunta: $e');
      return 'Erro ao tentar processar sua pergunta.';
    }
  }

  String _buildContextWithHistory() {
    final recentHistory = conversationHistory.takeLast(5);
    String history = recentHistory
        .map((entry) => "${entry['sender']}: ${entry['message']}")
        .join(" | ");
    return history;
  }

  // Função para remover símbolos "**" e "##" do início de cada linha
  String _sanitizeResponse(String response) {
    return response
        .split('\n')
        .map((line) => line.replaceAll(RegExp(r'^[*#]+\s*'), '').trim())
        .join('\n'); // Remove símbolos "*" ou "##" e espaços extras no início de cada linha
  }
}

extension TakeLastExtension<E> on List<E> {
  List<E> takeLast(int n) => sublist(length - n < 0 ? 0 : length - n, length);
}