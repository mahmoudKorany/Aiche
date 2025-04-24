import 'package:aiche/core/shared/components/gaps.dart';
import 'package:aiche/main/home/home_cubit/layout_cubit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeSlider extends StatefulWidget {
  const HomeSlider({super.key});
  @override
  State<HomeSlider> createState() => _HomeSliderState();
}

class _HomeSliderState extends State<HomeSlider> {
  int _currentIndex = 0;

  // Function to get the appropriate social media icon based on type
  IconData getSocialMediaIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'facebook':
        return FontAwesomeIcons.facebookF;
      case 'instagram':
        return FontAwesomeIcons.instagram;
      case 'twitter':
        return FontAwesomeIcons.twitter;
      case 'linkedin':
        return FontAwesomeIcons.linkedinIn;
      default:
        return FontAwesomeIcons.link;
    }
  }

  // Get color based on social media type
  Color getSocialMediaColor(String? type) {
    switch (type?.toLowerCase()) {
      case 'facebook':
        return const Color(0xFF1877F2); // Facebook blue
      case 'instagram':
        return const Color(0xFFE4405F); // Instagram pink/red
      case 'twitter':
        return const Color(0xFF1DA1F2); // Twitter blue
      case 'linkedin':
        return const Color(0xFF0A66C2); // LinkedIn blue
      default:
        return Colors.white;
    }
  }

  // Launch URL function
  Future<void> _launchUrl(String? url) async {
    if (url == null || url.isEmpty) return;

    final Uri uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $uri');
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LayoutCubit, LayoutState>(
      listener: (context, state) {},
      builder: (context, state) {
        var cubit = LayoutCubit.get(context);
        return Column(
          children: [
            CarouselSlider.builder(
              options: CarouselOptions(
                height: 170.0.h,
                enlargeCenterPage: true,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 5),
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                autoPlayCurve: Curves.fastOutSlowIn,
                viewportFraction: 0.85,
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),
              itemCount: cubit.bannerList.length,
              itemBuilder: (context, index, realIndex) {
                return GestureDetector(
                  onTap: () {
                    // Launch URL when the banner is tapped
                    _launchUrl(cubit.bannerList[index].link);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15.r),
                          child: CachedNetworkImage(
                            imageUrl: cubit.bannerList[index].image ?? '',
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Shimmer.fromColors(
                              baseColor: Colors.grey.shade300,
                              highlightColor: Colors.grey.shade100,
                              child: Container(
                                width: double.infinity,
                                height: 170.h,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15.r),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              width: double.infinity,
                              height: 170.h,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15.r),
                              ),
                              child: const Icon(Icons.error),
                            ),
                          ),
                        ),

                        // Gradient overlay
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15.r),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.1),
                                  Colors.black.withOpacity(0.5),
                                  Colors.black.withOpacity(0.7),
                                ],
                                stops: const [0.4, 0.65, 0.8, 1.0],
                              ),
                            ),
                          ),
                        ),

                        // Content
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Padding(
                            padding: EdgeInsets.all(15.r),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Improved Social Media Icon with Container
                                InkWell(
                                  onTap: () =>
                                      _launchUrl(cubit.bannerList[index].link),
                                  child: Container(
                                    width: 36.w,
                                    height: 36.h,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 5,
                                          spreadRadius: 1,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: FaIcon(
                                        getSocialMediaIcon(
                                            cubit.bannerList[index].type),
                                        color: getSocialMediaColor(
                                            cubit.bannerList[index].type),
                                        size: 18.sp,
                                      ),
                                    ),
                                  ),
                                ),
                                const Gap10(isHorizontal: true),
                                SizedBox(
                                  width: 200.w,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        cubit.bannerList[index].title ?? '',
                                        maxLines: 2,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.bold,
                                          shadows: [
                                            Shadow(
                                              blurRadius: 3,
                                              color:
                                                  Colors.black.withOpacity(0.5),
                                              offset: const Offset(1, 1),
                                            ),
                                          ],
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 4.h),
                                      InkWell(
                                        onTap: () => _launchUrl(
                                            cubit.bannerList[index].link),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.link,
                                              color:
                                                  Colors.white.withOpacity(0.8),
                                              size: 12.sp,
                                            ),
                                            SizedBox(width: 4.w),
                                            Text(
                                              'Visit',
                                              style: TextStyle(
                                                color: Colors.white
                                                    .withOpacity(0.8),
                                                fontSize: 12.sp,
                                                decoration:
                                                    TextDecoration.underline,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const Gap10(),

            // Slide indicators
            AnimatedSmoothIndicator(
              activeIndex: _currentIndex,
              count: cubit.bannerList.length,
              effect: ExpandingDotsEffect(
                dotHeight: 8.h,
                dotWidth: 8.w,
                activeDotColor: const Color(0xFF111347),
                dotColor: Colors.grey.shade300,
                spacing: 5.w,
              ),
            ),
          ],
        );
      },
    );
  }
}
