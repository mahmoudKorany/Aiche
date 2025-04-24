import 'dart:async';
import 'dart:io';
import 'package:aiche/core/services/network_connectivity_service.dart';
import 'package:aiche/core/utils/firebase_error_handler.dart';
import 'package:aiche/core/utils/notification_utils.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FirebaseMessagingService {
  static FirebaseMessagingService? _instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final NetworkConnectivityService _connectivityService =
      NetworkConnectivityService.instance;

  // Flag to track if initialization has been completed
  bool _isInitialized = false;

  // Auto-retry mechanism
  Timer? _retryTimer;
  int _retryAttempts = 0;
  static const int _maxRetryAttempts = 5;
  static const Duration _retryInterval = Duration(seconds: 30);

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

  FirebaseMessagingService._();

  Future<void> init() async {
    // Initialize network connectivity service first
    await _connectivityService.init();

    // Subscribe to network status changes to retry initialization when network is restored
    _connectivityService.connectionStatus.listen((isConnected) {
      if (isConnected && !_isInitialized) {
        _retryAttempts = 0; // Reset retry attempts
        _initializeFirebaseMessaging();
      }
    });

    // Also listen to Firebase-specific network issues
    FirebaseErrorHandler.firebaseNetworkStream.listen((isConnected) {
      if (isConnected && !_isInitialized) {
        _initializeFirebaseMessaging();
      }
    });

    // Initial attempt to initialize
    if (await _connectivityService.checkNetwork()) {
      await _initializeFirebaseMessaging();
    } else {
      // debugPrint(
      //     'Network not available. Firebase Messaging initialization deferred.');
      _scheduleRetry();
    }
  }

  Future<void> _initializeFirebaseMessaging() async {
    if (_isInitialized) return;

    try {
      // Use our new error handler for the initialization process
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
        retryCallback: _initializeFirebaseMessaging,
      );

      _isInitialized = true;
      _cancelRetryTimer();
    //  debugPrint('Firebase Messaging service initialized successfully');
    } catch (e) {
      // If the error was already handled by FirebaseErrorHandler, we don't need to do anything else
      // debugPrint(
      //     'Error during Firebase Messaging initialization (handled by FirebaseErrorHandler)');
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
    // Initialize Awesome Notifications
    await AwesomeNotifications().initialize(
      // Set the icon to null to use the default app icon
      'resource://drawable/app_icon',
      [
        NotificationChannel(
          channelKey: 'high_importance_channel',
          channelName: 'High Importance Notifications',
          channelDescription:
              'This channel is used for important notifications.',
          defaultColor: const Color(0xFF9D50DD),
          ledColor: const Color(0xFF9D50DD),
          importance: NotificationImportance.High,
          channelShowBadge: true,
        )
      ],
    );

    // Request notification permissions
    await AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });

    // Set up action event listeners
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: FirebaseMessagingService.onActionReceivedMethod,
      onNotificationCreatedMethod:
          FirebaseMessagingService.onNotificationCreatedMethod,
      onNotificationDisplayedMethod:
          FirebaseMessagingService.onNotificationDisplayedMethod,
      onDismissActionReceivedMethod:
          FirebaseMessagingService.onDismissActionReceivedMethod,
    );
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
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

 // debugPrint("Handling a background message: ${message.messageId}");
}
