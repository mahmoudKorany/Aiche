import 'package:aiche/auth/auth_cubit/auth_cubit.dart';
import 'package:aiche/core/shared/constants/constants.dart';
import 'package:aiche/main/blogs/blogs_cubit/blogs_cubit.dart';
import 'package:aiche/main/committee/cubit/committee_cubit.dart';
import 'package:aiche/main/events/events_cubit/events_cubit.dart';
import 'package:aiche/main/home/home_cubit/layout_cubit.dart';
import 'package:aiche/main/shop/shop_cubit/shop_cubit.dart';
import 'package:aiche/main/tasks/tasks_cubit/tasks_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/network/internet_connection_cubit/internet_connection_cubit.dart';
import 'welcome_screens/splash_screen/splash_screen.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => InternetCubit()..checkConnection(),
        ),
        BlocProvider(
          create: (context) => TasksCubit()..getTasks(),
        ),
        BlocProvider(
          create: (context) => ShopCubit()..getAllProducts()..getAllCollections(),
        ),
        BlocProvider(
          create: (context) => LayoutCubit()..getHomeBanner(),
        ),
        BlocProvider(
          create: (context) => EventsCubit()..fetchEvents(),
        ),
        BlocProvider(
          create: (context) => BlogsCubit()..getBlogs(),
        ),
        BlocProvider(
          create: (context) => AuthCubit()..getUserData(),
        ),
        BlocProvider(
          create: (context) => CommitteeCubit()..getCommitteeData(),
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return GestureDetector(
            onTap: () {
              //remove keyboard on touching anywhere on the screen.
              FocusScopeNode currentFocus = FocusScope.of(context);

              if (!currentFocus.hasPrimaryFocus) {
                currentFocus.unfocus();
                FocusManager.instance.primaryFocus?.unfocus();
              }
            },
            child: MaterialApp(
              title: 'aiche',
              theme: ThemeData(
                  useMaterial3: false,
                  disabledColor: Colors.black,
                  scaffoldBackgroundColor: Colors.white,
                  appBarTheme: const AppBarTheme(
                    backgroundColor: Colors.white,
                    elevation: 0.0,
                  )),
              debugShowCheckedModeBanner: false,
              builder: (context, child) {
                return MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: const TextScaler.linear(1.0)),
                  child: child!,
                );
              },
              home: const SplashScreen(),
            ),
          );
        },
      ),
    );
  }
}
