import 'base_model.dart';

class EmergencyNotificationModel extends BaseModel {
  final int id;
  final String userId;
  final String alertMessage;
  final bool isResolved;

  EmergencyNotificationModel({
    required this.id,
    required this.userId,
    required this.alertMessage,
    required this.isResolved,
    required DateTime createdAt,
  }) : super(createdAt: createdAt);

  factory EmergencyNotificationModel.fromJson(Map<String, dynamic> json) {
    return EmergencyNotificationModel(
      id: json['id'],
      userId: json['user_id'],
      alertMessage: json['alert_message'],
      isResolved: json['is_resolved'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'alert_message': alertMessage,
      'is_resolved': isResolved,
      'created_at': createdAt.toIso8601String(),
    };
  }

  EmergencyNotificationModel copyWith({
    int? id,
    String? userId,
    String? alertMessage,
    bool? isResolved,
    DateTime? createdAt,
  }) {
    return EmergencyNotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      alertMessage: alertMessage ?? this.alertMessage,
      isResolved: isResolved ?? this.isResolved,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
