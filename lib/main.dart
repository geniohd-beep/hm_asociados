import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hm_asociados/theme/app_theme.dart';
import 'package:hm_asociados/screens/home_screen.dart';
import 'package:hm_asociados/screens/blog_screen.dart';
import 'package:hm_asociados/screens/contact_screen.dart';
import 'package:hm_asociados/screens/clients_screen.dart';
import 'package:hm_asociados/widgets/chat_fab.dart';
import 'package:hm_asociados/services/ai_service.dart';

void main() {
  runApp(const HMAsociadosApp());
}

class HMAsociadosApp extends StatelessWidget {
  const HMAsociadosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HM & Asociados',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
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

  final List<Widget> _screens = const [
    HomeScreen(),
    BlogScreen(),
    ContactScreen(),
    ClientsScreen(),
  ];

  static const _titles = ['', 'BLOG', 'CONTACTO', 'CLIENTES'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentIndex == 0
          ? null
          : AppBar(
              title: Text(
                _titles[_currentIndex],
                style: GoogleFonts.cinzel(
                  fontSize: 20,
                  color: AppTheme.primaryGold,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: AppTheme.primaryDark,
              iconTheme: const IconThemeData(color: AppTheme.primaryGold),
            ),
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'INICIO',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: 'BLOG',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contact_phone),
            label: 'CONTACTO',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'CLIENTES',
          ),
        ],
      ),
      floatingActionButton: ChatFAB(
        aiService: AIService(
          apiKey: const String.fromEnvironment('AI_API_KEY', defaultValue: ''),
          endpoint: const String.fromEnvironment('AI_ENDPOINT', defaultValue: ''),
          model: const String.fromEnvironment('AI_MODEL', defaultValue: 'gpt-4o-mini'),
        ),
      ),
    );
  }
}
