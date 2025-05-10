import 'package:aiche/core/shared/functions/functions.dart';
import 'package:aiche/main/committee/committee_details_screen.dart';
import 'package:aiche/main/committee/cubit/committee_cubit.dart';
import 'package:aiche/main/committee/cubit/committee_states.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hexcolor/hexcolor.dart';

class CommitteesCard extends StatelessWidget {
  const CommitteesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CommitteeCubit, CommitteeState>(
      listener: (context, state) {},
      builder: (context, state) {
        var cubit = CommitteeCubit.get(context);
        return SizedBox(
          height: 170.0.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: cubit.committeeList.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  navigateTo(
                      context: context,
                      widget: CommitteeDetailsScreen(
                        committee: cubit.committeeList[index],
                      ));
                },
                child: Container(
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
                        backgroundImage:  cubit.committeeList[index].img != null && cubit.committeeList[index].img != '' ? CachedNetworkImageProvider(
                          cubit.committeeList[index].img ?? '',
                        ) :  const AssetImage(
                          'assets/images/committee.jpg',
                        ) as ImageProvider,
                        ),
                      SizedBox(height: 10.0.h),
                      Text(
                        cubit.committeeList[index].name ?? '',
                        style: TextStyle(
                          fontSize: 16.0.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      // SizedBox(height: 5.0.h),
                      // Text(
                      //   cubit.committeeList[index].description ?? '',
                      //   style: TextStyle(
                      //     fontSize: 14.0.sp,
                      //     color: Colors.grey,
                      //   ),
                      // ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
