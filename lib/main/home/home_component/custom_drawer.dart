import 'dart:io';
import 'package:aiche/auth/auth_cubit/auth_cubit.dart';
import 'package:aiche/auth/auth_cubit/auth_state.dart';
import 'package:aiche/auth/profile/profile_screen.dart';
import 'package:aiche/core/shared/components/gaps.dart';
import 'package:aiche/core/shared/functions/functions.dart';
import 'package:aiche/main/material/material_screen.dart';
import 'package:aiche/main/sessions/sessions_screem.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_indicator/loading_indicator.dart';

import '../home_cubit/layout_cubit.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});
  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state1) {},
      builder: (context, state1) {
        return Drawer(
          backgroundColor: const Color(0xff0C0341),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                const Gap60(),
                _buildHeader(),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      _buildMainMenuSection(),
                      Divider(
                          color: Colors.white24,
                          thickness: 1,
                          indent: 16.w,
                          endIndent: 16.w),
                      _buildResourcesSection(),
                      Divider(
                          color: Colors.white24,
                          thickness: 1,
                          indent: 16.w,
                          endIndent: 16.w),
                      _buildSettingsSection(),
                      Divider(
                          color: Colors.white24,
                          thickness: 1,
                          indent: 16.w,
                          endIndent: 16.w),
                      _buildBottomSection(context, state1),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Hero(
          tag: 'profileImage',
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: GestureDetector(
              onTap: () {
                navigateTo(context: context, widget: ProfileScreen());
              },
              child: AuthCubit.get(context).userModel?.imageUrl == null ||
                      AuthCubit.get(context).userModel?.imageUrl == ''
                  ? CircleAvatar(
                      radius: 40,
                      backgroundImage: AssetImage('assets/images/person.png'))
                  : CircleAvatar(
                      radius: 40,
                      backgroundImage: CachedNetworkImageProvider(
                        AuthCubit.get(context).userModel!.imageUrl!,
                      ),
                    ),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          AuthCubit.get(context).userModel?.name ?? '',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          '${AuthCubit.get(context).userModel?.email}',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14.sp,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.white.withOpacity(0.1),
        highlightColor: Colors.white.withOpacity(0.05),
        child: ListTile(
          leading: Icon(
            icon,
            color: textColor ?? Colors.white,
            size: 22.sp,
          ),
          title: Text(
            title,
            style: TextStyle(
              color: textColor ?? Colors.white,
              fontSize: 16.sp,
              letterSpacing: 0.3,
            ),
          ),
          dense: true,
          visualDensity: const VisualDensity(vertical: -1),
          horizontalTitleGap: 0,
        ),
      ),
    );
  }

  Widget _buildMainMenuSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
          child: Text(
            'MAIN MENU',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        _buildMenuItem(
          icon: Icons.meeting_room,
          title: 'Sessions',
          onTap: () {
            navigateTo(context: context, widget: const SessionsScreen());
          },
        ),
        _buildMenuItem(
          icon: Icons.event,
          title: 'Events',
          onTap: () {
            LayoutCubit.get(context).changeBottomNavBar(2, context);
            Navigator.pop(context);
          },
        ),
        _buildMenuItem(
          icon: Icons.article_rounded,
          title: 'Blogs',
          onTap: () {
            LayoutCubit.get(context).changeBottomNavBar(1, context);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  Widget _buildResourcesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
          child: Text(
            'RESOURCES',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        _buildMenuItem(
          icon: Icons.library_books,
          title: 'Materials',
          onTap: () {
            navigateTo(context: context, widget: const MaterialScreen());
          },
        ),
        _buildMenuItem(
          icon: Icons.shopping_cart,
          title: 'Shop',
          onTap: () {
            LayoutCubit.get(context).changeBottomNavBar(4, context);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
          child: Text(
            'PREFERENCES',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        _buildMenuItem(
          icon: Icons.person,
          title: 'Profile',
          onTap: () {
            navigateTo(context: context, widget: ProfileScreen());
          },
        ),
      ],
    );
  }

  Widget _buildBottomSection(BuildContext context, state1) {
    return Column(
      children: [
        _buildMenuItem(
          icon: Icons.help_outline,
          title: 'Help & Support',
          onTap: () {
            // TODO: Navigate to help & support
          },
        ),
        ConditionalBuilder(
          condition: state1 is! AuthLogoutLoading,
          fallback: (context) {
            if (Platform.isIOS) {
              return Center(
                  child: Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: SizedBox(
                  height: 24.h,
                  width: 24.w,
                  child: const CupertinoActivityIndicator(
                    color: Colors.white,
                  ),
                ),
              ));
            } else {
              return Center(
                  child: Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: SizedBox(
                  height: 24.h,
                  width: 24.w,
                  child: const LoadingIndicator(
                    indicatorType: Indicator.ballRotateChase,
                    colors: [
                      Colors.white,
                    ],
                    strokeWidth: 2,
                  ),
                ),
              ));
            }
          },
          builder: (context) => _buildMenuItem(
            icon: Icons.logout,
            title: 'Logout',
            onTap: () {
              AuthCubit.get(context).logout(context);
            },
            textColor: Colors.redAccent,
          ),
        ),
        SizedBox(height: 24.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            'Version 1.0.0',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12.sp,
              letterSpacing: 0.5,
            ),
          ),
        ),
        SizedBox(height: 24.h),
      ],
    );
  }
}
