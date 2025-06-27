import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';

class NotificationController {
  static bool _listenersInitialized = false;
  static dynamic _tasksCubit; // Store reference to TasksCubit

  /// Set the TasksCubit instance for handling notification actions
  static void setTasksCubit(dynamic tasksCubit) {
    _tasksCubit = tasksCubit;
    if (kDebugMode) {
      print('TasksCubit instance set in NotificationController');
    }
  }

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
      print('Channel key: ${receivedAction.channelKey}');
      print('Notification ID: ${receivedAction.id}');
    }

    // Handle task notification actions
    if (receivedAction.channelKey == 'task_channel') {
      final String? actionKey = receivedAction.buttonKeyPressed;
      final int notificationId = receivedAction.id!;

      if (actionKey != null && _tasksCubit != null) {
        try {
          if (kDebugMode) {
            print(
                'Attempting to handle task notification action: $actionKey for notification: $notificationId');
          }

          // Handle actions through TasksCubit
          await _tasksCubit.handleNotificationAction(actionKey, notificationId);

          if (kDebugMode) {
            print('Successfully handled notification action: $actionKey');
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error handling notification action: $e');
          }
        }
      } else if (_tasksCubit == null) {
        if (kDebugMode) {
          print('TasksCubit not available for handling notification action');
        }
      }
    }
  }

  @pragma('vm:entry-point')
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    if (kDebugMode) {
      print('Notification created: ${receivedNotification.channelKey}');
      print('Notification ID: ${receivedNotification.id}');
      print('Title: ${receivedNotification.title}');
    }
  }

  @pragma('vm:entry-point')
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    if (kDebugMode) {
      print('Notification displayed: ${receivedNotification.channelKey}');
      print('Notification ID: ${receivedNotification.id}');
      print('Title: ${receivedNotification.title}');
    }
  }

  @pragma('vm:entry-point')
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {
    if (kDebugMode) {
      print('Notification dismissed: ${receivedAction.channelKey}');
      print('Notification ID: ${receivedAction.id}');
    }
  }
}
