import 'package:flutter/material.dart';
import 'screens/home_page.dart';
import 'screens/interaction_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paralysis Patient Application',
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: const Color(0xFF1C4587), // Deep medical blue
          secondary: const Color(0xFF43A047), // Medical green
          tertiary: const Color(0xFF3F51B5), // Accent blue
          surface: Colors.white,
          background: const Color(0xFFF5F5F7), // Light grey background
          error: const Color(0xFFD32F2F), // Medical red
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1C4587),
          foregroundColor: Colors.white,
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF43A047),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/interaction': (context) => const InteractionPage(),
      },
    );
  }
}
