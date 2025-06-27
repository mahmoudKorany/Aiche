import 'dart:async';
import 'dart:io';
import 'package:aiche/core/services/network_connectivity_service.dart';
import 'package:aiche/core/utils/firebase_error_handler.dart';
import 'package:aiche/core/utils/notification_utils.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FirebaseMessagingService {
  static FirebaseMessagingService? _instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final NetworkConnectivityService _connectivityService =
      NetworkConnectivityService.instance;

  // Flag to track if initialization has been completed
  bool _isInitialized = false;
  bool _isInitializing = false;

  // Auto-retry mechanism
  Timer? _retryTimer;
  int _retryAttempts = 0;
  static const int _maxRetryAttempts = 3; // Reduced retry attempts
  static const Duration _retryInterval =
      Duration(seconds: 10); // Reduced interval

  // Stream controller for handling notification clicks
  final StreamController<RemoteMessage> _onMessageOpenedAppController =
      StreamController<RemoteMessage>.broadcast();
  Stream<RemoteMessage> get onMessageOpenedApp =>
      _onMessageOpenedAppController.stream;

  // Singleton pattern
  static FirebaseMessagingService get instance {
    _instance ??= FirebaseMessagingService._();
    return _instance!;
  }

  FirebaseMessagingService._() {
    // Set up listeners in constructor to avoid duplicate listeners
    _setupConnectionListeners();
  }

  void _setupConnectionListeners() {
    // Subscribe to network status changes to retry initialization when network is restored
    _connectivityService.connectionStatus.listen((isConnected) {
      if (isConnected && !_isInitialized && !_isInitializing) {
        _retryAttempts = 0; // Reset retry attempts
        _initializeFirebaseMessaging();
      }
    });

    // Also listen to Firebase-specific network issues
    FirebaseErrorHandler.firebaseNetworkStream.listen((isConnected) {
      if (isConnected && !_isInitialized && !_isInitializing) {
        _initializeFirebaseMessaging();
      }
    });
  }

  Future<void> init() async {
    // Prevent multiple initialization attempts
    if (_isInitialized || _isInitializing) {
      if (kDebugMode) {
        print(
            'Firebase Messaging Service already initialized or initializing...');
      }
      return;
    }

    _isInitializing = true;

    try {
      // Initialize network connectivity service first
      await _connectivityService.init();

      // Check if we already have network connectivity
      if (await _connectivityService.checkNetwork()) {
        await _initializeFirebaseMessaging();
      } else {
        if (kDebugMode) {
          print(
              'Network not available. Firebase Messaging initialization deferred.');
        }
      }
    } catch (e) {
      // Check if this is a SERVICE_NOT_AVAILABLE error (common in debug mode)
      if (e.toString().contains('SERVICE_NOT_AVAILABLE') ||
          e.toString().contains('java.io.IOException')) {
        if (kDebugMode) {
          print(
              'FCM service not available - continuing without cloud messaging');
          print('This is normal in debug mode or on emulators');
        }
        // Mark as initialized to prevent further retry attempts
        _isInitialized = true;
      } else {
        if (kDebugMode) {
          print('Firebase Messaging Service init error (non-critical): $e');
        }
      }
      // Don't throw the error - allow app to continue without FCM
    } finally {
      _isInitializing = false;
    }
  }

  Future<void> _initializeFirebaseMessaging() async {
    if (_isInitialized || _isInitializing) return;

    _isInitializing = true;

    try {
      // Check for FCM service availability first (common issue in debug mode)
      try {
        await _firebaseMessaging.getToken().timeout(const Duration(seconds: 3));
      } catch (e) {
        if (e.toString().contains('SERVICE_NOT_AVAILABLE') ||
            e.toString().contains('java.io.IOException')) {
          if (kDebugMode) {
            print(
                'FCM service not available - continuing without cloud messaging');
          }
          _isInitialized = true; // Mark as initialized to prevent retries
          return;
        }
        // For other errors, continue with normal error handling
        rethrow;
      }

      // Use our error handler for the initialization process
      await FirebaseErrorHandler.executeWithErrorHandling(
        () async {
          // Request permission for iOS
          if (Platform.isIOS) {
            await _firebaseMessaging.requestPermission(
              alert: true,
              badge: true,
              sound: true,
            );
          }

          // Configure local notifications using Awesome Notifications
          await _configureAwesomeNotifications();

          // Get the FCM token with error handling
          await _getFCMToken();

          // Configure FCM message handlers
          FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
          FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
          FirebaseMessaging.onBackgroundMessage(
              _firebaseMessagingBackgroundHandler);

          // Handle initial notification when app is launched from terminated state
          RemoteMessage? initialMessage =
              await FirebaseMessaging.instance.getInitialMessage();
          if (initialMessage != null) {
            _handleMessageOpenedApp(initialMessage);
          }
        },
        retryCallback: null, // Disable retries for initialization
      );

      _isInitialized = true;
      _cancelRetryTimer();
      if (kDebugMode) {
        print('Firebase Messaging service initialized successfully');
      }
    } catch (e) {
      // Check if this is a service unavailable error
      if (FirebaseErrorHandler.isRecoverableError(e)) {
        // Only schedule retry for recoverable errors
        _scheduleRetry();
      } else {
        // For non-recoverable errors (like SERVICE_NOT_AVAILABLE), mark as initialized
        _isInitialized = true;
        if (kDebugMode) {
          print(
              'Firebase Messaging initialization skipped due to service unavailability');
        }
      }
    } finally {
      _isInitializing = false;
    }
  }

  Future<void> _getFCMToken() async {
    if (!await _connectivityService.checkNetwork()) {
      // debugPrint('Network not available. Cannot get FCM token.');
      return;
    }

    await FirebaseErrorHandler.executeWithErrorHandling(
      () async {
        String? token = await _firebaseMessaging.getToken();
        //debugPrint('FCM Token: $token');
        return token;
      },
      retryCallback: _getFCMToken,
    );
  }

  void _scheduleRetry() {
    // Cancel any existing retry timer
    _cancelRetryTimer();

    if (_retryAttempts < _maxRetryAttempts) {
      _retryAttempts++;
      // debugPrint(
      //     'Scheduling retry attempt $_retryAttempts of $_maxRetryAttempts in ${_retryInterval.inSeconds} seconds');

      _retryTimer = Timer(_retryInterval, () async {
        if (await _connectivityService.checkNetwork()) {
          // debugPrint('Retrying Firebase Messaging initialization');
          _initializeFirebaseMessaging();
        } else {
          // debugPrint('Network still not available, rescheduling retry');
          _scheduleRetry();
        }
      });
    } else {
      // debugPrint('Maximum retry attempts reached. User action required.');
      // Here you might want to show a UI notification to the user
    }
  }

  void _cancelRetryTimer() {
    _retryTimer?.cancel();
    _retryTimer = null;
  }

  Future<void> _configureAwesomeNotifications() async {
    // Don't initialize AwesomeNotifications here since it's already done in main.dart
    // Just request permissions if needed
    await AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });

    // Note: Listeners are now set up in NotificationController to avoid conflicts
  }

  // Required static methods for awesome_notifications
  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    // debugPrint(
    //     'Notification action received: ${receivedAction.toMap().toString()}');
    // Add your code here
  }

  @pragma('vm:entry-point')
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    // debugPrint(
    //     'Notification created: ${receivedNotification.toMap().toString()}');
  }

  @pragma('vm:entry-point')
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    // debugPrint(
    //     'Notification displayed: ${receivedNotification.toMap().toString()}');
  }

  @pragma('vm:entry-point')
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {
    //debugPrint('Notification dismissed: ${receivedAction.toMap().toString()}');
  }

  void _handleForegroundMessage(RemoteMessage message) {
    // debugPrint('Got a message whilst in the foreground!');
    // debugPrint('Message data: ${message.data}');

    if (message.notification != null) {
      // debugPrint(
      //     'Message also contained a notification: ${message.notification}');
      _showAwesomeNotification(message);

      // Show a toast for the notification
      if (message.notification?.title != null &&
          message.notification?.body != null) {
        NotificationUtils.showNotificationToast(
          title: message.notification!.title!,
          body: message.notification!.body!,
        );
      }
    }
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    // debugPrint('A notification message was tapped!');
    // debugPrint('Message data: ${message.data}');

    if (message.notification != null) {
      // debugPrint(
      //     'Message also contained a notification: ${message.notification}');
    }

    _onMessageOpenedAppController.add(message);
  }

  Future<void> _showAwesomeNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;

    if (notification != null && !kIsWeb) {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: notification.hashCode,
          channelKey: 'high_importance_channel',
          title: notification.title,
          body: notification.body,
          notificationLayout: NotificationLayout.Default,
          payload: Map<String, String?>.from(
            message.data.map((key, value) => MapEntry(key, value?.toString())),
          ),
        ),
      );
    }
  }

  // Attempt to re-fetch the FCM token - can be called when the user requests a refresh
  Future<String?> refreshToken() async {
    if (!await _connectivityService.checkNetwork()) {
      // debugPrint('Network not available. Cannot refresh FCM token.');
      return null;
    }

    try {
      return await FirebaseErrorHandler.executeWithErrorHandling(
        () async {
          final token = await _firebaseMessaging.getToken();
          // debugPrint('FCM Token refreshed: $token');
          return token;
        },
        retryCallback: refreshToken,
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    if (!await _connectivityService.checkNetwork()) {
      // debugPrint('Network not available. Cannot subscribe to topic: $topic');
      return;
    }

    await FirebaseErrorHandler.executeWithErrorHandling(
      () => _firebaseMessaging.subscribeToTopic(topic),
      retryCallback: () => subscribeToTopic(topic),
    );
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    if (!await _connectivityService.checkNetwork()) {
      // debugPrint(
      //     'Network not available. Cannot unsubscribe from topic: $topic');
      return;
    }

    await FirebaseErrorHandler.executeWithErrorHandling(
      () => _firebaseMessaging.unsubscribeFromTopic(topic),
      retryCallback: () => unsubscribeFromTopic(topic),
    );
  }

  void dispose() {
    _cancelRetryTimer();
    _onMessageOpenedAppController.close();
  }
}

// This needs to be a top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase is already initialized in main, so we don't need to initialize it again
  // The Firebase.initializeApp() call is not needed here since Firebase is already initialized

  // debugPrint("Handling a background message: ${message.messageId}");
}
