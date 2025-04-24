import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;

  NotificationService._();

  Future<void> initialize() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelGroupKey: 'tasks_channel_group',
          channelKey: 'tasks_channel',
          channelName: 'Tasks notifications',
          channelDescription: 'Notification channel for task reminders',
          defaultColor: const Color(0xFF4587C9),
          ledColor: const Color(0xFF4587C9),
          importance: NotificationImportance.High,
        )
      ],
      channelGroups: [
        NotificationChannelGroup(
            channelGroupKey: 'tasks_channel_group', channelGroupName: 'Tasks')
      ],
    );
  }

  Future<bool> requestPermissions() async {
    return await AwesomeNotifications().requestPermissionToSendNotifications();
  }

  Future<int> scheduleTaskNotification(
      String title, String description, DateTime dueDate) async {
    final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    // Schedule notification 30 minutes before due date
    final scheduledDate = dueDate.subtract(const Duration(minutes: 30));

    if (scheduledDate.isAfter(DateTime.now())) {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: id,
          channelKey: 'tasks_channel',
          title: 'Task Reminder: $title',
          body: description,
          notificationLayout: NotificationLayout.Default,
          category: NotificationCategory.Reminder,
        ),
        schedule: NotificationCalendar.fromDate(date: scheduledDate),
      );
    }

    return id;
  }

  Future<void> cancelNotification(int id) async {
    await AwesomeNotifications().cancel(id);
  }
}
