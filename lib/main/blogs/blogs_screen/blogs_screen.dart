import 'package:aiche/core/shared/components/components.dart';
import 'package:aiche/core/shared/components/gaps.dart';
import 'package:aiche/main/blogs/blogs_cubit/blogs_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../home/home_component/blogs_card.dart';
import '../../home/home_component/drawer_icon.dart';

class BlogsScreen extends StatelessWidget {
  const BlogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BlogsCubit, BlogsState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          body: Stack(
            children: [
              const BackGround(),
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.all(20.0.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const DrawerIcon(),
                          const Gap10(isHorizontal: true,),
                          Text(
                            'Blogs',
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const Gap20(),
                      const BlogsCard(
                        fromHome: false,
                      ),
                      const Gap90(),
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
