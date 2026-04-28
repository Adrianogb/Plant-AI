import 'dart:convert';
import 'package:http/http.dart' as http;

class AIAssistantService {
  static const String openRouterKey = "SUA_CHAVE_OPENROUTER_AQUI";
  static const String openRouterModel = "google/gemini-2.0-flash-exp:free";

  String _ollamaBaseUrl = "http://localhost:11434";
  static const String ollamaModel = "llama3";
  bool _isOllamaDiscovered = false;

  final List<Map<String, String>> _history = [];

  AIAssistantService() {
    _history.add({
      'role': 'system',
      'content': """Você é o Especialista Botânico do PlantAI. 
Sua missão é ajudar usuários a identificar e cuidar de plantas com precisão científica e amabilidade.

DIRETRIZES:
1. PENSAMENTO ESTRUTURADO (Chain of Thought): Sempre comece sua resposta internamente analisando os detalhes botânicos.
2. GENERATIVE UI: Se você fornecer um guia de cuidados, retorne também um objeto JSON no final da mensagem seguindo este formato:
   [UI_COMPONENT: {"type": "care_card", "data": {"watering": "Moderada", "light": "Sombra parcial", "temp": "20-30°C", "difficulty": "Fácil"}}]
3. ARTIFACTS: Se criar uma ficha técnica completa, use:
   [ARTIFACT: {"title": "Ficha Técnica: Monstera", "content": "..."}]

Use emojis 🌿 e seja encorajador!"""
    });
  }

  Future<Map<String, dynamic>> sendMessage(String message) async {
    _history.add({'role': 'user', 'content': message});

    String? responseText;

    // Tentar Opção 1: OpenRouter
    if (openRouterKey != "SUA_CHAVE_OPENROUTER_AQUI" && openRouterKey.isNotEmpty) {
      try {
        responseText = await _callOpenRouter();
      } catch (e) {
        print("Erro OpenRouter: $e. Tentando fallback para Ollama...");
      }
    }

    // Tentar Opção 2: Ollama
    if (responseText == null) {
      if (!_isOllamaDiscovered) await _discoverOllama();
      try {
        responseText = await _callOllama();
      } catch (e) {
        print("Erro Ollama: $e");
      }
    }

    if (responseText == null) {
      return {
        'text': "Olá! Configure sua inteligência para começarmos. 🌿",
        'component': null,
        'artifact': null
      };
    }

    return _parseResponse(responseText);
  }

  Map<String, dynamic> _parseResponse(String text) {
    Map<String, dynamic>? component;
    Map<String, dynamic>? artifact;

    // Extrair Componente UI
    final compMatch = RegExp(r'\[UI_COMPONENT: (.*?)\]').firstMatch(text);
    if (compMatch != null) {
      try {
        component = jsonDecode(compMatch.group(1)!);
        text = text.replaceFirst(compMatch.group(0)!, '').trim();
      } catch (_) {}
    }

    // Extrair Artefato
    final artMatch = RegExp(r'\[ARTIFACT: (.*?)\]').firstMatch(text);
    if (artMatch != null) {
      try {
        artifact = jsonDecode(artMatch.group(1)!);
        text = text.replaceFirst(artMatch.group(0)!, '').trim();
      } catch (_) {}
    }

    return {
      'text': text,
      'component': component,
      'artifact': artifact,
    };
  }

  // Métodos de chamada (OpenRouter e Ollama) permanecem similares, retornando String
  Future<String?> _callOpenRouter() async {
    final uri = Uri.parse("https://openrouter.ai/api/v1/chat/completions");
    final response = await http.post(
      uri,
      headers: {"Authorization": "Bearer $openRouterKey", "Content-Type": "application/json"},
      body: jsonEncode({"model": openRouterModel, "messages": _history}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final reply = data['choices'][0]['message']['content'];
      _history.add({'role': 'assistant', 'content': reply});
      return reply;
    }
    return null;
  }

  Future<String?> _callOllama() async {
    final uri = Uri.parse("$_ollamaBaseUrl/api/chat");
    final response = await http.post(
      uri,
      body: jsonEncode({"model": ollamaModel, "messages": _history, "stream": false}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final reply = data['message']['content'];
      _history.add({'role': 'assistant', 'content': reply});
      return reply;
    }
    return null;
  }

  Future<void> _discoverOllama() async {
    final candidates = ['http://localhost:11434', 'http://10.0.2.2:11434', for (var i = 1; i <= 10; i++) 'http://192.168.1.$i:11434'];
    for (var url in candidates) {
      try {
        final res = await http.get(Uri.parse("$url/api/tags")).timeout(const Duration(milliseconds: 300));
        if (res.statusCode == 200) { _ollamaBaseUrl = url; _isOllamaDiscovered = true; return; }
      } catch (_) {}
    }
  }
}
