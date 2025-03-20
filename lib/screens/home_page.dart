import 'package:flutter/material.dart';
import '../models/vital_data.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late final AnimationController _heartBeatController;
  late final AnimationController _temperatureController;
  late final AnimationController _oxygenController;

  final VitalData _dummyData = VitalData(
    heartRate: 75,
    temperature: 37,
    oxygenLevel: 98,
    movementStatus: "Stable",
  );

  // Add vital sign thresholds
  static const Map<String, Map<String, double>> _vitalThresholds = {
    'heartRate': {'min': 60, 'max': 100},
    'temperature': {'min': 36.1, 'max': 37.2},
    'oxygenLevel': {'min': 95, 'max': 100},
  };

  bool _isVitalSignNormal(String vitalType, double value) {
    final threshold = _vitalThresholds[vitalType]!;
    return value >= threshold['min']! && value <= threshold['max']!;
  }

  bool get _isEmergencyState {
    return !_isVitalSignNormal('heartRate', _dummyData.heartRate) &&
        !_isVitalSignNormal('temperature', _dummyData.temperature) &&
        !_isVitalSignNormal('oxygenLevel', _dummyData.oxygenLevel);
  }

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
            size: 80, // Increased from 64 to 80
            color: color.withOpacity(0.5 + controller.value * 0.5),
          ),
        );
      },
    );
  }

  Widget _buildVitalCard(String title, String value, String unit, IconData icon,
      Color iconColor, AnimationController controller, String vitalType) {
    final double numValue = double.parse(value);
    final bool isNormal = _isVitalSignNormal(vitalType, numValue);
    final Color displayColor =
        isNormal ? iconColor : Theme.of(context).colorScheme.error;

    return Expanded(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24), // Increased from 20
          side: BorderSide(
            color: displayColor.withOpacity(0.3),
            width: 1.5, // Slightly thicker border
          ),
        ),
        child: Container(
          height: 180, // Adjusted for better fit
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                displayColor.withOpacity(0.05),
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
              _buildAnimatedIcon(icon, displayColor, controller),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16, // Increased from 12
                  color: displayColor.withOpacity(0.8),
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
                      fontSize: 28, // Slightly reduced for better fit
                      fontWeight: FontWeight.bold,
                      color: displayColor,
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    unit,
                    style: TextStyle(
                      fontSize: 14, // Increased from 10
                      color: displayColor.withOpacity(0.7),
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

  Widget _buildEmergencyWarning() {
    if (!_isEmergencyState) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.error,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Theme.of(context).colorScheme.error,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'CRITICAL: All vital signs are outside normal range!\nImmediate medical attention required.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
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
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(12, isSmallScreen ? 8 : 16, 12, 16),
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
                _buildEmergencyWarning(),
                SizedBox(height: isSmallScreen ? 12 : 20),
                // Vital signs row
                Row(
                  children: [
                    _buildVitalCard(
                      'Heart Rate',
                      _dummyData.heartRate.toString(),
                      'bpm',
                      Icons.favorite_rounded,
                      const Color(0xFFE53935),
                      _heartBeatController,
                      'heartRate',
                    ),
                    const SizedBox(width: 8),
                    _buildVitalCard(
                      'Temperature',
                      _dummyData.temperature.toString(),
                      '°C',
                      Icons.thermostat_rounded,
                      const Color(0xFFFF8F00),
                      _temperatureController,
                      'temperature',
                    ),
                    const SizedBox(width: 8),
                    _buildVitalCard(
                      'Oxygen',
                      _dummyData.oxygenLevel.toString(),
                      '%',
                      Icons.air_rounded,
                      const Color(0xFF7B1FA2),
                      _oxygenController,
                      'oxygenLevel',
                    ),
                  ],
                ),
                SizedBox(height: isSmallScreen ? 12 : 20),
                // Movement status card with improved design
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20), // Increased padding
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
                            size: 40, // Increased from 28
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
                                fontSize: 18, // Increased from 14
                              ),
                            ),
                            Text(
                              _dummyData.movementStatus,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: 16, // Increased from 13
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(), // Added to push content to the top
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/interaction');
        },
        icon: const Icon(Icons.gesture),
        label: const Text('Interaction'),
        elevation: 4,
      ),
    );
  }
}
