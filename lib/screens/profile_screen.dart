import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _openRouterKeyController = TextEditingController();
  final TextEditingController _openRouterModelController = TextEditingController();
  final TextEditingController _ollamaModelController = TextEditingController();
  final TextEditingController _plantNetController = TextEditingController();
  String _selectedProvider = 'OpenRouter';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedProvider = prefs.getString('ai_provider') ?? 'OpenRouter';
      _openRouterKeyController.text = prefs.getString('openrouter_key') ?? '';
      _openRouterModelController.text = prefs.getString('openrouter_model') ?? 'nvidia/nemotron-3-super-120b-a12b:free';
      _ollamaModelController.text = prefs.getString('ollama_model') ?? 'gemma4:31b-cloud';
      _plantNetController.text = prefs.getString('plantnet_key') ?? '';
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ai_provider', _selectedProvider);
    await prefs.setString('openrouter_key', _openRouterKeyController.text);
    await prefs.setString('openrouter_model', _openRouterModelController.text);
    await prefs.setString('ollama_model', _ollamaModelController.text);
    await prefs.setString('plantnet_key', _plantNetController.text);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Configurações salvas com sucesso! 🌿')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101415),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Configurações do Especialista', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 32),
            const Text('PROVEDOR DE INTELIGÊNCIA', 
              style: TextStyle(color: Color(0xFF54E98A), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 16),
            _buildProviderSelector(),
            const SizedBox(height: 32),
            const Text('MODELOS E CHAVES', 
              style: TextStyle(color: Color(0xFF54E98A), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 16),
            _buildTextField('OpenRouter Key', _openRouterKeyController, LucideIcons.key, obscure: true),
            const SizedBox(height: 12),
            _buildTextField('OpenRouter Model', _openRouterModelController, LucideIcons.cpu),
            const SizedBox(height: 24),
            _buildTextField('Ollama Model', _ollamaModelController, LucideIcons.cpu),
            const SizedBox(height: 24),
            _buildTextField('Pl@ntNet Key', _plantNetController, LucideIcons.leaf, obscure: true),
            const SizedBox(height: 40),
            _buildSaveButton(),
            const SizedBox(height: 40),
            const Divider(color: Colors.white10),
            _buildSimpleItem(LucideIcons.bell, 'Notificações de Rega'),
            _buildSimpleItem(LucideIcons.shieldCheck, 'Privacidade'),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 35,
          backgroundColor: Color(0xFF54E98A),
          child: Icon(LucideIcons.user, size: 35, color: Color(0xFF003919)),
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Usuário Plant-AI', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text('Plano Free Specialist', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14)),
          ],
        ),
      ],
    );
  }

  Widget _buildProviderSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedProvider,
          dropdownColor: const Color(0xFF1D2022),
          isExpanded: true,
          icon: const Icon(LucideIcons.chevronDown, color: Colors.white38),
          items: ['OpenRouter', 'Ollama (Local)'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: const TextStyle(color: Colors.white)),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedProvider = val!),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {bool obscure = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          icon: Icon(icon, size: 18, color: Colors.white24),
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white38),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: _saveSettings,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFF54E98A),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: const Color(0xFF54E98A).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))
          ],
        ),
        child: const Center(
          child: Text('SALVAR CONFIGURAÇÕES', 
            style: TextStyle(color: Color(0xFF003919), fontWeight: FontWeight.bold, letterSpacing: 1.1)),
        ),
      ),
    );
  }

  Widget _buildSimpleItem(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.white24),
          const SizedBox(width: 16),
          Text(title, style: const TextStyle(fontSize: 15, color: Colors.white70)),
          const Spacer(),
          const Icon(LucideIcons.chevronRight, size: 16, color: Colors.white10),
        ],
      ),
    );
  }
}
