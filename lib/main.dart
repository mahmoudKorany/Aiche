import 'package:aiche/auth/auth_screens/login_screen.dart';
import 'package:aiche/core/services/firebase_messaging_service.dart';
import 'package:aiche/core/shared/constants/constants.dart';
import 'package:aiche/main/home/home_screen/home_layout_screen.dart';
import 'package:aiche/welcome_screens/onboarding_screen/onboarding.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/services/dio/dio.dart';
import 'core/utils/cache-helper/cache-helper.dart';
import 'core/controllers/notification_controller.dart';
import 'firebase_options.dart';
import 'my_app.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print('Handling a background message ${message.messageId}');
  }
  AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: 1,
      channelKey: "basic_channel",
      title: message.notification?.title ?? '',
      body: message.notification?.body ?? '',
    ),
  );
}

Widget? startScreen;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase first - with duplicate check
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // If Firebase is already initialized, this will catch the duplicate app error
    if (e.toString().contains('duplicate-app')) {
      if (kDebugMode) {
        print('Firebase already initialized, continuing...');
      }
    } else {
      // Re-throw if it's a different error
      if (kDebugMode) {
        print('Firebase initialization error: $e');
      }
      rethrow;
    }
  }

  await CacheHelper.init();
  await DioHelper.init();

  // Initialize AwesomeNotifications BEFORE Firebase Messaging to avoid conflicts
  try {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelGroupKey: 'basic_channel_group',
          channelKey: 'basic_channel',
          channelName: 'Basic notifications',
          channelDescription: 'Notification channel for basic tests',
        ),
        NotificationChannel(
          channelGroupKey: 'task_channel_group',
          channelKey: 'task_channel',
          channelName: 'Task Reminders',
          channelDescription: 'High priority notifications for task reminders',
          importance: NotificationImportance.Max,
          defaultColor: const Color(0xFF111347),
          ledColor: const Color(0xFF111347),
          enableVibration: true,
          enableLights: true,
          criticalAlerts: true,
          channelShowBadge: true,
          onlyAlertOnce: false,
          defaultRingtoneType: DefaultRingtoneType.Alarm,
          // Enhanced settings for background notifications
          playSound: true,
          soundSource: null, // Use system default alarm sound
          locked: false,
        )
      ],
      channelGroups: [
        NotificationChannelGroup(
            channelGroupKey: 'basic_channel_group',
            channelGroupName: 'Basic group'),
        NotificationChannelGroup(
            channelGroupKey: 'task_channel_group',
            channelGroupName: 'Task Reminders'),
      ],
      debug: kDebugMode,
    );

    // Initialize notification listeners using our controller to prevent redefinition
    await NotificationController.initializeListeners();
  } catch (e) {
    if (kDebugMode) {
      print('AwesomeNotifications Error: $e');
    }
  }

  // Request notification permissions
  int? noOfRequest = await CacheHelper.getData(key: 'noOfRequest');
  if (noOfRequest == null) {
    await CacheHelper.saveData(key: 'noOfRequest', value: 0);
    noOfRequest = 0;
  }

  if (noOfRequest == 0 || noOfRequest > 10) {
    try {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    } catch (e) {
      if (kDebugMode) {
        print('Permission request error: $e');
      }
    }
  }
  noOfRequest = noOfRequest + 1;
  await CacheHelper.saveData(key: 'noOfRequest', value: noOfRequest);

  // Initialize Firebase Messaging Service AFTER AwesomeNotifications
  try {
    await FirebaseMessagingService.instance.init();
  } catch (e) {
    if (kDebugMode) {
      print('Firebase Messaging initialization error: $e');
    }
  }

  // Get FCM token with better error handling - make it completely optional
  String? fcmToken;
  try {
    // Add timeout to prevent hanging
    fcmToken = await FirebaseMessaging.instance.getToken().timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        if (kDebugMode) {
          print("FCM token request timed out - continuing without FCM");
        }
        return null;
      },
    );
    if (kDebugMode && fcmToken != null) {
      print("FCM Token: $fcmToken");
    }
  } catch (e) {
    if (kDebugMode) {
      print(
          "FCM service not available - continuing without cloud messaging: $e");
    }
    // Continue with app initialization - local task notifications will still work
  }

  // Note: Firebase messaging listeners are now handled in FirebaseMessagingService
  // to avoid duplicate setListeners calls

  token = await CacheHelper.getData(key: 'token');
  bool? onBoarding = await CacheHelper.getData(key: 'onBoarding');

  //print('Token: $token');
  if (token == null && onBoarding == null) {
    startScreen = const Onboarding();
  } else if (token == null && onBoarding == true) {
    startScreen = const LoginScreen();
  } else {
    startScreen = const HomeLayoutScreen();
  }
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.dark,
    ),
  );
  runApp(const MyApp());
}
