import 'dart:async';
import 'package:aiche/core/network/internet_connection_cubit/internet_connection_states.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InternetCubit extends Cubit<InternetState> {
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  InternetCubit() : super(InternetInitial()) {
    checkConnection();
  }

  void checkConnection() {
    _subscription = Connectivity().onConnectivityChanged.listen((results) {
      if (results.contains(ConnectivityResult.wifi) || results.contains(ConnectivityResult.mobile)) {
        connected();
      } else {
        notConnected();
      }
    });
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