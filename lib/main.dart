import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:ui';
import 'dart:io';
import 'services/plant_net_service.dart';
import 'screens/chat_screen.dart';

void main() {
  runApp(const PlantAIApp());
}

class PlantAIApp extends StatelessWidget {
  const PlantAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PlantAI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF101415),
        primaryColor: const Color(0xFF54E98A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF54E98A),
          secondary: Color(0xFF4EDDBB),
          surface: Color(0xFF1D2022),
          onPrimary: Color(0xFF003919),
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final ImagePicker _picker = ImagePicker();
  List<File> _selectedImages = [];
  bool _isLoading = false;

  Future<void> _pickImage() async {
    if (_selectedImages.length >= 5) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1D2022),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(LucideIcons.camera, color: Color(0xFF54E98A)),
              title: const Text('Tirar Foto', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
                if (image != null) setState(() => _selectedImages.add(File(image.path)));
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.image, color: Color(0xFF54E98A)),
              title: const Text('Escolher da Galeria', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                if (image != null) setState(() => _selectedImages.add(File(image.path)));
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _identifyPlant() async {
    if (_selectedImages.isEmpty) return;

    setState(() => _isLoading = true);

    final results = await PlantNetService.identify(_selectedImages);

    setState(() => _isLoading = false);

    if (results != null && results['results'] != null && results['results'].isNotEmpty) {
      final bestMatch = results['results'][0];
      final speciesName = bestMatch['species']['scientificNameWithoutAuthor'];
      final commonName = (bestMatch['species']['commonNames'] as List).isNotEmpty 
          ? bestMatch['species']['commonNames'][0] 
          : speciesName;

      _showResultDialog(commonName, speciesName, bestMatch['score']);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível identificar a planta. Tente outra foto.')),
      );
    }
  }

  void _showResultDialog(String commonName, String scientificName, double score) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Color(0xFF1D2022),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 32),
            const Icon(LucideIcons.checkCircle2, color: Color(0xFF54E98A), size: 64),
            const SizedBox(height: 24),
            Text('Planta Identificada!', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(commonName, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            Text(scientificName, style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.white.withOpacity(0.4))),
            const SizedBox(height: 16),
            Text('Confiança: ${(score * 100).toStringAsFixed(1)}%', style: const TextStyle(color: Color(0xFF54E98A), fontWeight: FontWeight.bold)),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF54E98A),
                foregroundColor: const Color(0xFF003919),
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChatScreen(initialPlantName: commonName)),
                );
              },
              child: const Text('CONVERSAR COM ASSISTENTE', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // Background Gradient Aesthetic
          // Optimized Background (simpler gradients for better FPS)
          Positioned.fill(
            child: Container(
              color: const Color(0xFF101415),
            ),
          ),
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF005141).withOpacity(0.3),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF003919).withOpacity(0.2),
              ),
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildHeader(),
                  const SizedBox(height: 48),
                  _buildHero(),
                  const SizedBox(height: 32),
                  _buildUploadCard(),
                  const SizedBox(height: 24),
                  _buildStatsGrid(),
                  const SizedBox(height: 160), // Aumentado de 120 para 160 para garantir visibilidade acima da barra flutuante
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator(color: Color(0xFF54E98A))),
            ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(LucideIcons.leaf, color: Color(0xFF54E98A), size: 28),
            const SizedBox(width: 8),
            Text('PlantAI', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF54E98A), letterSpacing: 1.2)),
          ],
        ),
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF54E98A).withOpacity(0.3)),
            image: const DecorationImage(image: NetworkImage('https://i.pravatar.cc/150?u=plantai'), fit: BoxFit.cover),
          ),
        ),
      ],
    );
  }

  Widget _buildHero() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('EXPLORADOR BOTÂNICO', style: TextStyle(color: Color(0xFF54E98A), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, height: 1.2),
            children: const [
              TextSpan(text: 'Identifique sua '),
              TextSpan(text: 'Próxima Planta', style: TextStyle(color: Color(0xFF2ECC71))),
              TextSpan(text: ' com Precisão.'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUploadCard() {
    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 260, // Reduzido ligeiramente para caber melhor na tela
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF191C1E).withOpacity(0.5),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_selectedImages.isEmpty)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: const Color(0xFF54E98A).withOpacity(0.1), shape: BoxShape.circle),
                          child: const Icon(LucideIcons.camera, color: Color(0xFF54E98A), size: 40),
                        ),
                        const SizedBox(height: 16),
                        const Text('Adicionar fotos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text('Carregue até 5 imagens', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14)),
                      ],
                    )
                  else
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.file(_selectedImages.last, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                    ),
                  Positioned.fill(child: Padding(padding: const EdgeInsets.all(32), child: CustomPaint(painter: ReticlePainter(color: const Color(0xFF54E98A))))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24), // Aumentado o respiro
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (index) => _buildPhotoSlot(index)),
          ),
          const SizedBox(height: 24), // Aumentado o respiro antes do botão
          GestureDetector(
            onTap: _selectedImages.isNotEmpty ? _identifyPlant : null,
            child: Container(
              width: double.infinity, height: 60, // Aumentado ligeiramente a altura do botão
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _selectedImages.isNotEmpty 
                      ? [const Color(0xFF2ECC71), const Color(0xFF00B596)]
                      : [Colors.white10, Colors.white10],
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: _selectedImages.isNotEmpty ? [
                  BoxShadow(color: const Color(0xFF2ECC71).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))
                ] : [],
              ),
              child: Center(
                child: Text(
                  'IDENTIFICAR PLANTA',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.5, color: _selectedImages.isNotEmpty ? const Color(0xFF00210C) : Colors.white24),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildPhotoSlot(int index) {
    bool hasImage = index < _selectedImages.length;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 50, height: 50,
          decoration: BoxDecoration(
            color: hasImage ? const Color(0xFF54E98A).withOpacity(0.1) : Colors.white.withOpacity(0.02),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: hasImage ? const Color(0xFF54E98A) : Colors.white.withOpacity(0.08), width: 1.5),
            boxShadow: hasImage ? [BoxShadow(color: const Color(0xFF54E98A).withOpacity(0.2), blurRadius: 8)] : [],
          ),
          child: hasImage 
              ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(_selectedImages[index], fit: BoxFit.cover))
              : Icon(LucideIcons.image, color: Colors.white.withOpacity(0.1), size: 20),
        ),
        if (hasImage)
          Positioned(
            top: -8,
            right: -8,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedImages.removeAt(index);
                });
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                child: const Icon(LucideIcons.x, color: Colors.white, size: 12),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        Expanded(child: _buildStatCard(icon: LucideIcons.zap, title: 'IA Potência', subtitle: '98.4% Precisão', color: const Color(0xFF54E98A))),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard(icon: LucideIcons.sparkles, title: 'Dica do Dia', subtitle: 'Regue sua Jiboia!', color: const Color(0xFF4EDDBB))),
      ],
    );
  }

  Widget _buildStatCard({required IconData icon, required String title, required String subtitle, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withOpacity(0.1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, color: color, size: 16), const SizedBox(width: 8), Text(title, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12, fontWeight: FontWeight.bold))]),
          const SizedBox(height: 8),
          Text(subtitle, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xFF00210C).withOpacity(0.6),
        borderRadius: BorderRadius.circular(36),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(36),
        child: Container(
          color: const Color(0xFF00210C).withOpacity(0.9), // Opacidade fixa é muito mais leve que blur
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(LucideIcons.camera, 'Identify', 0),
              _buildNavItem(LucideIcons.history, 'History', 1),
              _buildNavItem(LucideIcons.user, 'Profile', 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _currentIndex = index);
        if (index == 1) { // Just for testing, go to chat
           Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatScreen()));
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(color: isActive ? const Color(0xFF54E98A).withOpacity(0.2) : Colors.transparent, borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isActive ? const Color(0xFF54E98A) : Colors.white.withOpacity(0.4), size: 24),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isActive ? const Color(0xFF54E98A) : Colors.white.withOpacity(0.4))),
          ],
        ),
      ),
    );
  }
}

class ReticlePainter extends CustomPainter {
  final Color color;
  ReticlePainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = 2..style = PaintingStyle.stroke;
    const length = 20.0;
    canvas.drawLine(Offset.zero, Offset(0, length), paint);
    canvas.drawLine(Offset.zero, Offset(length, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width - length, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, length), paint);
    canvas.drawLine(Offset(0, size.height), Offset(0, size.height - length), paint);
    canvas.drawLine(Offset(0, size.height), Offset(length, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width - length, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width, size.height - length), paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
