import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';

/// A utility class to handle Firebase-related errors with special focus on
/// network connection errors.
class FirebaseErrorHandler {
  /// Stream controller for broadcasting network status specifically for Firebase operations
  static final StreamController<bool> _firebaseNetworkStreamController =
      StreamController<bool>.broadcast();

  /// Stream that can be listened to for Firebase network status changes
  static Stream<bool> get firebaseNetworkStream =>
      _firebaseNetworkStreamController.stream;

  /// Last known error
  static FirebaseException? _lastError;
  static FirebaseException? get lastError => _lastError;

  /// Flag to indicate whether a network retry is in progress
  static bool _isRetryInProgress = false;
  static bool get isRetryInProgress => _isRetryInProgress;

  /// Handle Firebase exceptions with special attention to network issues
  static void handleError(Object error, {Function? retryCallback}) {
    bool isNetworkError = false;

    if (error is FirebaseException) {
      _lastError = error;

      // Check if the error is network related
      if (error.message?.contains('network') == true ||
          error.message?.contains('connection') == true ||
          error.code == 'unknown') {
        isNetworkError = true;
      }
    } else if (error is PlatformException) {
      // Check for network-related platform exceptions
      if (error.message?.contains('network') == true ||
          error.message?.contains('connection') == true) {
        isNetworkError = true;
      }
    }

    // Log the error
    // debugPrint(errorMessage);

    // If it's a network error, notify listeners
    if (isNetworkError) {
      _firebaseNetworkStreamController.add(false);

      // If a retry callback is provided, schedule a retry
      if (retryCallback != null && !_isRetryInProgress) {
        _scheduleRetry(retryCallback);
      }
    }
  }

  /// Schedule a retry for a Firebase operation after a network error
  static void _scheduleRetry(Function retryCallback) {
    _isRetryInProgress = true;

    // Retry after 5 seconds
    Timer(const Duration(seconds: 5), () async {
      // debugPrint('Attempting to retry Firebase operation after network error');
      try {
        await retryCallback();
        // If successful, notify listeners that network is back
        _firebaseNetworkStreamController.add(true);
        _isRetryInProgress = false;
        _lastError = null;
      } catch (e) {
        // If still failing, handle the error again (which may schedule another retry)
        // debugPrint('Retry failed: $e');
        _isRetryInProgress = false;
        handleError(e, retryCallback: retryCallback);
      }
    });
  }

  /// A utility method that wraps Firebase operations with error handling
  static Future<T> executeWithErrorHandling<T>(Future<T> Function() operation,
      {Function? retryCallback}) async {
    try {
      return await operation();
    } catch (e) {
      handleError(e, retryCallback: retryCallback);
      rethrow; // Rethrow to allow the caller to handle the error as well
    }
  }

  /// Clean up resources
  static void dispose() {
    _firebaseNetworkStreamController.close();
  }
}
