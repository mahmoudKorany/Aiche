import 'package:aiche/core/shared/components/components.dart';
import 'package:aiche/core/shared/functions/functions.dart';
import 'package:aiche/main/committee/committee_details_screen.dart';
import 'package:aiche/main/committee/cubit/committee_cubit.dart';
import 'package:aiche/main/committee/cubit/committee_states.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hexcolor/hexcolor.dart';

class AllCommitteesScreen extends StatelessWidget {
  const AllCommitteesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const BackGround(),
        Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: const Text(
              "All Committees",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            leading:  Padding(
              padding: EdgeInsets.all(8.0.r),
              child: const Pop(),
            ),
          ),
          backgroundColor: Colors.transparent,
          body: BlocConsumer<CommitteeCubit, CommitteeState>(
            listener: (context, state) {},
            builder: (context, state) {
              var cubit = CommitteeCubit.get(context);

              if (state is GetCommitteeLoadingState) {
                return const Center(child: CircularProgressIndicator());
              }

              if (cubit.committeeList.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.group_off,
                        size: 80.sp,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        "No Committees Available",
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Padding(
                padding: EdgeInsets.all(16.r),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 15.w,
                    mainAxisSpacing: 15.h,
                  ),
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
                        decoration: BoxDecoration(
                          color: HexColor('03172C'),
                          borderRadius: BorderRadius.circular(15.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 45.r,
                              backgroundColor: Colors.black26,
                              backgroundImage:  cubit.committeeList[index].img != null && cubit.committeeList[index].img != '' ? CachedNetworkImageProvider(
                                cubit.committeeList[index].img ?? '',
                              ) :  const AssetImage(
                                'assets/images/committee.jpg',
                              ) as ImageProvider,
                            ),
                            SizedBox(height: 15.h),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.w),
                              child: Text(
                                cubit.committeeList[index].name ?? '',
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
