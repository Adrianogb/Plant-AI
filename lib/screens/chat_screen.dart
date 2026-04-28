import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../services/ai_assistant_service.dart';
import '../widgets/gen_ui_factory.dart';

class ChatScreen extends StatefulWidget {
  final String? initialPlantName;
  const ChatScreen({super.key, this.initialPlantName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final AIAssistantService _aiService = AIAssistantService();
  bool _isTyping = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.initialPlantName != null) {
      _messages.add({
        'text': "Olá! Analisei sua foto e identifiquei uma **${widget.initialPlantName}**. Escolha uma ação abaixo para começarmos os cuidados!",
        'isUser': false,
        'component': {
          'type': 'action_buttons',
          'data': {
            'actions': [
              {'label': 'Como regar?'},
              {'label': 'Luz ideal'},
              {'label': 'Ficha completa'},
            ]
          }
        }
      });
    } else {
      _messages.add({
        'text': "Olá! Sou o Especialista PlantAI. Como posso ajudar com suas plantas hoje? 🌿",
        'isUser': false,
      });
    }
  }

  void _handleSend([String? customText]) async {
    final text = customText ?? _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'text': text, 'isUser': true});
      _isTyping = true;
      if (customText == null) _controller.clear();
    });

    _scrollToBottom();

    final result = await _aiService.sendMessage(text);

    setState(() {
      _messages.add({
        'text': result['text'],
        'isUser': false,
        'component': result['component'],
        'artifact': result['artifact'],
      });
      _isTyping = false;
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101415),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Especialista PlantAI', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(LucideIcons.chevronLeft), onPressed: () => Navigator.pop(context)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: msg['isUser'] ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      _buildMessageBubble(msg['text'], msg['isUser']),
                      if (msg['component'] != null) 
                        GenUIFactory.build(msg['component'], context, (actionLabel) {
                          _handleSend(actionLabel); // Loop Dinâmico: Ação do Widget gera nova resposta da IA
                        }),
                      if (msg['artifact'] != null) _buildArtifactAction(msg['artifact']),
                    ],
                  ),
                );
              },
            ),
          ),
          if (_isTyping) _buildTypingIndicator(),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isUser) {
    return Container(
      padding: const EdgeInsets.all(16),
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
      decoration: BoxDecoration(
        color: isUser ? const Color(0xFF54E98A) : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
          bottomLeft: Radius.circular(isUser ? 20 : 0),
          bottomRight: Radius.circular(isUser ? 0 : 20),
        ),
      ),
      child: Text(text, style: TextStyle(color: isUser ? const Color(0xFF003919) : Colors.white, height: 1.4, fontSize: 15)),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: const SizedBox(
        width: 40,
        child: LinearProgressIndicator(color: Color(0xFF54E98A), backgroundColor: Colors.transparent),
      ),
    );
  }

  Widget _buildArtifactAction(Map<String, dynamic> artifact) {
    return GestureDetector(
      onTap: () => _showArtifactDialog(artifact),
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF54E98A).withOpacity(0.1), 
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF54E98A).withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.fileText, color: Color(0xFF54E98A), size: 18),
            const SizedBox(width: 8),
            Text(artifact['title'], style: const TextStyle(color: Color(0xFF54E98A), fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  void _showArtifactDialog(Map<String, dynamic> artifact) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF101415),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        padding: const EdgeInsets.all(32),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 32),
              Text(artifact['title'], style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              Text(artifact['content'], style: const TextStyle(fontSize: 16, height: 1.7, color: Colors.white70)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 10, 10),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Pergunte sobre sua planta...',
                  hintStyle: TextStyle(color: Colors.white24),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _handleSend(),
              ),
            ),
            Container(
              decoration: const BoxDecoration(color: Color(0xFF54E98A), shape: BoxShape.circle),
              child: IconButton(
                icon: const Icon(LucideIcons.send, color: Color(0xFF003919), size: 20),
                onPressed: _handleSend,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
