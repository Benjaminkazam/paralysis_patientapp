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
  Timer? _healthDataTimer;

  // Vital signs
  String _heartRate = '0';
  String _temperature = '0';
  String _spo2 = '0';

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
      'color': const Color(0xFF2196F3),
      'icon': Icons.water_drop,
      'action': 'Need Water/Food',
      'gesture_type': 'water/food',
      'description': 'Raise index finger for water/food',
    },
    'middle': {
      'color': const Color(0xFFE91E63),
      'icon': Icons.medical_services,
      'action': 'Need Medicine',
      'gesture_type': 'medicine',
      'description': 'Raise middle finger for medical assistance',
    },
    'ring': {
      'color': const Color(0xFF9C27B0),
      'icon': Icons.wc,
      'action': 'Need Bathroom',
      'gesture_type': 'bathroom',
      'description': 'Raise ring finger for bathroom needs',
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

  void _initSupabase() {
    _client = Supabase.instance.client;
    _startHealthDataStream();
    _startGestureStream();
  }

  void _startHealthDataStream() {
    // Initial fetch
    _fetchLatestHealthData();

    // Real-time subscription
    _client
        .from('health_data')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(1)
        .listen((data) {
          if (data.isNotEmpty) {
            setState(() {
              _heartRate = data[0]['heart_rate'].toString();
              _temperature = data[0]['temperature'].toString();
              _spo2 = data[0]['spo2'].toString();
            });
          }
        });

    // Periodic refresh
    _healthDataTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _fetchLatestHealthData();
    });
  }

  void _fetchLatestHealthData() async {
    try {
      final response = await _client
          .from('health_data')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(1)
          .single();

      if (response != null) {
        setState(() {
          _heartRate = response['heart_rate'].toString();
          _temperature = response['temperature'].toString();
          _spo2 = response['spo2'].toString();
        });
      }
    } catch (e) {
      print('Error fetching health data: $e');
    }
  }

  void _startGestureStream() {
    _client
        .from('gesture_alerts')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .listen((data) {
          if (data.isNotEmpty && data[0]['gesture_type'] != null) {
            final gestureType = data[0]['gesture_type'] as String;
            String message = '';
            if (gestureType == 'water/food') {
              message = 'Patient needs water or food';
            } else if (gestureType == 'medicine') {
              message = 'Patient needs medicine';
            } else if (gestureType == 'bathroom') {
              message = 'Patient needs to use the bathroom';
            } else if (gestureType == 'emergency') {
              message = 'Emergency alert!';
            } else {
              message = 'Unknown gesture detected';
            }
            _showAlert('Gesture Alert', message, gestureType == 'emergency');
          }
        });
  }

  @override
  void dispose() {
    _heartBeatController.dispose();
    _temperatureController.dispose();
    _oxygenController.dispose();
    _healthDataTimer?.cancel();
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
    } else {
      _showAlert(
        'Action Detected',
        'Patient moved: $finger\nRequested: ${_fingerConfigs[finger]?['action']}',
        false,
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
    if (!mounted) return;

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

  Widget _buildFingerMovementCard(String finger,
      {required Map<String, dynamic> config}) {
    final Color fingerColor = config['color'] as Color;
    final bool isActive = _activeFingers[finger.toLowerCase()] ?? false;

    return Card(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.height < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Monitoring'),
        centerTitle: true,
        elevation: 0,
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
                              'Stable',
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
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () {
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
                const SizedBox(height: 60), // Space for bottom sheet
              ],
            ),
          ),
        ),
      ),
    );
  }
}
