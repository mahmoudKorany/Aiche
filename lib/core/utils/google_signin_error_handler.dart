import 'package:flutter/foundation.dart';

class GoogleSignInErrorHandler {
  static String getErrorMessage(dynamic error) {
    final String errorString = error.toString().toLowerCase();

    if (errorString.contains('network_error') ||
        errorString.contains('network error')) {
      return 'Please check your internet connection and try again.';
    }

    if (errorString.contains('sign_in_canceled') ||
        errorString.contains('cancelled')) {
      return 'Sign in was cancelled.';
    }

    if (errorString.contains('sign_in_failed')) {
      return 'Google Sign-In failed. Please try again.';
    }

    if (errorString.contains('timeout')) {
      return 'Sign in timed out. Please try again.';
    }

    if (errorString.contains('developer_error')) {
      return 'Configuration error. Please contact support.';
    }

    if (errorString.contains('invalid_account')) {
      return 'Invalid Google account. Please try with a different account.';
    }

    // Log the original error for debugging in debug mode
    if (kDebugMode) {
      print('Google Sign-In Error: $error');
    }

    return 'Google Sign-In failed. Please try again.';
  }

  static bool isRetryableError(dynamic error) {
    final String errorString = error.toString().toLowerCase();

    return errorString.contains('network_error') ||
        errorString.contains('timeout') ||
        errorString.contains('temporary');
  }
}
