import 'package:aiche/core/shared/components/components.dart';
import 'package:aiche/core/shared/components/gaps.dart';
import 'package:aiche/main/home/home_component/blogs_card.dart';
import 'package:aiche/main/home/home_component/committees_card.dart';
import 'package:aiche/main/home/home_component/event_card_and_material_card.dart';
import 'package:aiche/main/home/home_component/hello_name_component.dart';
import 'package:aiche/main/home/home_component/price_card.dart';
import 'package:aiche/main/home/home_cubit/layout_cubit.dart';
import 'package:flutter/material.dart';
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
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: 20.0.w,
              vertical: 20.0.h,
            ),
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Gap40(),
                const HelloNameComponent(),
                const Gap20(),
                const HomeSlider(),
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
                const BlogsCard(
                  fromHome: true,
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
                        // Navigate to committees screen
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
                const CommitteesCard(),
                const Gap100(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
