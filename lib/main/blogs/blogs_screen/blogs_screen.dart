import 'package:aiche/core/shared/components/components.dart';
import 'package:aiche/core/shared/components/gaps.dart';
import 'package:aiche/main/blogs/blogs_cubit/blogs_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import '../../home/home_component/blogs_card.dart';
import '../../home/home_component/drawer_icon.dart';

class BlogsScreen extends StatelessWidget {
  const BlogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BlogsCubit, BlogsState>(
      listener: (context, state) {},
      builder: (context, state) {
        final blogsCubit = BlogsCubit.get(context);
        return Scaffold(
          body: Stack(
            children: [
              const BackGround(),
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.all(20.0.r),
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await blogsCubit.getBlogs();
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const DrawerIcon(),
                            const Gap10(
                              isHorizontal: true,
                            ),
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
                        if (state is BlogsLoading)
                          _buildShimmerEffect()
                        else if (state is BlogsSuccess &&
                            blogsCubit.blogs.isEmpty)
                          _buildEmptyState(context)
                        else
                          const BlogsCard(
                            fromHome: false,
                          ),
                        const Gap90(),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildShimmerEffect() {
    return Expanded(
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!.withOpacity(0.5),
        highlightColor: Colors.grey[100]!.withOpacity(0.5),
        child: ListView.separated(
          itemCount: 5,
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: EdgeInsets.zero,
          separatorBuilder: (context, index) => SizedBox(height: 15.h),
          itemBuilder: (_, __) => Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Avatar shimmer
                    Container(
                      width: 44.r,
                      height: 44.r,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 5.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Author name shimmer
                          Container(
                            height: 16.h,
                            width: 100.w,
                            color: Colors.white,
                          ),
                          SizedBox(height: 4.h),
                          // Metadata row shimmer
                          Row(
                            children: [
                              Container(
                                height: 12.h,
                                width: 80.w,
                                color: Colors.white,
                              ),
                              SizedBox(width: 10.w),
                              Container(
                                height: 20.h,
                                width: 60.w,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5.h),
                // Content shimmer - multiple lines
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(
                    4,
                    (index) => Padding(
                      padding: EdgeInsets.only(top: index > 0 ? 5.h : 0),
                      child: Container(
                        height: 13.h,
                        width: double.infinity,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article_outlined,
              size: 60.sp,
              color: Colors.grey,
            ),
            const Gap20(),
            Text(
              'No blogs available',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const Gap10(),
            Text(
              'Check back later for new content',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
