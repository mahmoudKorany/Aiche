import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class NotificationTestHelper {
  /// Test the task notification system by creating a test notification
  static Future<void> testTaskAlarm() async {
    try {
      // Create a test notification that will trigger in 10 seconds
      final DateTime testTime = DateTime.now().add(const Duration(seconds: 10));
      final int testId =
          DateTime.now().millisecondsSinceEpoch.remainder(100000);

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: testId,
          channelKey: 'task_channel',
          title: '🚨 TEST ALARM: Task Reminder',
          body:
              '📱 This is a test alarm notification to verify the sound and vibration work properly',
          notificationLayout: NotificationLayout.BigText,
          category: NotificationCategory.Alarm,
          wakeUpScreen: true,
          fullScreenIntent: true,
          criticalAlert: true,
          autoDismissible: false,
          actionType: ActionType.Default,
          backgroundColor: const Color(0xFF111347),
          displayOnForeground: true,
          displayOnBackground: true,
          ticker: 'Test alarm notification',
        ),
        actionButtons: [
          NotificationActionButton(
            key: 'DISMISS_TEST',
            label: 'Dismiss Test',
            actionType: ActionType.DismissAction,
            autoDismissible: true,
            color: Colors.red,
          ),
          NotificationActionButton(
            key: 'TEST_SNOOZE',
            label: 'Test Snooze',
            actionType: ActionType.SilentAction,
            autoDismissible: true,
            color: Colors.orange,
          ),
        ],
        schedule: NotificationCalendar.fromDate(date: testTime),
      );

      if (kDebugMode) {
        print('Test alarm scheduled for: $testTime');
        print('Test notification ID: $testId');
        print(
            'The alarm should trigger in 10 seconds with maximum volume and vibration');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to create test notification: $e');
      }
    }
  }

  /// Test immediate notification to verify channel setup
  static Future<void> testImmediateNotification() async {
    try {
      final int testId =
          DateTime.now().millisecondsSinceEpoch.remainder(100000);

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: testId,
          channelKey: 'task_channel',
          title: '✅ Notification Test',
          body:
              'If you see this notification, the task channel is configured correctly!',
          notificationLayout: NotificationLayout.Default,
          category: NotificationCategory.Message,
          wakeUpScreen: true,
          criticalAlert: true,
          displayOnForeground: true,
          displayOnBackground: true,
        ),
      );

      if (kDebugMode) {
        print('Immediate test notification created with ID: $testId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to create immediate test notification: $e');
      }
    }
  }

  /// Check notification permissions and channel status
  static Future<void> checkNotificationStatus() async {
    try {
      // Check if notifications are allowed
      final bool isAllowed =
          await AwesomeNotifications().isNotificationAllowed();

      if (kDebugMode) {
        print(
            'Notification permission status: ${isAllowed ? "GRANTED" : "DENIED"}');
      }

      if (!isAllowed) {
        if (kDebugMode) {
          print('Requesting notification permission...');
        }
        final bool permissionGranted =
            await AwesomeNotifications().requestPermissionToSendNotifications();
        if (kDebugMode) {
          print(
              'Permission request result: ${permissionGranted ? "GRANTED" : "DENIED"}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking notification status: $e');
      }
    }
  }
}
