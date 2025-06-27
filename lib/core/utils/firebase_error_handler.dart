import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// A utility class to handle Firebase-related errors with special focus on
/// network connection errors and FCM service availability.
class FirebaseErrorHandler {
  /// Stream controller for broadcasting network status specifically for Firebase operations
  static final StreamController<bool> _firebaseNetworkStreamController =
      StreamController<bool>.broadcast();

  /// Stream that can be listened to for Firebase network status changes
  static Stream<bool> get firebaseNetworkStream =>
      _firebaseNetworkStreamController.stream;

  /// Last known error
  static dynamic _lastError;
  static dynamic get lastError => _lastError;

  /// Flag to indicate whether a network retry is in progress
  static bool _isRetryInProgress = false;
  static bool get isRetryInProgress => _isRetryInProgress;

  /// Flag to track if we've already logged FCM service unavailable message
  static bool _fcmUnavailableLogged = false;

  /// Handle Firebase exceptions with special attention to network issues and FCM service availability
  static void handleError(Object error, {Function? retryCallback}) {
    bool isNetworkError = false;
    bool isServiceUnavailable = false;
    String errorMessage = error.toString();

    _lastError = error;

    if (error is FirebaseException) {
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

    // Check for FCM service availability issues (common in debug mode)
    if (errorMessage.contains('SERVICE_NOT_AVAILABLE') ||
        errorMessage.contains('java.io.IOException') ||
        errorMessage.contains('ExecutionException') ||
        errorMessage.contains('firebase_messaging/unknown')) {
      isServiceUnavailable = true;

      // Only log once to avoid spam
      if (!_fcmUnavailableLogged && kDebugMode) {
        print(
            'FCM service not available - this is common in debug mode/emulators');
        print('The app will continue to function without cloud messaging');
        _fcmUnavailableLogged = true;
      }
    }

    // Log appropriate message based on error type (avoid duplicate service unavailable logs)
    if (isServiceUnavailable && !_fcmUnavailableLogged) {
      if (kDebugMode) {
        print('FCM service unavailable: $errorMessage');
      }
      // Don't retry for service unavailable errors as they're environmental
      return;
    } else if (isNetworkError && !isServiceUnavailable) {
      if (kDebugMode) {
        print('Firebase network error: $errorMessage');
      }
    } else if (!isServiceUnavailable) {
      if (kDebugMode) {
        print('Firebase error: $errorMessage');
      }
    }

    // If it's a network error (but not service unavailable), notify listeners and retry
    if (isNetworkError && !isServiceUnavailable) {
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

  /// Check if an error is recoverable (network issues) vs non-recoverable (service unavailable)
  static bool isRecoverableError(Object error) {
    String errorMessage = error.toString();

    // Service unavailable errors are not recoverable in the current session
    if (errorMessage.contains('SERVICE_NOT_AVAILABLE') ||
        errorMessage.contains('java.io.IOException') ||
        errorMessage.contains('ExecutionException')) {
      return false;
    }

    // Network errors are typically recoverable
    if (errorMessage.contains('network') ||
        errorMessage.contains('connection') ||
        errorMessage.contains('timeout')) {
      return true;
    }

    return false;
  }

  /// Clean up resources
  static void dispose() {
    _firebaseNetworkStreamController.close();
  }
}
