import 'package:flutter/material.dart';
import '../models/vital_data.dart';
import 'dart:math' as math;

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
            size: 64, // Increased from 48 to 64
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

    return Card(
      elevation: 3,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              displayColor.withOpacity(0.1),
              Colors.white,
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: !isNormal
              ? Border.all(
                  color: Theme.of(context).colorScheme.error,
                  width: 2,
                )
              : null,
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16), // Increased from 12 to 16
              decoration: BoxDecoration(
                color: displayColor.withOpacity(0.1),
                borderRadius:
                    BorderRadius.circular(60), // Increased from 50 to 60
              ),
              child: _buildAnimatedIcon(icon, displayColor, controller),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: displayColor.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: displayColor,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: TextStyle(
                    fontSize: 14,
                    color: displayColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ],
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Monitoring'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Implement refresh logic
        },
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            const Text('Vitals Monitor',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            _buildEmergencyWarning(),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.85,
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
                _buildVitalCard(
                  'Temperature',
                  _dummyData.temperature.toString(),
                  '°C',
                  Icons.thermostat_rounded,
                  const Color(0xFFFF8F00),
                  _temperatureController,
                  'temperature',
                ),
                _buildVitalCard(
                  'Oxygen Level',
                  _dummyData.oxygenLevel.toString(),
                  '%',
                  Icons.air_rounded,
                  const Color(0xFF7B1FA2),
                  _oxygenController,
                  'oxygenLevel',
                ),
              ],
            ),
            const SizedBox(height: 20),
            Card(
              child: ListTile(
                leading: Icon(
                  Icons.accessibility_new_rounded,
                  size: 32,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text('Movement Status'),
                subtitle: Text(_dummyData.movementStatus),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Emergency Alerts',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            // Add emergency alerts list here
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/interaction');
        },
        child: const Icon(Icons.gesture),
      ),
    );
  }
}
