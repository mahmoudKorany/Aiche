import 'package:aiche/core/shared/components/gaps.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Add this import for clipboard
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:aiche/core/shared/components/components.dart';
import 'package:aiche/main/home/model/awards_model.dart';

import '../home/home_cubit/layout_cubit.dart';

class AwardsScreen extends StatefulWidget {
  const AwardsScreen({Key? key}) : super(key: key);

  @override
  State<AwardsScreen> createState() => _AwardsScreenState();
}

class _AwardsScreenState extends State<AwardsScreen> {
  // Sample data for awards

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LayoutCubit, LayoutState>(
      listener: (context, state) {},
      builder: (context, state) {
        final List<AwardsModel> awards = LayoutCubit.get(context).awardsList;
        return Scaffold(
          body: Stack(
            children: [
              const BackGround(), // Use the existing BackGround component
              SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Custom App Bar
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 16.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Pop(),
                          SizedBox(width: 16.w), // Balancing the layout
                          Text(
                            "Awards",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 40.w), // Balancing the layout
                        ],
                      ),
                    ),

                    // Header Section
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 16.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Aiche Achievements",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            "Browse through all the awards and recognitions",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Awards List
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(top: 16.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30.r),
                            topRight: Radius.circular(30.r),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30.r),
                            topRight: Radius.circular(30.r),
                          ),
                          child: ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            padding: EdgeInsets.all(16.r),
                            itemCount: awards.length,
                            itemBuilder: (context, index) {
                              return buildAwardCard(awards[index]);
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildAwardCard(AwardsModel award) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () {
            // Show award details
            showAwardDetails(context, award);
          },
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Award icon/trophy
                Container(
                  width: 60.w,
                  height: 60.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFF111347).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.emoji_events_rounded,
                    color: const Color(0xFF111347),
                    size: 32.sp,
                  ),
                ),
                SizedBox(width: 16.w),

                // Award details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        award.title ?? "Award Title",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        award.description ?? "Award Description",
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 14.sp,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14.sp,
                            color: Colors.black45,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            award.date ?? "Award Date",
                            style: TextStyle(
                              color: Colors.black45,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Chevron icon
                Icon(
                  Icons.chevron_right,
                  color: Colors.black45,
                  size: 24.sp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showAwardDetails(BuildContext context, AwardsModel award) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.64,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.r),
            topRight: Radius.circular(30.r),
          ),
        ),
        child: Column(
          children: [
            // Bottom sheet handle
            Container(
              margin: EdgeInsets.symmetric(vertical: 12.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.0.w),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Award icon/trophy
                    Center(
                      child: Container(
                        width: 80.w,
                        height: 80.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFF111347).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Icon(
                          Icons.emoji_events_rounded,
                          color: const Color(0xFF111347),
                          size: 48.sp,
                        ),
                      ),
                    ),
                    const Gap35(),

                    // Award title
                    Center(
                      child: Text(
                        award.title ?? "Award Title",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const Gap10(),

                    // Award date
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16.sp,
                            color: Colors.black45,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            award.date ?? "Award Date",
                            style: TextStyle(
                              color: Colors.black45,
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap20(),

                    // Description header
                    Text(
                      "Description",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Gap10(),

                    // Description text
                    Text(
                      award.description ?? "Award Description",
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 16.sp,
                        height: 1.5,
                      ),
                    ),
                    const Gap20(),

                    // Divider
                    const Divider(),
                    const Gap20(),

                    // Additional info
                    Text(
                      "Certificate Information",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Gap10(),

                    // Issue date
                    buildInfoRow("Issue Date:", award.date ?? "N/A"),

                    // Share button
                    const Gap50(),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Copy certificate link to clipboard
                          final certificateLink = award.title ??
                              "https://aiche.org/certificates/${award.id}";
                          Clipboard.setData(
                              ClipboardData(text: certificateLink));
                          showToast(
                            msg: "Certificate link copied to clipboard!",
                            state: MsgState.success,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF111347),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: 24.w, vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        icon: Icon(Icons.copy, size: 20.sp),
                        label: Text(
                          "Copy Certificate Link",
                          style: TextStyle(fontSize: 16.sp),
                        ),
                      ),
                    ),

                    // Bottom padding to ensure content doesn't stick to the bottom
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 150.w,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.black54,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: Colors.black,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
