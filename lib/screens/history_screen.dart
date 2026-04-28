import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101415),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Histórico de Plantas', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.history, size: 80, color: Colors.white.withOpacity(0.1)),
            const SizedBox(height: 24),
            const Text('Seu histórico está vazio', style: TextStyle(color: Colors.white38, fontSize: 18)),
            const SizedBox(height: 8),
            const Text('Identifique uma planta para vê-la aqui.', style: TextStyle(color: Colors.white24, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
