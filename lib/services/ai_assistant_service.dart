import 'dart:convert';
import 'package:http/http.dart' as http;

class AIAssistantService {
  // Configurações OpenRouter (Opção 1)
  static const String openRouterKey = "SUA_CHAVE_OPENROUTER_AQUI";
  static const String openRouterModel = "google/gemini-2.0-flash-exp:free";

  // Configurações Ollama (Opção 2 - Fallback Automático)
  String _ollamaBaseUrl = "http://localhost:11434"; // Default
  static const String ollamaModel = "llama3";
  bool _isOllamaDiscovered = false;

  final List<Map<String, String>> _history = [];

  AIAssistantService() {
    _history.add({
      'role': 'system',
      'content': "Você é o Assistente Botânico do PlantAI. Sua missão é ajudar usuários a cuidar de suas plantas. "
                 "Seja amigável, use emojis de plantas e forneça conselhos práticos sobre rega, luz e solo."
    });
  }

  Future<String> sendMessage(String message) async {
    _history.add({'role': 'user', 'content': message});

    // Tentar Opção 1: OpenRouter
    if (openRouterKey != "SUA_CHAVE_OPENROUTER_AQUI" && openRouterKey.isNotEmpty) {
      try {
        final response = await _callOpenRouter();
        if (response != null) return response;
      } catch (e) {
        print("Erro OpenRouter: $e. Tentando fallback para Ollama...");
      }
    }

    // Tentar Opção 2: Ollama (com descoberta automática)
    if (!_isOllamaDiscovered) {
      await _discoverOllama();
    }

    try {
      final response = await _callOllama();
      if (response != null) return response;
    } catch (e) {
      print("Erro Ollama: $e");
    }

    return "Olá! Sou seu assistente botânico. Configure sua chave OpenRouter ou certifique-se que o Ollama está rodando no seu PC para respostas reais. 🌿";
  }

  Future<void> _discoverOllama() async {
    print("Iniciando descoberta automática do Ollama...");
    
    // Lista de endereços para tentar
    final candidates = [
      'http://localhost:11434',
      'http://10.0.2.2:11434', // Emulador Android
      // Ranges comuns em redes brasileiras
      for (var i = 1; i <= 20; i++) 'http://192.168.1.$i:11434',
      for (var i = 1; i <= 20; i++) 'http://192.168.15.$i:11434',
      for (var i = 1; i <= 20; i++) 'http://192.168.0.$i:11434',
    ];

    // Tenta em lotes de 5 para não sobrecarregar
    const batchSize = 5;
    for (var i = 0; i < candidates.length; i += batchSize) {
      final batch = candidates.skip(i).take(batchSize);
      final results = await Future.wait(batch.map((url) => _checkOllama(url)));
      
      for (var j = 0; j < results.length; j++) {
        if (results[j] != null) {
          _ollamaBaseUrl = results[j]!;
          _isOllamaDiscovered = true;
          print("Ollama descoberto em: $_ollamaBaseUrl");
          return;
        }
      }
    }
  }

  Future<String?> _checkOllama(String url) async {
    try {
      final response = await http.get(Uri.parse("$url/api/tags")).timeout(const Duration(milliseconds: 500));
      if (response.statusCode == 200) return url;
    } catch (_) {}
    return null;
  }

  Future<String?> _callOpenRouter() async {
    final uri = Uri.parse("https://openrouter.ai/api/v1/chat/completions");
    final response = await http.post(
      uri,
      headers: {
        "Authorization": "Bearer $openRouterKey",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "model": openRouterModel,
        "messages": _history,
      }),
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
      body: jsonEncode({
        "model": ollamaModel,
        "messages": _history,
        "stream": false,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final reply = data['message']['content'];
      _history.add({'role': 'assistant', 'content': reply});
      return reply;
    }
    return null;
  }
}
