import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';

class NotificationController {
  static bool _listenersInitialized = false;

  /// Initialize notification listeners only once
  static Future<void> initializeListeners() async {
    if (_listenersInitialized) return;

    try {
      await AwesomeNotifications().setListeners(
        onActionReceivedMethod: NotificationController.onActionReceivedMethod,
        onNotificationCreatedMethod:
            NotificationController.onNotificationCreatedMethod,
        onNotificationDisplayedMethod:
            NotificationController.onNotificationDisplayedMethod,
        onDismissActionReceivedMethod:
            NotificationController.onDismissActionReceivedMethod,
      );
      _listenersInitialized = true;
      if (kDebugMode) {
        print('Notification listeners initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing notification listeners: $e');
      }
    }
  }

  /// Handle notification actions (like marking task complete or snoozing)
  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    if (kDebugMode) {
      print('Notification action received: ${receivedAction.actionType}');
      print('Action key: ${receivedAction.buttonKeyPressed}');
    }

    // Handle task notification actions
    if (receivedAction.channelKey == 'task_channel') {
      final String? actionKey = receivedAction.buttonKeyPressed;
      final int notificationId = receivedAction.id!;

      if (actionKey != null) {
        // TODO: Implement task action handling
        // This would need to communicate with your TasksCubit
        // For now, we'll just log the actions
        switch (actionKey) {
          case 'MARK_DONE':
            if (kDebugMode) {
              print(
                  'Mark task complete requested for notification: $notificationId');
            }
            break;
          case 'SNOOZE':
            if (kDebugMode) {
              print('Snooze task requested for notification: $notificationId');
            }
            break;
        }
      }
    }
  }

  @pragma('vm:entry-point')
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    if (kDebugMode) {
      print('Notification created: ${receivedNotification.channelKey}');
    }
  }

  @pragma('vm:entry-point')
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    if (kDebugMode) {
      print('Notification displayed: ${receivedNotification.channelKey}');
    }
  }

  @pragma('vm:entry-point')
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {
    if (kDebugMode) {
      print('Notification dismissed: ${receivedAction.channelKey}');
    }
  }
}
