import 'package:flutter/foundation.dart';
import '../models/health_data_model.dart';
import '../services/supabase_service.dart';
import 'dart:async';

class HealthProvider with ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  List<HealthDataModel> _healthData = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _healthDataSubscription;

  List<HealthDataModel> get healthData => _healthData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadHealthData(String? userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final data = await _supabaseService.getLatestHealthData(userId);
      print('Loaded health data: $data'); // Debug print
      _healthData = data;
    } catch (e) {
      print('Error loading health data: $e'); // Debug print
      _error = 'Failed to load health data: $e';
      _healthData = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void startHealthDataStream(String? userId) {
    try {
      print('Starting health data stream...'); // Debug print

      // Cancel existing subscription if any
      _healthDataSubscription?.cancel();

      // Start new subscription
      _healthDataSubscription =
          _supabaseService.streamHealthData(userId).listen(
        (data) {
          print('Received new health data: $data'); // Debug print
          _healthData = data;
          _error = null;
          notifyListeners();
        },
        onError: (error) {
          print('Error in health data stream: $error'); // Debug print
          _error = 'Error streaming health data: $error';
          notifyListeners();
        },
        cancelOnError: false,
      );
    } catch (e) {
      print('Error setting up health data stream: $e'); // Debug print
      _error = 'Error setting up health data stream: $e';
      notifyListeners();
    }
  }

  HealthDataModel? get latestHealthData {
    if (_healthData.isEmpty) {
      print('No health data available'); // Debug print
      return null;
    }
    print('Latest health data: ${_healthData.first}'); // Debug print
    return _healthData.first;
  }

  @override
  void dispose() {
    _healthDataSubscription?.cancel();
    super.dispose();
  }

  // Method to force refresh data
  Future<void> refreshData(String? userId) async {
    await loadHealthData(userId);
    startHealthDataStream(userId);
  }
}
