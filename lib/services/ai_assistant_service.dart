import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AIAssistantService {
  // Configurações OpenRouter (Opção 1)
  final String openRouterKey = dotenv.env['OPENROUTER_API_KEY'] ?? "";
  static const String openRouterModel = "google/gemini-2.0-flash-exp:free";

  // Configurações Ollama (Opção 2 - Fallback Automático)
  String _ollamaBaseUrl = "http://localhost:11434";
  static const String ollamaModel = "llama3";
  bool _isOllamaDiscovered = false;

  final List<Map<String, String>> _history = [];

  AIAssistantService() {
    _history.add({
      'role': 'system',
      'content': """Você é um assistente especializado em botânica e fitopatologia. Sua função é identificar plantas ornamentais, agrícolas e silvestres, bem como diagnosticar sintomas de doenças e pragas a partir de descrições ou imagens fornecidas. 

Diretrizes de Especialista:
- Sempre responda com **nome científico** e **nome popular** da planta ou doença.
- Forneça uma descrição detalhada das características morfológicas (folhas, flores, caule, raízes) ou sintomas observados (manchas, necroses, deformações).
- Explique **condições favoráveis** ao desenvolvimento da planta ou da doença.
- Inclua informações sobre **importância econômica, riscos e impacto** quando relevante.
- Apresente **estratégias de manejo e cuidados** recomendados, baseados em boas práticas agrícolas ou de jardinagem.
- Mantenha o tom **profissional, claro e objetivo**, evitando termos vagos ou imprecisos.
- Quando houver possibilidade de confusão entre doenças ou espécies, liste as alternativas e explique como diferenciá-las.
- Não forneça diagnósticos médicos para humanos ou animais; limite-se ao contexto vegetal.
- Se a informação não puder ser confirmada apenas pela descrição ou imagem, ressalte a necessidade de análise laboratorial ou consulta com um agrônomo/botânico.

REGRAS ESTRUTURAIS DO APP:
1. PENSAMENTO ESTRUTURADO (Chain of Thought): Antes da resposta final, realize uma análise botânica interna.
2. GENERATIVE UI (GenUI): Utilize JSONs para compor a interface. Componentes disponíveis:
   - [UI_COMPONENT: {"type": "care_card", "data": {"watering": "...", "light": "...", "temp": "...", "difficulty": "..."}}]
   - [UI_COMPONENT: {"type": "action_buttons", "data": {"actions": [{"label": "Sugerir Solo"}, {"label": "É tóxica?"}]}}]
   - [UI_COMPONENT: {"type": "fact_sheet", "data": {"title": "...", "description": "..."}}]
3. ARTIFACTS: Ao criar fichas técnicas detalhadas, use:
   [ARTIFACT: {"title": "Título da Ficha", "content": "Conteúdo detalhado..."}]

Objetivo: Garantir que o usuário receba uma resposta precisa, completa e confiável."""
    });
  }

  Future<Map<String, dynamic>> sendMessage(String message) async {
    _history.add({'role': 'user', 'content': message});

    String? responseText;

    if (openRouterKey != "SUA_CHAVE_OPENROUTER_AQUI" && openRouterKey.isNotEmpty) {
      try {
        responseText = await _callOpenRouter();
      } catch (e) {
        print("Erro OpenRouter: $e. Tentando fallback para Ollama...");
      }
    }

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
        'text': "Olá! Por favor, configure sua chave do OpenRouter ou certifique-se de que o Ollama está ativo para que eu possa realizar a análise botânica. 🌿",
        'component': null,
        'artifact': null
      };
    }

    return _parseResponse(responseText);
  }

  Map<String, dynamic> _parseResponse(String text) {
    Map<String, dynamic>? component;
    Map<String, dynamic>? artifact;

    final compMatch = RegExp(r'\[UI_COMPONENT: (.*?)\]').firstMatch(text);
    if (compMatch != null) {
      try {
        component = jsonDecode(compMatch.group(1)!);
        text = text.replaceFirst(compMatch.group(0)!, '').trim();
      } catch (_) {}
    }

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
    final candidates = ['http://localhost:11434', 'http://10.0.2.2:11434', for (var i = 1; i <= 20; i++) 'http://192.168.1.$i:11434', for (var i = 1; i <= 20; i++) 'http://192.168.15.$i:11434'];
    for (var url in candidates) {
      try {
        final res = await http.get(Uri.parse("$url/api/tags")).timeout(const Duration(milliseconds: 300));
        if (res.statusCode == 200) { _ollamaBaseUrl = url; _isOllamaDiscovered = true; return; }
      } catch (_) {}
    }
  }
}
