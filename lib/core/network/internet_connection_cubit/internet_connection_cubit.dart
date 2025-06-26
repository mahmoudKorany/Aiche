import 'dart:async';
import 'dart:io';
import 'package:aiche/core/network/internet_connection_cubit/internet_connection_states.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InternetCubit extends Cubit<InternetState> {
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  InternetCubit() : super(InternetInitial()) {
    checkConnection();
  }

  void checkConnection() {
    _subscription =
        Connectivity().onConnectivityChanged.listen((results) async {
      if (results.contains(ConnectivityResult.wifi) ||
          results.contains(ConnectivityResult.mobile)) {
        // Verify actual internet access
        bool hasInternet = await _hasInternetAccess();
        if (hasInternet) {
          connected();
        } else {
          notConnected();
        }
      } else {
        notConnected();
      }
    });
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

  void connected() {
    emit(ConnectedState(message: "Connected"));
  }

  void notConnected() {
    emit(NotConnectedState(message: "Not Connected"));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
