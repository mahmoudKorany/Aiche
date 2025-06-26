import 'dart:io';
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
import 'firebase_options.dart';
import 'my_app.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase is already initialized in main, so we don't need to initialize it again
  // await Firebase.initializeApp(); // Remove this line

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

  // Initialize Firebase Messaging Service with network connectivity handling
  try {
    await FirebaseMessagingService.instance.init();
  } catch (e) {
    if (kDebugMode) {
      print('Firebase Messaging initialization error: $e');
    }
  }
  int? noOfRequest = await CacheHelper.getData(key: 'noOfRequest');
  if (noOfRequest == null) {
    await CacheHelper.saveData(key: 'noOfRequest', value: 0);
    noOfRequest = 0;
  }

  if (noOfRequest == 0 || noOfRequest > 10) {
    AwesomeNotifications().requestPermissionToSendNotifications();
  }
  noOfRequest = noOfRequest + 1;

  await CacheHelper.saveData(key: 'noOfRequest', value: noOfRequest);

  String? fcmToken;
  try {
    fcmToken = await FirebaseMessaging.instance.getToken();
    if (kDebugMode) {
      print("FCM Token: $fcmToken");
    }
  } catch (e) {
    if (kDebugMode) {
      print("Could not get FCM token: $e");
    }
    // Continue with login even if we can't get FCM token
  }
  try {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelGroupKey: 'basic_channel_group',
          channelKey: 'basic_channel',
          channelName: 'Basic notifications',
          channelDescription: 'Notification channel for basic tests',
        )
      ],
      channelGroups: [
        NotificationChannelGroup(
            channelGroupKey: 'basic_channel_group',
            channelGroupName: 'Basic group')
      ],
    );
  } catch (e) {
    if (kDebugMode) {
      print('AwesomeNotifications Error: $e');
    }
  }
  if (Platform.isAndroid) {
    FirebaseMessaging.onMessage.listen((message) async {
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
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) async {
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
    });
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }
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
