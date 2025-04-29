import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://oetthrfpgwdoqjbrlnem.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9ldHRocmZwZ3dkb3FqYnJsbmVtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDA1MDcxMjUsImV4cCI6MjA1NjA4MzEyNX0.O4NvtulRNiSE4nTvUNyEhme4ABzX0OwArh8j0deJMdE',
  );

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
          background: const Color(0xFFF5F5F7),
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
      home: const HomePage(),
    );
  }
}
