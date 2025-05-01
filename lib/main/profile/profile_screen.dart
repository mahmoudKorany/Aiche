import 'dart:math' as math;
import 'package:aiche/core/shared/components/components.dart';
import 'package:aiche/core/shared/components/gaps.dart';
import 'package:aiche/main/blogs/model/blog_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileDetailScreen extends StatefulWidget {
  final User userModel;

  const ProfileDetailScreen({
    super.key,
    required this.userModel,
  });

  @override
  State<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _profileImageAnimation;
  late Animation<double> _nameAnimation;
  late Animation<double> _cardsAnimation;
  late Animation<double> _buttonAnimation;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _backgroundCircleAnimation;

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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Build animated information card with standardized styling
  Widget _buildAnimatedInfoCard({
    required String title,
    required String content,
    required IconData icon,
    required double delay,
    String? url,
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
            child: GestureDetector(
              onTap: url != null && url.isNotEmpty
                  ? () {
                      launchUrl(Uri.parse(url));
                    }
                  : null,
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
                    if (url != null && url.isNotEmpty)
                      Icon(
                        Icons.launch,
                        color: Colors.blue,
                        size: 20.r,
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

  // Helper method to format date string
  String _formatDate(String dateString) {
    try {
      final DateTime date = DateTime.parse(dateString);
      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      SizedBox(height: 50.h),

                      // Profile Image with Advanced Animation
                      ScaleTransition(
                        scale: _profileImageAnimation,
                        child: RotationTransition(
                          turns: Tween(begin: -0.05, end: 0.0)
                              .animate(_profileImageAnimation),
                          child: Stack(
                            alignment: Alignment.center,
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
                                              color: Colors.blue.withOpacity(
                                                  0.5 +
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
                                            child: (widget.userModel.imageUrl ==
                                                        null ||
                                                    widget.userModel.imageUrl!
                                                        .isEmpty)
                                                ? Image.asset(
                                                    'assets/images/person.png',
                                                    fit: BoxFit.cover,
                                                  )
                                                : CachedNetworkImage(
                                                    imageUrl: widget
                                                        .userModel.imageUrl!,
                                                    fit: BoxFit.cover,
                                                    placeholder:
                                                        (context, url) =>
                                                            const Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                        color: Colors.blue,
                                                      ),
                                                    ),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            Image.asset(
                                                      'assets/images/person.png',
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
                            widget.userModel.name ?? "No Name",
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const Gap5(),
                      //
                      // // Animated Email
                      // FadeTransition(
                      //   opacity: _emailAnimation,
                      //   child: SlideTransition(
                      //     position: Tween<Offset>(
                      //       begin: const Offset(0, 0.5),
                      //       end: Offset.zero,
                      //     ).animate(_emailAnimation),
                      //     child: Text(
                      //       widget.userModel.email ?? "No Email",
                      //       style: TextStyle(
                      //         fontSize: 16.sp,
                      //         color: Colors.grey,
                      //       ),
                      //     ),
                      //   ),
                      // ),

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
                              // Bio
                              _buildAnimatedInfoCard(
                                title: "Bio",
                                content: widget.userModel.bio?.isEmpty ?? true
                                    ? "No bio available"
                                    : widget.userModel.bio!,
                                icon: Icons.person_outline,
                                delay: 0.0,
                              ),

                              // Phone Number
                              GestureDetector(
                                onTap: (){
                                  launchUrl(Uri.parse('tel:${widget.userModel.phone}'));
                                },
                                child: _buildAnimatedInfoCard(
                                  title: "Phone Number",
                                  content: widget.userModel.phone?.isEmpty ?? true
                                      ? "No phone number available"
                                      : widget.userModel.phone!,
                                  icon: Icons.phone_outlined,
                                  delay: 0.1,
                                ),
                              ),

                              // LinkedIn Profile
                              AnimatedBuilder(
                                animation: _controller,
                                builder: (context, child) {
                                  final double begin = 0.2;
                                  final double end = 0.2 + 0.3;
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
                                      child: GestureDetector(
                                        onTap:   widget.userModel.linkedInLink != null && widget.userModel.linkedInLink!.isNotEmpty
                                            ? () {
                                          launchUrl(Uri.parse(widget.userModel.linkedInLink??''));
                                        }
                                            : null,
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
                                                child:  Image.asset(
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
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'LinkedIn Profile',
                                                      style: TextStyle(
                                                        fontSize: 16.sp,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                    const Gap5(),
                                                    Text(
                                                      widget.userModel.linkedInLink ?? "No LinkedIn profile available",
                                                      maxLines: 1,
                                                      style: TextStyle(
                                                        fontSize: 15.sp,
                                                        color: Colors.grey.shade700,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              if ( widget.userModel.linkedInLink != null && widget.userModel.linkedInLink!.isNotEmpty)
                                                Icon(
                                                  Icons.launch,
                                                  color: Colors.blue,
                                                  size: 20.r,
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              // Creation Dat

                              // // Last Updated
                              // _buildAnimatedInfoCard(
                              //   title: "Last Updated",
                              //   content: widget.userModel.updatedAt?.isEmpty ??
                              //           true
                              //       ? "Unknown"
                              //       : _formatDate(widget.userModel.updatedAt!),
                              //   icon: Icons.update,
                              //   delay: 0.4,
                              // ),
                            ],
                          ),
                        ),
                      ),

                      const Gap20(),

                      // Back Button with Animation
                      ScaleTransition(
                        scale: _buttonAnimation,
                        child: AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: 1.0 +
                                  0.05 *
                                      math.sin(_controller.value * math.pi * 5),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
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
                                    const Icon(Icons.arrow_back),
                                    const Gap10(
                                      isHorizontal: true,
                                    ),
                                    Text(
                                      "Back",
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

                      const Gap30(),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Back button at top
          Positioned(
            top: 60.h,
            left: 20.w,
            child: Pop(),
          ),
        ],
      ),
    );
  }
}

// Enhanced Background Widget
class BackGround extends StatelessWidget {
  const BackGround({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

// Enhanced Animated Background with Particles
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
