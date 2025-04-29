import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../models/health_data_model.dart';
import '../models/gesture_alert_model.dart';
import '../models/emergency_notification_model.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  static const String patientId = '4a7d3f88-29c1-4b2a-bc49-9cf7f1234567';

  late final SupabaseClient _client;

  SupabaseService._internal();

  Future<void> initialize() async {
    await Supabase.initialize(
      url: 'https://oetthrfpgwdoqjbrlnem.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9ldHRocmZwZ3dkb3FqYnJsbmVtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDA1MDcxMjUsImV4cCI6MjA1NjA4MzEyNX0.O4NvtulRNiSE4nTvUNyEhme4ABzX0OwArh8j0deJMdE',
    );
    _client = Supabase.instance.client;
  }

  // Health Data Methods
  Stream<List<HealthDataModel>> streamHealthData(String? userId) {
    final id = userId ?? patientId;
    return _client
        .from('health_data')
        .stream(primaryKey: ['user_id', 'created_at'])
        .eq('user_id', id)
        .order('created_at', ascending: false)
        .map((rows) =>
            rows.map((row) => HealthDataModel.fromJson(row)).toList());
  }

  Future<List<HealthDataModel>> getLatestHealthData(String? userId,
      {int limit = 1}) async {
    final id = userId ?? patientId;
    final response = await _client
        .from('health_data')
        .select()
        .eq('user_id', id)
        .order('created_at', ascending: false)
        .limit(limit);

    return response
        .map<HealthDataModel>((row) => HealthDataModel.fromJson(row))
        .toList();
  }

  // Gesture Alert Methods
  Stream<List<GestureAlertModel>> streamGestureAlerts(String? userId) {
    final id = userId ?? patientId;
    return _client
        .from('gesture_alerts')
        .stream(primaryKey: ['user_id', 'created_at'])
        .eq('user_id', id)
        .order('created_at', ascending: false)
        .map((rows) =>
            rows.map((row) => GestureAlertModel.fromJson(row)).toList());
  }

  Stream<List<GestureAlertModel>> streamPendingGestureAlerts() {
    return _client
        .from('gesture_alerts')
        .stream(primaryKey: ['user_id', 'created_at'])
        .eq('alert_status', false)
        .order('created_at')
        .map((rows) =>
            rows.map((row) => GestureAlertModel.fromJson(row)).toList());
  }

  Future<void> insertGestureAlert({
    required String userId,
    required String gestureType,
  }) async {
    await _client.from('gesture_alerts').insert({
      'user_id': userId,
      'gesture_type': gestureType,
      'alert_status': false,
    });
  }

  Future<void> updateGestureAlert({
    required String userId,
    required String gestureType,
    required bool alertStatus,
    required DateTime createdAt,
  }) async {
    await _client
        .from('gesture_alerts')
        .update({'alert_status': alertStatus})
        .eq('user_id', userId)
        .eq('gesture_type', gestureType)
        .eq('created_at', createdAt.toIso8601String());
  }

  // Emergency Notification Methods
  Stream<List<EmergencyNotificationModel>> streamEmergencyNotifications(
      String? userId) {
    final id = userId ?? patientId;
    return _client
        .from('emergency_notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', id)
        .order('created_at', ascending: false)
        .map((rows) => rows
            .map((row) => EmergencyNotificationModel.fromJson(row))
            .toList());
  }

  Stream<List<EmergencyNotificationModel>> streamActiveEmergencies() {
    return _client
        .from('emergency_notifications')
        .stream(primaryKey: ['id'])
        .eq('is_resolved', false)
        .order('created_at')
        .map((rows) => rows
            .map((row) => EmergencyNotificationModel.fromJson(row))
            .toList());
  }
}
