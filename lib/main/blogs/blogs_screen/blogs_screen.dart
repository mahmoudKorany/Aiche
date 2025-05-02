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
        child: ListView.builder(
          itemCount: 5,
          itemBuilder: (_, __) => Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0.r),
            child: Container(
              height: 120.h,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(15.r),
              ),
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
