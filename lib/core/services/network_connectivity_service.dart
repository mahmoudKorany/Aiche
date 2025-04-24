import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkConnectivityService {
  static NetworkConnectivityService? _instance;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool _isConnected = false;

  // Stream controller for connectivity status
  final StreamController<bool> _connectionStatusController =
      StreamController<bool>.broadcast();

  // Stream that can be listened to for network status changes
  Stream<bool> get connectionStatus => _connectionStatusController.stream;

  // Current connection status
  bool get isConnected => _isConnected;

  // Singleton pattern
  static NetworkConnectivityService get instance {
    _instance ??= NetworkConnectivityService._();
    return _instance!;
  }

  NetworkConnectivityService._();

  Future<void> init() async {
    // Initial check
    await _checkConnectivity();

    // Listen for connectivity changes
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _checkConnectivity() async {
    try {
      final connectivityResults = await _connectivity.checkConnectivity();
      _updateConnectionStatus(connectivityResults);
    } catch (e) {
      // debugPrint('Failed to check connectivity: $e');
      _updateConnectionStatus([ConnectivityResult.none]);
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final wasConnected = _isConnected;

    // Consider connected if any result is not 'none'
    _isConnected = results.any((result) => result != ConnectivityResult.none);

    // Only emit event if status changed
    if (wasConnected != _isConnected) {
      _connectionStatusController.add(_isConnected);

      if (_isConnected) {
        // debugPrint('Network connection restored: $results');
      } else {
        //debugPrint('Network connection lost: $results');
      }
    }
  }

  // Helper method to check if there's network connectivity
  Future<bool> checkNetwork() async {
    final connectivityResults = await _connectivity.checkConnectivity();
    return connectivityResults
        .any((result) => result != ConnectivityResult.none);
  }

  void dispose() {
    _connectivitySubscription.cancel();
    _connectionStatusController.close();
  }
}
