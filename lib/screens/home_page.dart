import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late final AnimationController _heartBeatController;
  late final AnimationController _temperatureController;
  late final AnimationController _oxygenController;
  final bool _isConnected = true;
  late final SupabaseClient _client;
  final String userId = '4a7d3f88-29c1-4b2a-bc49-9cf7f1234567';
  DateTime? _lastProcessedGesture;

  // Vital signs
  String _heartRate = '0';
  String _temperature = '0';
  String _spo2 = '0';
  String movementStatus = 'Stable';

  // Add finger configurations
  final Map<String, Map<String, dynamic>> _fingerConfigs = {
    'Middle': {
      'color': const Color(0xFF2196F3),
      'icon': Icons.water_drop,
      'action': 'Need Water/Food',
      'gesture_type': 'water/food',
      'description': 'Raise Middle finger for water/food',
    },
    'Ring': {
      'color': const Color(0xFFE91E63),
      'icon': Icons.medical_services,
      'action': 'Need Medicine',
      'gesture_type': 'medicine',
      'description': 'Raise Ring finger for medical assistance',
    },
    'Pinky': {
      'color': const Color(0xFF9C27B0),
      'icon': Icons.wc,
      'action': 'Need Bathroom',
      'gesture_type': 'bathroom',
      'description': 'Raise Pinky finger for bathroom needs',
    },
  };

  @override
  void initState() {
    super.initState();
    _heartBeatController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    _temperatureController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _oxygenController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _initSupabase();
  }

  void _initSupabase() async {
    _client = Supabase.instance.client;

    // Get and process latest gesture
    try {
      final latestGesture = await _client
          .from('gesture_alerts')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(1)
          .single();

      if (latestGesture != null) {
        _processGestureAlert(latestGesture);
      }
    } catch (e) {
      print('Error fetching latest gesture: $e');
    }

    _startHealthDataStream();
    _startGestureStream();
  }

  void _processGestureAlert(Map<String, dynamic> gestureData) {
    if (gestureData['gesture_type'] == null ||
        gestureData['created_at'] == null) return;

    movementStatus = gestureData['gesture_type'] as String;

    final timestamp = DateTime.parse(gestureData['created_at']);
    final gestureType = gestureData['gesture_type'] as String;

    String message = '';
    if (gestureType == 'water/food') {
      message = 'Patient needs water or food';
      movementStatus = 'Water/Food Alert';
      _showAlert('Gesture Alert', message, gestureType == 'emergency');
    } else if (gestureType == 'medicine') {
      message = 'Patient needs medicine';
      movementStatus = 'Medicine Alert';
      _showAlert('Gesture Alert', message, gestureType == 'emergency');
    } else if (gestureType == 'bathroom') {
      movementStatus = 'Bathroom Alert';
      message = 'Patient needs to use the bathroom';
      _showAlert('Gesture Alert', message, gestureType == 'emergency');
    } else if (gestureType == 'emergency') {
      movementStatus = 'Emergency Alert';
      message = 'Emergency alert!';
      _showAlert('Gesture Alert', message, gestureType == 'emergency');
    }

    _lastProcessedGesture = timestamp;
  }

  void _startHealthDataStream() async {
    // Get initial health data
    try {
      final initialData = await _client
          .from('health_data')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(1)
          .single();

      if (initialData != null) {
        setState(() {
          _heartRate = initialData['heart_rate'].toString();
          _temperature = initialData['temperature'].toString();
          _spo2 = initialData['spo2'].toString();
        });
      }
    } catch (e) {
      print('Error fetching initial health data: $e');
    }

    // Start real-time stream
    _client
        .from('health_data')
        .stream(primaryKey: ['id', 'created_at'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(1)
        .map((maps) => maps)
        .listen((data) {
          if (data.isNotEmpty) {
            setState(() {
              _heartRate = data[0]['heart_rate'].toString();
              _temperature = data[0]['temperature'].toString();
              _spo2 = data[0]['spo2'].toString();
            });
          }
        });
  }

  void _startGestureStream() {
    _client
        .from('gesture_alerts')
        .stream(primaryKey: ['id', 'created_at'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(1)
        .listen((data) {
          if (data.isNotEmpty) {
            setState(() {
              _processGestureAlert(data[0]);
            });
          }
        });
  }

  @override
  void dispose() {
    _heartBeatController.dispose();
    _temperatureController.dispose();
    _oxygenController.dispose();
    super.dispose();
  }

  Widget _buildAnimatedIcon(
      IconData icon, Color color, AnimationController controller) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + controller.value * 0.2,
          child: Icon(
            icon,
            size: 80,
            color: color.withOpacity(0.5 + controller.value * 0.5),
          ),
        );
      },
    );
  }

  Widget _buildVitalCard(String title, String value, String unit, IconData icon,
      Color iconColor, AnimationController controller) {
    return Expanded(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: iconColor.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Container(
          height: 180,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                iconColor.withOpacity(0.05),
                Colors.white,
                Colors.white,
              ],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildAnimatedIcon(icon, iconColor, controller),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: iconColor.withOpacity(0.8),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                textBaseline: TextBaseline.alphabetic,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: iconColor,
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    unit,
                    style: TextStyle(
                      fontSize: 14,
                      color: iconColor.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAlert(String title, String message, bool isEmergency) {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
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

  Widget _buildFingerMovementCard(String finger,
      {required Map<String, dynamic> config}) {
    final Color fingerColor = config['color'] as Color;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
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
                      color: fingerColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    config['action'] as String,
                    style: TextStyle(
                      color: fingerColor.withOpacity(0.7),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.height < 600;

    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/IMG_8064.PNG',
          height: 180,
          fit: BoxFit.contain,
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {},
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16.0),
        color: _isConnected ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
        child: Row(
          children: [
            Icon(
              _isConnected ? Icons.health_and_safety : Icons.health_and_safety,
              color: _isConnected
                  ? const Color(0xFF43A047)
                  : const Color(0xFFD32F2F),
            ),
            const SizedBox(width: 8),
            Text(
              _isConnected ? 'Room Number: 12 ' : 'Room Number: 12 (Offline)',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const Spacer(),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(12, isSmallScreen ? 8 : 16, 12, 76),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: isSmallScreen ? 8 : 16,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.monitor_heart_outlined,
                        color: Theme.of(context).colorScheme.primary,
                        size: isSmallScreen ? 24 : 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Vital Signs Monitor',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 20 : 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isSmallScreen ? 12 : 20),
                Row(
                  children: [
                    _buildVitalCard(
                      'Heart Rate',
                      _heartRate,
                      'bpm',
                      Icons.favorite_rounded,
                      const Color(0xFFE53935),
                      _heartBeatController,
                    ),
                    const SizedBox(width: 8),
                    _buildVitalCard(
                      'Temperature',
                      _temperature,
                      '°C',
                      Icons.thermostat_rounded,
                      const Color(0xFFFF8F00),
                      _temperatureController,
                    ),
                    const SizedBox(width: 8),
                    _buildVitalCard(
                      'SpO2',
                      _spo2,
                      '%',
                      Icons.air_rounded,
                      const Color(0xFF7B1FA2),
                      _oxygenController,
                    ),
                  ],
                ),
                SizedBox(height: isSmallScreen ? 12 : 20),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.accessibility_new_rounded,
                            size: 40,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Movement Status',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              movementStatus,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Column(
                  children: _fingerConfigs.entries.map((entry) {
                    return _buildFingerMovementCard(
                      entry.key,
                      config: entry.value,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 60), // Space for bottom sheet
              ],
            ),
          ),
        ),
      ),
    );
  }
}
