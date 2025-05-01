import 'package:aiche/auth/auth_screens/login_screen.dart';
import 'package:aiche/core/services/firebase_messaging_service.dart';
import 'package:aiche/core/shared/constants/constants.dart';
import 'package:aiche/main/home/home_screen/home_layout_screen.dart';
import 'package:aiche/welcome_screens/onboarding_screen/onboarding.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/services/dio/dio.dart';
import 'core/utils/cache-helper/cache-helper.dart';
import 'my_app.dart';

Widget? startScreen;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    if (kDebugMode) {
      // print('Firebase initialization error: $e');
    }
  }

  await CacheHelper.init();
  await DioHelper.init();

  // Initialize Firebase Messaging Service with network connectivity handling
  try {
    await FirebaseMessagingService.instance.init();
  } catch (e) {
    if (kDebugMode) {
      // print('Firebase Messaging initialization error: $e');
    }
  }

  // Initialize Awesome Notifications
  AwesomeNotifications().requestPermissionToSendNotifications();
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
          channelDescription: 'Notifications for task deadlines and reminders',
          defaultColor: Colors.blue,
          importance: NotificationImportance.High,
          defaultRingtoneType: DefaultRingtoneType.Alarm,
        )
      ],
      channelGroups: [
        NotificationChannelGroup(
            channelGroupKey: 'basic_channel_group',
            channelGroupName: 'Basic group'),
        NotificationChannelGroup(
            channelGroupKey: 'task_channel_group',
            channelGroupName: 'Task Reminders')
      ],
    );
  } catch (e) {
    if (kDebugMode) {
      print('AwesomeNotifications Error: $e');
    }
  }

  // var fcmToken = await  FirebaseMessaging.instance.getToken();
  // if (kDebugMode) {
  //   print('FCM Token: ${fcmToken.toString()}');
  // }
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
