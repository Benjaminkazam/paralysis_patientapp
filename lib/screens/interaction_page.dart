import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/gesture_provider.dart';
import '../models/gesture_alert_model.dart';
import '../services/supabase_service.dart';

class InteractionPage extends StatefulWidget {
  const InteractionPage({super.key});

  @override
  State<InteractionPage> createState() => _InteractionPageState();
}

class _InteractionPageState extends State<InteractionPage> {
  final bool _isConnected = true;
  // Add finger state tracking
  final Map<String, bool> _activeFingers = {
    'index': false,
    'middle': false,
    'ring': false,
    'pinky': false,
  };

  // Add finger configurations
  final Map<String, Map<String, dynamic>> _fingerConfigs = {
    'index': {
      'color': const Color(0xFF2196F3), // Blue for water
      'icon': Icons.water_drop,
      'action': 'Need Water',
      'gesture_type': 'water',
      'description': 'Raise index finger for water',
    },
    'middle': {
      'color': const Color(0xFFE91E63), // Pink for medical
      'icon': Icons.medical_services,
      'action': 'Need Medicine',
      'gesture_type': 'medicine',
      'description': 'Raise middle finger for medical assistance',
    },
    'ring': {
      'color': const Color(0xFF9C27B0), // Purple for bathroom
      'icon': Icons.wc,
      'action': 'Need Bathroom',
      'gesture_type': 'bathroom',
      'description': 'Raise ring finger for bathroom needs',
    },
  };

  @override
  void initState() {
    super.initState();
    // Start gesture alert stream
    Future.microtask(() {
      final provider = context.read<GestureProvider>();
      provider.startGestureAlertStream(SupabaseService.patientId);
    });
  }

  void _handleFingerMovement(String finger, String gestureType) {
    setState(() {
      _activeFingers[finger] = true;
    });

    // Check if multiple fingers are active
    int activeCount = _activeFingers.values.where((active) => active).length;

    if (activeCount > 1) {
      _showAlert(
        'Emergency Alert',
        'Multiple finger movements detected!\nTreating as emergency signal.',
        true,
      );
      // Create emergency gesture alert
      context.read<GestureProvider>().createGestureAlert(
            userId: SupabaseService.patientId,
            gestureType: 'emergency',
          );
    } else {
      _showAlert(
        'Action Detected',
        'Patient moved: $finger\nRequested: ${_fingerConfigs[finger]?['action']}',
        false,
      );
      // Create normal gesture alert
      context.read<GestureProvider>().createGestureAlert(
            userId: SupabaseService.patientId,
            gestureType: gestureType,
          );
    }

    // Reset finger state after delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _activeFingers[finger] = false;
        });
      }
    });
  }

  void _showAlert(String title, String message, bool isEmergency) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: TextStyle(
              color: isEmergency
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.primary,
            ),
          ),
          content: Text(message),
          icon: Icon(
            isEmergency ? Icons.warning_rounded : Icons.info_outline,
            color: isEmergency
                ? Theme.of(context).colorScheme.error
                : Theme.of(context).colorScheme.primary,
            size: 32,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFingerMovementCard(String finger, {required double cardHeight}) {
    final config = _fingerConfigs[finger.toLowerCase()]!;
    final Color fingerColor = config['color'] as Color;
    final bool isActive = _activeFingers[finger.toLowerCase()] ?? false;

    return SizedBox(
      height: cardHeight,
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        child: InkWell(
          onTap: () => _handleFingerMovement(
              finger.toLowerCase(), config['gesture_type'] as String),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: isActive ? fingerColor : fingerColor.withOpacity(0.2),
              ),
              borderRadius: BorderRadius.circular(12),
              gradient: isActive
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        fingerColor.withOpacity(0.2),
                        Colors.white,
                      ],
                    )
                  : null,
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: fingerColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: fingerColor.withOpacity(0.2),
                      ),
                    ),
                    child: Icon(
                      config['icon'] as IconData,
                      color: fingerColor,
                      size: 28,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$finger Finger',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: isActive ? fingerColor : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        config['action'] as String,
                        style: TextStyle(
                          color: isActive
                              ? fingerColor
                              : fingerColor.withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        config['description'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.secondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cardHeight = (size.height - 300) / 3; // Dynamic card height

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Finger Movement Controls'),
        elevation: 2,
      ),
      body: Consumer<GestureProvider>(
        builder: (context, gestureProvider, child) {
          return Column(
            children: [
              // Connection status container
              Container(
                padding: const EdgeInsets.all(16.0),
                color: _isConnected
                    ? const Color(0xFFE8F5E9)
                    : const Color(0xFFFFEBEE),
                child: Row(
                  children: [
                    Icon(
                      _isConnected ? Icons.wifi : Icons.wifi_off,
                      color: _isConnected
                          ? const Color(0xFF43A047)
                          : const Color(0xFFD32F2F),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isConnected ? 'Sensor Connected' : 'Sensor Disconnected',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const Spacer(),
                    if (gestureProvider.pendingAlertsCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.error,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${gestureProvider.pendingAlertsCount} pending',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Display error if any
              if (gestureProvider.error != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    gestureProvider.error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              // Instructions text
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_rounded,
                        color: Theme.of(context).colorScheme.error,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'EMERGENCY MODE activates automatically when multiple fingers are raised!',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Finger movement cards
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      _buildFingerMovementCard('Index', cardHeight: cardHeight),
                      _buildFingerMovementCard('Middle',
                          cardHeight: cardHeight),
                      _buildFingerMovementCard('Ring', cardHeight: cardHeight),
                    ],
                  ),
                ),
              ),
              // Emergency button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    // Create emergency alert
                    context.read<GestureProvider>().createGestureAlert(
                          userId: SupabaseService.patientId,
                          gestureType: 'emergency',
                        );
                    _showAlert(
                      'Emergency Alert',
                      'Emergency signal received from patient!\nImmediate assistance required.',
                      true,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    minimumSize: const Size(double.infinity, 60),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.warning_rounded, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'EMERGENCY',
                        style: TextStyle(fontSize: 24, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
