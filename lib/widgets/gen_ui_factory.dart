import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// GenUI Factory: Transforma JSON da IA em Widgets Interativos do Flutter.
/// Inspirado no padrão experimental GenUI SDK da Google.
class GenUIFactory {
  static Widget build(Map<String, dynamic> component, BuildContext context, Function(String) onAction) {
    final type = component['type'];
    final data = component['data'] ?? {};

    switch (type) {
      case 'care_card':
        return _buildCareCard(data);
      case 'action_buttons':
        return _buildActionButtons(data, onAction);
      case 'fact_sheet':
        return _buildFactSheet(data);
      default:
        return const SizedBox.shrink();
    }
  }

  static Widget _buildCareCard(Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1D2022), Color(0xFF0B0F10)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF54E98A).withOpacity(0.2)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(LucideIcons.leaf, color: Color(0xFF54E98A), size: 16),
              SizedBox(width: 8),
              Text('GUIA DINÂMICO DE CUIDADOS', 
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF54E98A), letterSpacing: 1.2)),
            ],
          ),
          const SizedBox(height: 20),
          _buildItem(LucideIcons.droplets, 'Rega', data['watering'] ?? 'N/A'),
          _buildItem(LucideIcons.sun, 'Luz', data['light'] ?? 'N/A'),
          _buildItem(LucideIcons.thermometer, 'Temp', data['temp'] ?? 'N/A'),
          _buildItem(LucideIcons.award, 'Dificuldade', data['difficulty'] ?? 'Fácil'),
        ],
      ),
    );
  }

  static Widget _buildActionButtons(Map<String, dynamic> data, Function(String) onAction) {
    final List actions = data['actions'] ?? [];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: actions.map<Widget>((action) {
          return ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF54E98A).withOpacity(0.1),
              foregroundColor: const Color(0xFF54E98A),
              elevation: 0,
              side: BorderSide(color: const Color(0xFF54E98A).withOpacity(0.3)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => onAction(action['label']),
            child: Text(action['label']),
          );
        }).toList(),
      ),
    );
  }

  static Widget _buildFactSheet(Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(data['title'] ?? 'Ficha Técnica', 
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
          const Divider(color: Colors.white10),
          Text(data['description'] ?? '', 
            style: const TextStyle(fontSize: 13, color: Colors.white54, height: 1.5)),
        ],
      ),
    );
  }

  static Widget _buildItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.white24),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 13)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.white)),
        ],
      ),
    );
  }
}
