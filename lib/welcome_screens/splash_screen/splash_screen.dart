import 'package:aiche/auth/auth_cubit/auth_cubit.dart';
import 'package:aiche/auth/auth_cubit/auth_state.dart';
import 'package:aiche/core/network/internet_connection_cubit/internet_connection_states.dart';
import 'package:aiche/core/shared/components/gaps.dart';
import 'package:aiche/core/shared/functions/functions.dart';
import 'package:aiche/main.dart';
import 'package:aiche/main/blogs/blogs_cubit/blogs_cubit.dart';
import 'package:aiche/main/shop/shop_cubit/shop_cubit.dart';
import 'package:aiche/main/shop/shop_cubit/shop_state.dart';
import 'package:aiche/main/tasks/tasks_cubit/tasks_cubit.dart';
import 'package:aiche/main/tasks/tasks_cubit/tasks_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/network/internet_connection_cubit/internet_connection_cubit.dart';
import '../../core/shared/components/components.dart';
import '../../main/events/events_cubit/events_cubit.dart';
import '../../main/events/events_cubit/events_state.dart';
import '../../main/home/home_cubit/layout_cubit.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _navigateToHome();
  }

  void _initAnimations() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutBack,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.forward();
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(milliseconds: 2000));
    if (mounted) {
      navigateAndFinish(context: context, widget: startScreen!);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {},
      builder: (context, state) {
        return BlocConsumer<TasksCubit, TasksState>(
          listener: (context, state) {},
          builder: (context, state) {
            return BlocConsumer<BlogsCubit, BlogsState>(
              listener: (context, state) {},
              builder: (context, state) {
                return BlocConsumer<EventsCubit, EventsState>(
                  listener: (context, state) {},
                  builder: (context, state) {
                    return BlocConsumer<ShopCubit, ShopState>(
                      listener: (context, state) {},
                      builder: (context, state) {
                        return BlocConsumer<InternetCubit, InternetState>(
                          listener: (context, state) {},
                          builder: (context, state) {
                            return BlocConsumer<LayoutCubit, LayoutState>(
                              listener: (context, state) {},
                              builder: (context, state) {
                                return Scaffold(
                                  body: AnnotatedRegion<SystemUiOverlayStyle>(
                                    value: SystemUiOverlayStyle.light,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        const BackGround(),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 24.w),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment
                                                .center,
                                            children: [
                                              ScaleTransition(
                                                scale: _scaleAnimation,
                                                child: Image.asset(
                                                  'assets/images/onboarding_2.png',
                                                  height: 150.h,
                                                ),
                                              ),
                                              const Gap30(),
                                              SlideTransition(
                                                position: _slideAnimation,
                                                child: FadeTransition(
                                                  opacity: _fadeAnimation,
                                                  child: Text(
                                                    'AIChE Suez',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 32.sp,
                                                      fontWeight: FontWeight
                                                          .bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const Gap10(),
                                              SlideTransition(
                                                position: _slideAnimation,
                                                child: FadeTransition(
                                                  opacity: _fadeAnimation,
                                                  child: Text(
                                                    'American Institute of Chemical Engineers',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 14.sp,
                                                      color: Colors.white
                                                          .withOpacity(
                                                          0.8),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const Gap40(),
                                              SpinKitThreeBounce(
                                                color: Colors.white,
                                                size: 30.sp,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
