import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../services/firebase_messaging_service.dart';

class NotificationHelper {
  static final NotificationHelper _instance = NotificationHelper._internal();

  factory NotificationHelper() => _instance;

  NotificationHelper._internal();

  Future<void> initialize(BuildContext context) async {
    // Listen for notification taps when the app is in the foreground
    FirebaseMessagingService.instance.onMessageOpenedApp
        .listen((RemoteMessage message) {
      _handleNotificationTap(context, message);
    });
  }

  void _handleNotificationTap(BuildContext context, RemoteMessage message) {
    // Extract data from the notification
    final Map<String, dynamic> data = message.data;

    // Check if there's a specific screen to navigate to
    if (data.containsKey('screen')) {
      final String screenName = data['screen'];

      // Navigate based on the screen name
      switch (screenName) {
        case 'event_details':
          if (data.containsKey('eventId')) {
            final String eventId = data['eventId'];
            // Navigate to event details screen
            // Example: Navigator.pushNamed(context, '/events/details', arguments: eventId);
            debugPrint('Navigate to event details for ID: $eventId');
          }
          break;
        case 'blog_details':
          if (data.containsKey('blogId')) {
            final String blogId = data['blogId'];
            // Navigate to blog details screen
            // Example: Navigator.pushNamed(context, '/blogs/details', arguments: blogId);
            debugPrint('Navigate to blog details for ID: $blogId');
          }
          break;
        default:
          // Default navigation or show a generic message
          debugPrint('Notification tapped with unknown screen: $screenName');
      }
    }
  }

  // Subscribe to a topic (for example, to receive notifications for specific events or categories)
  Future<void> subscribeToTopic(String topic) async {
    await FirebaseMessagingService.instance.subscribeToTopic(topic);
    debugPrint('Subscribed to topic: $topic');
  }

  // Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await FirebaseMessagingService.instance.unsubscribeFromTopic(topic);
    debugPrint('Unsubscribed from topic: $topic');
  }
}
