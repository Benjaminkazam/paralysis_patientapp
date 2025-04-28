import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../providers/health_provider.dart';
import '../models/health_data_model.dart';
import '../services/supabase_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late final AnimationController _heartBeatController;
  late final AnimationController _temperatureController;
  late final AnimationController _oxygenController;
  Timer? _refreshTimer;

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

  bool _isEmergencyState(HealthDataModel? healthData) {
    if (healthData == null) return false;
    return !_isVitalSignNormal('heartRate', healthData.heartRate) &&
        !_isVitalSignNormal('temperature', healthData.temperature) &&
        !_isVitalSignNormal('oxygenLevel', healthData.spo2);
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

    _initializeHealthData();
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    // Refresh every 5 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        _initializeHealthData();
      }
    });
  }

  void _initializeHealthData() {
    Future.microtask(() async {
      final provider = Provider.of<HealthProvider>(context, listen: false);
      // First load the data
      await provider.loadHealthData(SupabaseService.patientId);
      // Then start the stream
      provider.startHealthDataStream(SupabaseService.patientId);
    });
  }

  @override
  void dispose() {
    _heartBeatController.dispose();
    _temperatureController.dispose();
    _oxygenController.dispose();
    _refreshTimer?.cancel();
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
      Color iconColor, AnimationController controller, String vitalType) {
    final double numValue = double.parse(value);
    final bool isNormal = _isVitalSignNormal(vitalType, numValue);
    final Color displayColor =
        isNormal ? iconColor : Theme.of(context).colorScheme.error;

    return Expanded(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: displayColor.withOpacity(0.3),
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
                  fontSize: 16,
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
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: displayColor,
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    unit,
                    style: TextStyle(
                      fontSize: 14,
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

  Widget _buildEmergencyWarning(HealthDataModel? healthData) {
    if (!_isEmergencyState(healthData)) return const SizedBox.shrink();

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
      body: Consumer<HealthProvider>(
        builder: (context, healthProvider, child) {
          final healthData = healthProvider.latestHealthData;

          if (healthProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Container(
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
                padding:
                    EdgeInsets.fromLTRB(12, isSmallScreen ? 8 : 16, 12, 16),
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
                    if (healthProvider.error != null)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          healthProvider.error!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    _buildEmergencyWarning(healthData),
                    SizedBox(height: isSmallScreen ? 12 : 20),
                    Row(
                      children: [
                        _buildVitalCard(
                          'Heart Rate',
                          healthData?.heartRate.toStringAsFixed(1) ?? '0',
                          'bpm',
                          Icons.favorite_rounded,
                          const Color(0xFFE53935),
                          _heartBeatController,
                          'heartRate',
                        ),
                        const SizedBox(width: 8),
                        _buildVitalCard(
                          'Temperature',
                          healthData?.temperature.toStringAsFixed(1) ?? '0',
                          '°C',
                          Icons.thermostat_rounded,
                          const Color(0xFFFF8F00),
                          _temperatureController,
                          'temperature',
                        ),
                        const SizedBox(width: 8),
                        _buildVitalCard(
                          'SpO2',
                          healthData?.spo2.toStringAsFixed(1) ?? '0',
                          '%',
                          Icons.air_rounded,
                          const Color(0xFF7B1FA2),
                          _oxygenController,
                          'oxygenLevel',
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
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          );
        },
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
