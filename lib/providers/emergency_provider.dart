import 'package:flutter/foundation.dart';
import '../models/emergency_notification_model.dart';
import '../services/supabase_service.dart';
import 'dart:async';

class EmergencyProvider with ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  List<EmergencyNotificationModel> _emergencies = [];
  List<EmergencyNotificationModel> _activeEmergencies = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _emergencySubscription;
  StreamSubscription? _activeEmergencySubscription;

  List<EmergencyNotificationModel> get emergencies => _emergencies;
  List<EmergencyNotificationModel> get activeEmergencies => _activeEmergencies;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void startEmergencyStream(String userId) {
    try {
      _emergencySubscription?.cancel();
      _activeEmergencySubscription?.cancel();

      _emergencySubscription =
          _supabaseService.streamEmergencyNotifications(userId).listen(
        (data) {
          _emergencies = data;
          _error = null;
          notifyListeners();
        },
        onError: (error) {
          _error = 'Error streaming emergencies: $error';
          notifyListeners();
        },
      );

      _activeEmergencySubscription =
          _supabaseService.streamActiveEmergencies().listen(
        (data) {
          _activeEmergencies = data;
          notifyListeners();
        },
        onError: (error) {
          print('Error streaming active emergencies: $error'); // Debug print
        },
      );
    } catch (e) {
      _error = 'Error setting up emergency streams: $e';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _emergencySubscription?.cancel();
    _activeEmergencySubscription?.cancel();
    super.dispose();
  }

  bool get hasActiveEmergencies => _activeEmergencies.isNotEmpty;
  int get activeEmergencyCount => _activeEmergencies.length;
}
