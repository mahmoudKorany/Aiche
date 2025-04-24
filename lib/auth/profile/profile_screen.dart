import 'dart:math' as math;
import 'package:aiche/auth/auth_cubit/auth_cubit.dart';
import 'package:aiche/auth/auth_cubit/auth_state.dart';
import 'package:aiche/core/shared/components/components.dart';
import 'package:aiche/core/shared/components/gaps.dart';
import 'package:aiche/core/shared/functions/functions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:aiche/auth/profile/edit_profile_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _profileImageAnimation;
  late Animation<double> _nameAnimation;
  late Animation<double> _emailAnimation;
  late Animation<double> _cardsAnimation;
  late Animation<double> _buttonAnimation;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _backgroundCircleAnimation;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Create various animations
    _profileImageAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    _nameAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.4, curve: Curves.easeOut),
      ),
    );

    _emailAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.5, curve: Curves.easeOut),
      ),
    );

    _cardsAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
      ),
    );

    _buttonAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 0.8, curve: Curves.elasticOut),
      ),
    );

    _colorAnimation = ColorTween(
      begin: Colors.blue.shade200,
      end: Colors.blue,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 0.8, curve: Curves.easeInOut),
      ),
    );

    _backgroundCircleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );

    // Start the animation when the screen loads
    _controller.forward();
  }

  // Method to pick image from gallery
  Future<void> _pickImageFromGallery() async {
    final XFile? pickedImage = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedImage != null) {
      _uploadProfileImage(File(pickedImage.path));
    }
  }

  // Method to capture image from camera
  Future<void> _pickImageFromCamera() async {
    final XFile? pickedImage = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (pickedImage != null) {
      _uploadProfileImage(File(pickedImage.path));
    }
  }

  // Method to upload the selected image
  void _uploadProfileImage(File imageFile) {
    AuthCubit.get(context).updateProfileImage(
      context: context,
      imageFile: imageFile,
    );
  }

  // Method to show image selection options
  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Bottom sheet handle
              Container(
                width: 40.r,
                height: 5.r,
                margin: EdgeInsets.only(bottom: 20.r),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2.5.r),
                ),
              ),
              Text(
                "Change Profile Picture",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20.r),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImageSourceOption(
                    context: context,
                    icon: Icons.camera_alt,
                    title: "Camera",
                    onTap: () {
                      Navigator.pop(context);
                      _pickImageFromCamera();
                    },
                  ),
                  _buildImageSourceOption(
                    context: context,
                    icon: Icons.photo_library,
                    title: "Gallery",
                    onTap: () {
                      Navigator.pop(context);
                      _pickImageFromGallery();
                    },
                  ),
                ],
              ),
              SizedBox(height: 20.r),
            ],
          ),
        );
      },
    );
  }

  // Widget to build image source option
  Widget _buildImageSourceOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60.r,
            height: 60.r,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15.r),
            ),
            child: Icon(
              icon,
              color: Colors.blue,
              size: 30.r,
            ),
          ),
          SizedBox(height: 8.r),
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is UpdateProfileImageSuccess) {
          showToast(
              msg: 'Profile image updated successfully',
              state: MsgState.success);
        } else if (state is UpdateProfileImageError) {
          showToast(
              msg: 'Failed to update profile image: ${state.error}',
              state: MsgState.error);
        }
      },
      builder: (context, state) {
        var cubit = AuthCubit.get(context);
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Stack(
            alignment: Alignment.center,
            children: [
              BackGround(),
              Scaffold(
                backgroundColor: Colors.white.withOpacity(0.0),
                body: AnimatedBackground(
                  animation: _backgroundCircleAnimation,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(16.0.r),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ScaleTransition(
                            scale: _profileImageAnimation,
                            child: RotationTransition(
                              turns: Tween(begin: -0.05, end: 0.0)
                                  .animate(_profileImageAnimation),
                              child: Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  // Image container with pulsating effect
                                  TweenAnimationBuilder<double>(
                                    tween: Tween<double>(begin: 1.0, end: 1.08),
                                    duration: const Duration(seconds: 2),
                                    curve: Curves.easeInOut,
                                    builder: (context, value, child) {
                                      return AnimatedBuilder(
                                        animation: _controller,
                                        builder: (context, child) {
                                          return Transform.scale(
                                            scale: math.sin(_controller.value *
                                                        math.pi *
                                                        2) *
                                                    0.03 +
                                                1.0,
                                            child: Container(
                                              height: 120.h,
                                              width: 120.w,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: Colors.blue
                                                      .withOpacity(0.5 +
                                                          0.5 *
                                                              math.sin(_controller
                                                                      .value *
                                                                  math.pi *
                                                                  2)),
                                                  width: 3.w,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.blue
                                                        .withOpacity(0.3),
                                                    blurRadius: 15 *
                                                        _profileImageAnimation
                                                            .value,
                                                    spreadRadius: 2,
                                                  ),
                                                ],
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(60.r),
                                                child: (cubit.userModel
                                                                ?.imageUrl ==
                                                            null ||
                                                        cubit.userModel!
                                                            .imageUrl!.isEmpty)
                                                    ? const Image(
                                                        image: AssetImage(
                                                            'assets/images/person.png'),
                                                        fit: BoxFit.cover,
                                                      )
                                                    : CachedNetworkImage(
                                                        imageUrl: cubit
                                                            .userModel!
                                                            .imageUrl!,
                                                        fit: BoxFit.cover,
                                                        placeholder:
                                                            (context, url) =>
                                                                Center(
                                                          child:
                                                              CircularProgressIndicator(
                                                            color: Colors.blue,
                                                          ),
                                                        ),
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            const Image(
                                                          image: AssetImage(
                                                              'assets/images/person.png'),
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                  // Edit icon with bounce effect
                                  TweenAnimationBuilder<double>(
                                    tween: Tween<double>(begin: 0.0, end: 1.0),
                                    duration: const Duration(milliseconds: 800),
                                    curve: Curves.elasticOut,
                                    builder: (context, value, child) {
                                      return Transform.scale(
                                        scale: value,
                                        child: GestureDetector(
                                          onTap: _showImageSourceOptions,
                                          child: Container(
                                            height: 35.h,
                                            width: 35.w,
                                            decoration: BoxDecoration(
                                              color: _colorAnimation.value,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.white,
                                                width: 2,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.2),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Icon(
                                              Icons.edit,
                                              color: Colors.white,
                                              size: 20.sp,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const Gap15(),

                          // Animated Name
                          FadeTransition(
                            opacity: _nameAnimation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.5),
                                end: Offset.zero,
                              ).animate(_nameAnimation),
                              child: Text(
                                "${cubit.userModel?.name}",
                                style: TextStyle(
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          const Gap5(),

                          // Animated Email
                          FadeTransition(
                            opacity: _emailAnimation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.5),
                                end: Offset.zero,
                              ).animate(_emailAnimation),
                              child: Text(
                                "${cubit.userModel?.email}",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),

                          const Gap30(),

                          // Animated Information Cards
                          FadeTransition(
                            opacity: _cardsAnimation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.5, 0),
                                end: Offset.zero,
                              ).animate(_cardsAnimation),
                              child: Column(
                                children: [
                                  _buildAnimatedInfoCard(
                                    title: "Bio",
                                    content:
                                        cubit.userModel?.bio?.length == 0 ||
                                                cubit.userModel?.bio == null
                                            ? "No bio available"
                                            : cubit.userModel!.bio!,
                                    icon: Icons.person_outline,
                                    delay: 0.0,
                                  ),
                                  _buildAnimatedInfoCard(
                                    title: "Phone Number",
                                    content:
                                        cubit.userModel?.phone?.length == 0 ||
                                                cubit.userModel?.phone == null
                                            ? "No phone number available"
                                            : cubit.userModel!.phone!,
                                    icon: Icons.phone_outlined,
                                    delay: 0.1,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      if (cubit.userModel?.linkedInLink
                                                  ?.length !=
                                              0 ||
                                          cubit.userModel?.linkedInLink !=
                                              null) {
                                        launchUrl(Uri.parse(
                                            cubit.userModel!.linkedInLink!));
                                      }
                                    },
                                    child: AnimatedBuilder(
                                      animation: _controller,
                                      builder: (context, child) {
                                        final double begin = 0.2;
                                        final double end = 0.2 + 0.3;
                                        final curvedAnimation = CurvedAnimation(
                                          parent: _controller,
                                          curve: Interval(begin, end,
                                              curve: Curves.easeOut),
                                        );

                                        return Transform.translate(
                                          offset: Offset(
                                            50 * (1 - curvedAnimation.value),
                                            0,
                                          ),
                                          child: Opacity(
                                            opacity: curvedAnimation.value,
                                            child: Container(
                                              margin:
                                                  EdgeInsets.only(bottom: 15.h),
                                              padding: EdgeInsets.all(15.r),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(15.r),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.blue
                                                        .withOpacity(0.08),
                                                    spreadRadius: 2,
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 3),
                                                  ),
                                                ],
                                                border: Border.all(
                                                  color: Colors.blue
                                                      .withOpacity(0.1),
                                                  width: 1,
                                                ),
                                              ),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    padding:
                                                        EdgeInsets.all(8.r),
                                                    decoration: BoxDecoration(
                                                      color: Colors.blue
                                                          .withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.r),
                                                    ),
                                                    child: Image.asset(
                                                      'assets/images/linkedin.png',
                                                      height: 24.r,
                                                      width: 24.r,
                                                    ),
                                                  ),
                                                  const Gap15(
                                                    isHorizontal: true,
                                                  ),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'LinkedIn Profile',
                                                          style: TextStyle(
                                                            fontSize: 16.sp,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Colors.black87,
                                                          ),
                                                        ),
                                                        const Gap5(),
                                                        Text(
                                                          cubit.userModel?.linkedInLink
                                                                          ?.length ==
                                                                      0 ||
                                                                  cubit.userModel
                                                                          ?.linkedInLink ==
                                                                      null
                                                              ? "No LinkedIn profile available"
                                                              : cubit.userModel!
                                                                  .linkedInLink!,
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                            fontSize: 15.sp,
                                                            color: Colors
                                                                .grey.shade700,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Animated Edit Profile Button
                          const SizedBox(height: 30),
                          ScaleTransition(
                            scale: _buttonAnimation,
                            child: AnimatedBuilder(
                              animation: _controller,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: 1.0 +
                                      0.05 *
                                          math.sin(
                                              _controller.value * math.pi * 5),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      // Show edit options bottom sheet
                                      _showEditOptionsBottomSheet(
                                          context, cubit);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _colorAnimation.value,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 30.w,
                                        vertical: 12.h,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      elevation: 5,
                                      shadowColor: Colors.blue.withOpacity(0.5),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.edit),
                                        const Gap10(
                                          isHorizontal: true,
                                        ),
                                        Text(
                                          "Edit Profile",
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const Gap20(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (state is UpdateProfileImageLoading)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
              Positioned(
                top: 60.h,
                left: 20.w,
                child: Pop(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnimatedInfoCard({
    required String title,
    required String content,
    required IconData icon,
    required double delay,
  }) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double begin = delay;
        final double end = delay + 0.3;
        final curvedAnimation = CurvedAnimation(
          parent: _controller,
          curve: Interval(begin, end, curve: Curves.easeOut),
        );

        return Transform.translate(
          offset: Offset(
            50 * (1 - curvedAnimation.value),
            0,
          ),
          child: Opacity(
            opacity: curvedAnimation.value,
            child: Container(
              margin: EdgeInsets.only(bottom: 15.h),
              padding: EdgeInsets.all(15.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.08),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
                border: Border.all(
                  color: Colors.blue.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      icon,
                      color: Colors.blue,
                      size: 24.r,
                    ),
                  ),
                  const Gap15(
                    isHorizontal: true,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const Gap5(),
                        Text(
                          content,
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showEditOptionsBottomSheet(BuildContext context, AuthCubit cubit) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                Colors.blue.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Bottom sheet handle
              Container(
                width: 40.r,
                height: 5.r,
                margin: EdgeInsets.only(bottom: 20.r),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2.5.r),
                ),
              ),

              Text(
                "Edit Profile",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const Gap20(),

              // Email option
              _buildEditOption(
                context: context,
                icon: Icons.email_outlined,
                title: "Edit LinkedIn",
                subtitle: "Change your current LinkedIn profile",
                fieldToEdit: 'LinkedIn',
              ),

              Divider(height: 1, color: Colors.grey.withOpacity(0.2)),

              // Bio option
              _buildEditOption(
                context: context,
                icon: Icons.person_outline,
                title: "Edit Bio",
                subtitle: "Update your personal information",
                fieldToEdit: 'bio',
              ),

              Divider(height: 1, color: Colors.grey.withOpacity(0.2)),

              // Phone option
              _buildEditOption(
                context: context,
                icon: Icons.phone_outlined,
                title: "Edit Phone Number",
                subtitle: "Update your contact number",
                fieldToEdit: 'phone',
              ),

              const Gap20(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEditOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required String fieldToEdit,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(
          icon,
          color: Colors.blue,
          size: 24.r,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12.sp,
          color: Colors.grey,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16.r, color: Colors.grey),
      onTap: () {
        Navigator.pop(context);
        navigateTo(
            context: context,
            widget: EditProfileScreen(fieldToEdit: fieldToEdit));
      },
    );
  }
}

// Enhanced Background Widget with Animation
class AnimatedBackground extends StatelessWidget {
  final Widget child;
  final Animation<double> animation;

  const AnimatedBackground({
    Key? key,
    required this.child,
    required this.animation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blue.withOpacity(0.2),
            Colors.white,
          ],
          stops: const [0.1, 0.4],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          // Animated top-left circle
          AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return Positioned(
                top: -50 * (1 - animation.value),
                left: -50 * (1 - animation.value),
                child: Transform.scale(
                  scale: animation.value,
                  child: Container(
                    height: 200.h,
                    width: 200.w,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(100.r),
                    ),
                  ),
                ),
              );
            },
          ),

          // Animated bottom-right circle
          AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return Positioned(
                bottom: -80 * (1 - animation.value),
                right: -80 * (1 - animation.value),
                child: Transform.scale(
                  scale: animation.value,
                  child: Container(
                    height: 200.h,
                    width: 200.w,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(100.r),
                    ),
                  ),
                ),
              );
            },
          ),

          // Animated floating particles
          ...List.generate(10, (index) {
            final random = math.Random(index);
            final size = random.nextDouble() * 15 + 5;
            final posX =
                random.nextDouble() * MediaQuery.of(context).size.width;
            final posY =
                random.nextDouble() * MediaQuery.of(context).size.height;
            final opacity = random.nextDouble() * 0.2;
            final duration = Duration(seconds: random.nextInt(10) + 5);

            return AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                if (animation.value < 0.3) return const SizedBox.shrink();

                return Positioned(
                  left: posX,
                  top: posY,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: duration,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: opacity *
                            math.sin(value * math.pi) *
                            animation.value,
                        child: Transform.translate(
                          offset: Offset(
                            math.sin(value * math.pi * 2) * 20,
                            math.cos(value * math.pi * 2) * 20,
                          ),
                          child: Container(
                            width: size,
                            height: size,
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }),

          child,
        ],
      ),
    );
  }
}
