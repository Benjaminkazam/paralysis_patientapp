import 'package:flutter/foundation.dart';
import '../models/gesture_alert_model.dart';
import '../services/supabase_service.dart';
import 'dart:async';

class GestureProvider with ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  List<GestureAlertModel> _gestureAlerts = [];
  List<GestureAlertModel> _pendingAlerts = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _gestureSubscription;
  StreamSubscription? _pendingAlertsSubscription;

  List<GestureAlertModel> get gestureAlerts => _gestureAlerts;
  List<GestureAlertModel> get pendingAlerts => _pendingAlerts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void startGestureAlertStream(String? userId) {
    try {
      _gestureSubscription?.cancel();
      _pendingAlertsSubscription?.cancel();

      _gestureSubscription =
          _supabaseService.streamGestureAlerts(userId).listen(
        (data) {
          _gestureAlerts = data;
          _error = null;
          notifyListeners();
        },
        onError: (error) {
          _error = 'Error streaming gesture alerts: $error';
          notifyListeners();
        },
      );

      _pendingAlertsSubscription =
          _supabaseService.streamPendingGestureAlerts().listen(
        (data) {
          _pendingAlerts = data;
          notifyListeners();
        },
        onError: (error) {
          print('Error streaming pending alerts: $error'); // Debug print
        },
      );
    } catch (e) {
      _error = 'Error setting up gesture streams: $e';
      notifyListeners();
    }
  }

  Future<void> createGestureAlert({
    required String userId,
    required String gestureType,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _supabaseService.insertGestureAlert(
        userId: userId,
        gestureType: gestureType,
      );
    } catch (e) {
      _error = 'Failed to create gesture alert: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> acknowledgeAlert(GestureAlertModel alert) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _supabaseService.updateGestureAlert(
        userId: alert.userId,
        gestureType: alert.gestureType,
        alertStatus: true,
      );
    } catch (e) {
      _error = 'Failed to acknowledge alert: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _gestureSubscription?.cancel();
    _pendingAlertsSubscription?.cancel();
    super.dispose();
  }

  int get pendingAlertsCount => _pendingAlerts.length;

  bool hasActiveAlertOfType(String gestureType) {
    return _pendingAlerts
        .any((alert) => alert.gestureType == gestureType && !alert.alertStatus);
  }
}
