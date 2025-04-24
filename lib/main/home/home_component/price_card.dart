import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hexcolor/hexcolor.dart';

import '../../../core/shared/functions/functions.dart';
import '../../awards/awards_screen.dart';

class AwardsCard extends StatelessWidget {
  const AwardsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        navigateTo(widget:  const AwardsScreen(), context: context,);
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: HexColor('#03172C'),
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30.r,
              backgroundColor: Colors.blue.withOpacity(0.2),
              child: Image.asset(
                'assets/images/price.png',
                height: 40.h,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Competition Awards',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Check out our latest achievements',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }
}
