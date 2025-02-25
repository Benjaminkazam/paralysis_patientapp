class VitalData {
  final double heartRate;
  final double bloodPressure;
  final double temperature;
  final double oxygenLevel; // Added back
  final String movementStatus;

  VitalData({
    required this.heartRate,
    required this.bloodPressure,
    required this.temperature,
    required this.oxygenLevel, // Added back
    required this.movementStatus,
  });
}
