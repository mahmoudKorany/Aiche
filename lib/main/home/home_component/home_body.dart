import 'package:aiche/core/shared/components/components.dart';
import 'package:aiche/core/shared/components/gaps.dart';
import 'package:aiche/core/shared/functions/functions.dart';
import 'package:aiche/main/blogs/blogs_cubit/blogs_cubit.dart';
import 'package:aiche/main/committee/all_committees_screen.dart';
import 'package:aiche/main/committee/cubit/committee_cubit.dart';
import 'package:aiche/main/committee/cubit/committee_states.dart';
import 'package:aiche/main/events/events_cubit/events_cubit.dart';
import 'package:aiche/main/home/home_component/blogs_card.dart';
import 'package:aiche/main/home/home_component/committees_card.dart';
import 'package:aiche/main/home/home_component/event_card_and_material_card.dart';
import 'package:aiche/main/home/home_component/hello_name_component.dart';
import 'package:aiche/main/home/home_component/home_shimmer_components.dart';
import 'package:aiche/main/home/home_component/price_card.dart';
import 'package:aiche/main/home/home_cubit/layout_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'home_slider.dart';

class HomeBody extends StatelessWidget {
  const HomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          const BackGround(),
          SafeArea(
            bottom: false,
            child: RefreshIndicator(
              onRefresh: () async {
                // Refresh the data when pulled down
                await LayoutCubit.get(context).getHomeBanner();
                await LayoutCubit.get(context).getMaterial();
                await BlogsCubit.get(context).getBlogs();
                await CommitteeCubit.get(context).getCommitteeData();
                await EventsCubit.get(context).fetchEvents();
                await LayoutCubit.get(context).getAwards();
              },
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: 20.0.w,
                  vertical: 20.0.h,
                ),
                physics:
                const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const HelloNameComponent(),
                    const Gap20(),
                    // Banner section with shimmer loading
                    BlocBuilder<LayoutCubit, LayoutState>(
                      builder: (context, state) {
                        final cubit = LayoutCubit.get(context);

                        // Check if banner is loading or empty
                        if (state is LayoutGetBannerLoading ||
                            cubit.bannerList.isEmpty) {
                          return HomeShimmerComponents.buildSliderShimmer();
                        } else {
                          return const HomeSlider();
                        }
                      },
                    ),

                    const Gap20(),
                    const EventCardAndMaterialCard(),
                    const Gap20(),
                    const AwardsCard(),
                    const Gap20(),
                    Row(
                      children: [
                        Text(
                          'Blogs',
                          style: TextStyle(
                            fontSize: 20.0.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () {
                            LayoutCubit.get(context).changeBottomNavBar(1, context);
                          },
                          child: Text(
                            'View All',
                            style: TextStyle(
                              fontSize: 14.0.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Gap20(),

                    // Blogs section with shimmer loading
                    BlocBuilder<BlogsCubit, BlogsState>(
                      builder: (context, state) {
                        final blogCubit = BlogsCubit.get(context);

                        // Check if blogs are loading or empty
                        if (state is BlogsLoading || blogCubit.blogs.isEmpty) {
                          return HomeShimmerComponents.buildBlogsShimmer(
                              fromHome: true);
                        } else {
                          return const BlogsCard(fromHome: true);
                        }
                      },
                    ),

                    const Gap20(),
                    Row(
                      children: [
                        Text(
                          'Committees',
                          style: TextStyle(
                            fontSize: 20.0.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () {
                            navigateTo(context: context, widget: const AllCommitteesScreen());
                          },
                          child: Text(
                            'View All',
                            style: TextStyle(
                              fontSize: 14.0.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Gap20(),

                    // Committees section with shimmer loading
                    BlocBuilder<CommitteeCubit, CommitteeState>(
                      builder: (context, state) {
                        final committeeCubit = CommitteeCubit.get(context);

                        // Check if committees are loading or empty
                        if (state is GetCommitteeLoadingState ||
                            committeeCubit.committeeList.isEmpty) {
                          return HomeShimmerComponents.buildCommitteesShimmer();
                        } else {
                          return const CommitteesCard();
                        }
                      },
                    ),

                    const Gap100(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
