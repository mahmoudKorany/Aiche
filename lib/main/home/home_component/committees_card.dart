import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hexcolor/hexcolor.dart';

class CommitteesCard extends StatelessWidget {
  const CommitteesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170.0.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(right: 10.0.w),
            width: 150.0.w,
            decoration: BoxDecoration(
              color: HexColor('03172C'),
              borderRadius: BorderRadius.circular(15.0.r),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50.0.r,
                  backgroundImage:
                      const AssetImage('assets/images/committee.jpg'),
                ),
                SizedBox(height: 10.0.h),
                Text(
                  'Committee Name',
                  style: TextStyle(
                    fontSize: 16.0.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 5.0.h),
                Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 14.0.sp,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
