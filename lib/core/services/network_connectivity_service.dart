import 'dart:async';
import 'dart:io';
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
      await _updateConnectionStatus(connectivityResults);
    } catch (e) {
      // debugPrint('Failed to check connectivity: $e');
      await _updateConnectionStatus([ConnectivityResult.none]);
    }
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> results) async {
    final wasConnected = _isConnected;

    // First check if we have network connectivity
    bool hasNetworkConnection =
        results.any((result) => result != ConnectivityResult.none);

    // If we have network connection, verify actual internet access
    bool hasInternetAccess = false;
    if (hasNetworkConnection) {
      hasInternetAccess = await _hasInternetAccess();
    }

    _isConnected = hasInternetAccess;

    // Only emit event if status changed
    if (wasConnected != _isConnected) {
      _connectionStatusController.add(_isConnected);

      if (_isConnected) {
        // debugPrint('Internet connection verified: $results');
      } else {
        // debugPrint('No internet access: $results');
      }
    }
  }

  // Check actual internet connectivity by pinging reliable servers
  Future<bool> _hasInternetAccess() async {
    try {
      // Try multiple reliable endpoints
      final List<String> testUrls = [
        'google.com',
        'cloudflare.com',
        '8.8.8.8', // Google DNS
        '1.1.1.1', // Cloudflare DNS
      ];

      for (String url in testUrls) {
        try {
          final result = await InternetAddress.lookup(url)
              .timeout(const Duration(seconds: 5));
          if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
            return true;
          }
        } catch (e) {
          // Try next URL
          continue;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Helper method to check if there's network connectivity
  Future<bool> checkNetwork() async {
    final connectivityResults = await _connectivity.checkConnectivity();
    bool hasNetworkConnection =
        connectivityResults.any((result) => result != ConnectivityResult.none);

    if (hasNetworkConnection) {
      return await _hasInternetAccess();
    }
    return false;
  }

  void dispose() {
    _connectivitySubscription.cancel();
    _connectionStatusController.close();
  }
}
