import 'package:aiche/core/shared/components/gaps.dart';
import 'package:aiche/main/material/material_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hexcolor/hexcolor.dart';

import '../home_cubit/layout_cubit.dart';

class EventCardAndMaterialCard extends StatelessWidget {
  const EventCardAndMaterialCard({super.key});

  //background: #03172C;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              LayoutCubit.get(context).changeBottomNavBar(2, context);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              height: 150.0.h,
              decoration: BoxDecoration(
                color: HexColor('#03172C'),
                borderRadius: BorderRadius.circular(15.0.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              padding: EdgeInsetsDirectional.only(
                start: 20.0.w,
                top: 20.0.h,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Event',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      const Spacer(),
                      Hero(
                        tag: 'eventImage',
                        child: Image.asset(
                          'assets/images/event.png',
                          height: 90.h,
                        ),
                      ),
                      const Gap10(
                        isHorizontal: true,
                      ),
                    ],
                  ),
                  const Gap10(),
                ],
              ),
            ),
          ),
        ),
        const Gap15(
          isHorizontal: true,
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MaterialScreen(),
                ),
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              height: 150.0.h,
              decoration: BoxDecoration(
                color: HexColor('#03172C'),
                borderRadius: BorderRadius.circular(15.0.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              padding: EdgeInsetsDirectional.only(
                start: 20.0.w,
                top: 20.0.h,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Material',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      const Spacer(),
                      Hero(
                        tag: 'materialImage',
                        child: Image.asset(
                          'assets/images/material.png',
                          height: 90.h,
                        ),
                      ),
                      const Gap10(
                        isHorizontal: true,
                      ),
                    ],
                  ),
                  const Gap10(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
