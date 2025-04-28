import 'base_model.dart';

class HealthDataModel extends BaseModel {
  final String userId;
  final double temperature;
  final double heartRate;
  final double spo2;

  HealthDataModel({
    required this.userId,
    required this.temperature,
    required this.heartRate,
    required this.spo2,
    required DateTime createdAt,
  }) : super(createdAt: createdAt);

  factory HealthDataModel.fromJson(Map<String, dynamic> json) {
    return HealthDataModel(
      userId: json['user_id'],
      temperature: json['temperature'].toDouble(),
      heartRate: json['heart_rate'].toDouble(),
      spo2: json['spo2'].toDouble(),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'temperature': temperature,
      'heart_rate': heartRate,
      'spo2': spo2,
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool isTemperatureNormal(double min, double max) {
    return temperature >= min && temperature <= max;
  }

  bool isHeartRateNormal(double min, double max) {
    return heartRate >= min && heartRate <= max;
  }

  bool isSpo2Normal(double min, double max) {
    return spo2 >= min && spo2 <= max;
  }
}
