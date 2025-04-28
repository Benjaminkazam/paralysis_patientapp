import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_page.dart';
import 'screens/interaction_page.dart';
import 'providers/health_provider.dart';
import 'providers/gesture_provider.dart';
import 'providers/emergency_provider.dart';
import 'services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  try {
    print('Initializing Supabase...'); // Debug print
    final supabaseService = SupabaseService();
    await supabaseService.initialize();
    print('Supabase initialized successfully'); // Debug print

    // Verify initial health data fetch
    final healthData =
        await supabaseService.getLatestHealthData(SupabaseService.patientId);
    print('Initial health data check: ${healthData.length} records found');
  } catch (e) {
    print('Error during initialization: $e'); // Debug print
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final provider = HealthProvider();
            // Start streaming health data for the specified patient
            provider.startHealthDataStream(SupabaseService.patientId);
            return provider;
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            final provider = GestureProvider();
            provider.startGestureAlertStream(SupabaseService.patientId);
            return provider;
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            final provider = EmergencyProvider();
            provider.startEmergencyStream(SupabaseService.patientId);
            return provider;
          },
        ),
      ],
      child: MaterialApp(
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
        initialRoute: '/',
        routes: {
          '/': (context) => const HomePage(),
          '/interaction': (context) => const InteractionPage(),
        },
      ),
    );
  }
}
