import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class HomeShimmerComponents {
  // Shimmer for the slider when loading or empty
  static Widget buildSliderShimmer() {
    return Column(
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey.shade300.withOpacity(0.5),
          highlightColor: Colors.grey.shade100.withOpacity(0.5),
          child: Container(
            height: 170.0.h,
            margin: EdgeInsets.symmetric(horizontal: 20.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(15.r),
            ),
          ),
        ),
        SizedBox(height: 10.h),
        // Shimmer for the indicator dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            3,
            (index) => Shimmer.fromColors(
              baseColor: Colors.grey.shade300.withOpacity(0.5),
              highlightColor: Colors.grey.shade100.withOpacity(0.5),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 2.w),
                height: 8.h,
                width: 8.w,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Shimmer for the blogs section when loading or empty
  static Widget buildBlogsShimmer({required bool fromHome}) {
    if (fromHome) {
      // Horizontal list for home screen
      return SizedBox(
        height: 200.h,
        child: ListView.separated(
          padding: EdgeInsets.zero,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            return Shimmer.fromColors(
              baseColor: Colors.grey.shade300.withOpacity(0.5),
              highlightColor: Colors.grey.shade100.withOpacity(0.5),
              child: Container(
                width: 310.0.w,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
            );
          },
          separatorBuilder: (context, index) => SizedBox(width: 15.w),
          itemCount: 3,
        ),
      );
    } else {
      // Vertical list for the blogs screen
      return Expanded(
        child: ListView.separated(
          padding: EdgeInsets.zero,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            return Shimmer.fromColors(
              baseColor: Colors.grey.shade300.withOpacity(0.5),
              highlightColor: Colors.grey.shade100.withOpacity(0.5),
              child: Container(
                height: 140.h,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
            );
          },
          separatorBuilder: (context, index) => SizedBox(height: 15.h),
          itemCount: 5,
        ),
      );
    }
  }

  // Shimmer for the committees section when loading or empty
  static Widget buildCommitteesShimmer() {
    return SizedBox(
      height: 170.0.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey.shade300.withOpacity(0.5),
            highlightColor: Colors.grey.shade100.withOpacity(0.5),
            child: Container(
              margin: EdgeInsets.only(right: 10.0.w),
              width: 150.0.w,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(15.0.r),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Circle avatar placeholder
                  Container(
                    width: 100.r,
                    height: 100.r,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(height: 10.0.h),
                  // Name placeholder
                  Container(
                    height: 16.h,
                    width: 100.w,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Shimmer for awards card when loading or empty
  static Widget buildAwardsShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300.withOpacity(0.5),
      highlightColor: Colors.grey.shade100.withOpacity(0.5),
      child: Container(
        height: 120.h,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(15.r),
        ),
      ),
    );
  }
}
