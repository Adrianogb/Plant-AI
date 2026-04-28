import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../services/ai_assistant_service.dart';

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

  @override
  void initState() {
    super.initState();
    if (widget.initialPlantName != null) {
      _messages.add({
        'text': "Olá! Sou o Especialista PlantAI. Analisei sua foto e confirmo que é uma **${widget.initialPlantName}**. Como posso ajudar com os cuidados?",
        'isUser': false,
      });
    } else {
      _messages.add({
        'text': "Olá! Sou o Especialista PlantAI. Como posso ajudar você hoje? 🌿",
        'isUser': false,
      });
    }
  }

  void _handleSend() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'text': text, 'isUser': true});
      _isTyping = true;
      _controller.clear();
    });

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101415),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Especialista PlantAI', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Column(
                  crossAxisAlignment: msg['isUser'] ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    _buildMessageBubble(msg['text'], msg['isUser']),
                    if (msg['component'] != null) _buildGenerativeUI(msg['component']),
                    if (msg['artifact'] != null) _buildArtifactAction(msg['artifact']),
                  ],
                );
              },
            ),
          ),
          if (_isTyping) const Padding(padding: EdgeInsets.all(8.0), child: LinearProgressIndicator(color: Color(0xFF54E98A), backgroundColor: Colors.transparent)),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isUser) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUser ? const Color(0xFF54E98A) : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: TextStyle(color: isUser ? Colors.black : Colors.white, height: 1.4)),
    );
  }

  Widget _buildGenerativeUI(Map<String, dynamic> component) {
    if (component['type'] == 'care_card') {
      final data = component['data'];
      return Container(
        margin: const EdgeInsets.only(bottom: 16, top: 4),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF1D2022), Color(0xFF0B0F10)]),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF54E98A).withOpacity(0.2)),
        ),
        child: Column(
          children: [
            const Row(children: [Icon(LucideIcons.leaf, color: Color(0xFF54E98A), size: 16), SizedBox(width: 8), Text('GUIA DE CUIDADOS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF54E98A)))]),
            const SizedBox(height: 16),
            _buildCareRow(LucideIcons.droplets, 'Rega', data['watering']),
            _buildCareRow(LucideIcons.sun, 'Luz', data['light']),
            _buildCareRow(LucideIcons.thermometer, 'Temp', data['temp']),
            _buildCareRow(LucideIcons.award, 'Nível', data['difficulty']),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildCareRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.white.withOpacity(0.3)),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildArtifactAction(Map<String, dynamic> artifact) {
    return GestureDetector(
      onTap: () => _showArtifactDialog(artifact),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: const Color(0xFF54E98A).withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF54E98A).withOpacity(0.3))),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.fileText, color: Color(0xFF54E98A), size: 20),
            const SizedBox(width: 8),
            Text(artifact['title'], style: const TextStyle(color: Color(0xFF54E98A), fontWeight: FontWeight.bold)),
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
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(artifact['title'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Text(artifact['content'], style: const TextStyle(fontSize: 16, height: 1.6, color: Colors.white70)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Pergunte algo...',
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              ),
              onSubmitted: (_) => _handleSend(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(icon: const Icon(LucideIcons.send, color: Color(0xFF54E98A)), onPressed: _handleSend),
        ],
      ),
    );
  }
}
