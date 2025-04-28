import 'base_model.dart';

class GestureAlertModel extends BaseModel {
  final String userId;
  final String gestureType;
  final bool alertStatus;

  GestureAlertModel({
    required this.userId,
    required this.gestureType,
    required this.alertStatus,
    required DateTime createdAt,
  }) : super(createdAt: createdAt);

  factory GestureAlertModel.fromJson(Map<String, dynamic> json) {
    return GestureAlertModel(
      userId: json['user_id'],
      gestureType: json['gesture_type'],
      alertStatus: json['alert_status'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'gesture_type': gestureType,
      'alert_status': alertStatus,
      'created_at': createdAt.toIso8601String(),
    };
  }

  GestureAlertModel copyWith({
    String? userId,
    String? gestureType,
    bool? alertStatus,
    DateTime? createdAt,
  }) {
    return GestureAlertModel(
      userId: userId ?? this.userId,
      gestureType: gestureType ?? this.gestureType,
      alertStatus: alertStatus ?? this.alertStatus,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
