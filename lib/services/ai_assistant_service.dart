import 'package:google_generative_ai/google_generative_ai.dart';

class AIAssistantService {
  // O usuário pode substituir por sua própria chave do Google AI Studio
  static const String _apiKey = "SUA_CHAVE_GEMINI_AQUI"; 
  late final GenerativeModel _model;
  late final ChatSession _chat;

  AIAssistantService() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 1024,
      ),
      systemInstruction: Content.system(
        "Você é o Assistente Botânico do PlantAI. Sua missão é ajudar usuários a cuidar de suas plantas. "
        "Seja amigável, use emojis de plantas e forneça conselhos práticos sobre rega, luz e solo. "
        "Se o usuário identificou uma planta específica, foque nas necessidades dessa espécie."
      ),
    );
    _chat = _model.startChat();
  }

  Future<String> sendMessage(String message) async {
    if (_apiKey == "SUA_CHAVE_GEMINI_AQUI") {
      return "Olá! Sou seu assistente botânico. (Nota: Configure sua chave Gemini no arquivo ai_assistant_service.dart para respostas reais da IA). Como posso ajudar com suas plantas hoje? 🌿";
    }

    try {
      final response = await _chat.sendMessage(Content.text(message));
      return response.text ?? "Desculpe, não consegui processar isso. 🌵";
    } catch (e) {
      return "Houve um erro na comunicação com a IA: $e";
    }
  }
}
