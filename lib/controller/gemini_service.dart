import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  final GenerativeModel _model = GenerativeModel(
    model: 'gemini-1.5-flash-latest', // Atualize para o modelo correto se necessário
    apiKey: 'AIzaSyCh-f-dnEzvhmllTo-Cfb_X713lCvPB16k', // Substitua pela sua chave de API
  );

  final List<String> categories = [
    'Alimentação', 'Animais de Estimação', 'Beleza e Cuidados', 'Compras',
    'Contas', 'Educação', 'Entretenimento', 'Finanças', 'Lazer', 'Moradia',
    'Saúde', 'Serviços Terceiros', 'Transporte', 'Utilidades'
  ];

  Future<String> classifyText(String text) async {
    try {
      final content = [
        Content.text(
            "Classifique a seguinte descrição em uma das seguintes categorias: ${categories.join(', ')}. Descrição: $text"
        )
      ];
      final response = await _model.generateContent(content);

      if (response.candidates.isNotEmpty) {
        String? generatedText = response.candidates.first.text;
        if (generatedText != null && generatedText.isNotEmpty) {
          for (String category in categories) {
            if (generatedText.contains(category)) {
              return category;
            }
          }
        }
      }
      return 'Desconhecido';
    } catch (e) {
      print('Failed to classify text: $e');
      return 'Desconhecido';
    }
  }
}