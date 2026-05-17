// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _username = '';

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final name = await AuthService.getLoggedUsername();
    setState(() => _username = name);
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C2233),
        title: Text(
          'Hai, $_username!',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.grey),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text(
              'Pilih Kategori',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildMenuCard(
                    context,
                    type: 'news',
                    title: 'News',
                    description:
                        'Dapatkan berita terkini seputar penerbangan luar angkasa dari berbagai sumber. Hubungkan penggunamu ke website yang tepat.',
                    icon: Icons.newspaper_rounded,
                    color: const Color(0xFF4FC3F7),
                  ),
                  const SizedBox(height: 16),
                  _buildMenuCard(
                    context,
                    type: 'blog',
                    title: 'Blog',
                    description:
                        'Blog sering memberikan gambaran lebih detail tentang peluncuran dan misi. Wajib bagi penggemar penerbangan luar angkasa.',
                    icon: Icons.article_rounded,
                    color: const Color(0xFF81C784),
                  ),
                  const SizedBox(height: 16),
                  _buildMenuCard(
                    context,
                    type: 'report',
                    title: 'Report',
                    description:
                        'Stasiun luar angkasa dan misi lainnya sering menerbitkan datanya. Dengan SNAPI kamu bisa menyertakannya di aplikasimu.',
                    icon: Icons.bar_chart_rounded,
                    color: const Color(0xFFFF8A65),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String type,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ListScreen(type: type),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1C2233),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF2A2F45)),
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
