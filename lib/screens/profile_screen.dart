import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101415),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Seu Perfil', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFF54E98A),
              child: Icon(LucideIcons.user, size: 50, color: Color(0xFF003919)),
            ),
            const SizedBox(height: 24),
            const Text('Usuário Plant-AI', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const Text('Membro desde Abril 2026', style: TextStyle(color: Colors.white38)),
            const SizedBox(height: 40),
            _buildProfileItem(LucideIcons.settings, 'Configurações'),
            _buildProfileItem(LucideIcons.bell, 'Notificações de Rega'),
            _buildProfileItem(LucideIcons.shieldCheck, 'Privacidade'),
            const SizedBox(height: 40),
            TextButton(
              onPressed: () {},
              child: const Text('Sair da Conta', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF54E98A)),
          const SizedBox(width: 16),
          Text(title, style: const TextStyle(fontSize: 16)),
          const Spacer(),
          const Icon(LucideIcons.chevronRight, size: 16, color: Colors.white24),
        ],
      ),
    );
  }
}
