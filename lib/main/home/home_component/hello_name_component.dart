import 'package:aiche/auth/auth_cubit/auth_cubit.dart';
import 'package:aiche/auth/auth_cubit/auth_state.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../auth/profile/profile_screen.dart';
import '../../../core/shared/components/gaps.dart';
import '../../../core/shared/functions/functions.dart';
import 'drawer_icon.dart';

class HelloNameComponent extends StatefulWidget {
  const HelloNameComponent({super.key});

  @override
  State<HelloNameComponent> createState() => _HelloNameComponentState();
}

class _HelloNameComponentState extends State<HelloNameComponent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _iconRotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-0.5, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutQuint,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _iconRotateAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 1.0, curve: Curves.elasticOut),
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 18) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  IconData _getGreetingIcon() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return Icons.wb_sunny_outlined; // Morning - sun icon
    } else if (hour < 18) {
      return Icons.wb_sunny; // Afternoon - full sun icon
    } else {
      return Icons.nightlight_round; // Evening - moon icon
    }
  }

  Color _getIconColor() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return Colors.amber.shade300; // Morning - light yellow
    } else if (hour < 18) {
      return Colors.orange.shade400; // Afternoon - orange
    } else {
      return Colors.indigo.shade300; // Evening - indigo blue
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {},
      builder: (context, state) {
        final userName = AuthCubit.get(context).userModel?.name ?? '';
        final greeting = _getGreeting();
        final greetingIcon = _getGreetingIcon();
        final iconColor = _getIconColor();
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.black.withOpacity(0.1),
                Colors.transparent,
              ],
            ),
            borderRadius: BorderRadius.circular(16.r),
          ),
          // margin: EdgeInsets.symmetric(vertical: 4.h),
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const DrawerIcon(),
                    const Gap10(isHorizontal: true),
                    RotationTransition(
                      turns: _iconRotateAnimation,
                      child: Icon(
                        greetingIcon,
                        color: iconColor,
                        size: 22.sp,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            greeting,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.8),
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            userName,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white.withOpacity(0.95),
                              letterSpacing: 0.5,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      height: 42.h,
                      width: 42.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.9),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(50),
                          onTap: () {
                            navigateTo(
                                context: context, widget: ProfileScreen());
                          },
                          child: ClipOval(
                            child: AuthCubit.get(context)
                                            .userModel
                                            ?.imageUrl ==
                                        null ||
                                    AuthCubit.get(context)
                                            .userModel
                                            ?.imageUrl ==
                                        ''
                                ? Image.asset(
                                    'assets/images/person.png',
                                    fit: BoxFit.cover,
                                  )
                                : CachedNetworkImage(
                                    imageUrl: AuthCubit.get(context)
                                        .userModel!
                                        .imageUrl!,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      color: Colors.grey[300],
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Icon(
                                      Icons.person,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}