import 'package:aiche/core/shared/components/gaps.dart';
import 'package:aiche/core/shared/functions/functions.dart';
import 'package:aiche/main/home/home_cubit/layout_cubit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:shimmer/shimmer.dart';

import '../../blogs/blog_details/blog_details_screen.dart';
import '../../blogs/blogs_cubit/blogs_cubit.dart';

class BlogsCard extends StatefulWidget {
  const BlogsCard({super.key, required this.fromHome});

  final bool fromHome;

  @override
  State<BlogsCard> createState() => _BlogsCardState();
}

class _BlogsCardState extends State<BlogsCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.fromHome) {
      return BlocConsumer<LayoutCubit, LayoutState>(
        listener: (context, state) {},
        builder: (context, state) {
          return Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                return AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) => Transform.scale(
                    scale: _scaleAnimation.value,
                    child: child,
                  ),
                  child: GestureDetector(
                    onTapDown: (_) => _controller.forward(),
                    onTapUp: (_) => _controller.reverse(),
                    onTapCancel: () => _controller.reverse(),
                    child: Container(
                      width: 310.0.w,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            HexColor('03172C'),
                            HexColor('081F3C'),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20.r),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              navigateTo(
                                  context: context,
                                  widget: BlogDetailsScreen(
                                    blog: BlogsCubit.get(context).blogs[index],
                                  ));
                            },
                            child: Padding(
                              padding: EdgeInsets.all(16.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      _buildAvatar(index),
                                      Gap5(isHorizontal: true),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            _buildAuthorName(index: index),
                                            SizedBox(height: 4.h),
                                            _buildMetadata(index: index),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Gap5(),
                                  _buildContent(index: index),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) => Gap15(),
              itemCount: BlogsCubit.get(context).blogs.length,
            ),
          );
        },
      );
    } else {
      return BlocConsumer<LayoutCubit, LayoutState>(
        listener: (context, state) {},
        builder: (context, state) {
          return SizedBox(
            height: 200.h,
            child: ListView.separated(
              padding: EdgeInsets.zero,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                return AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) => Transform.scale(
                    scale: _scaleAnimation.value,
                    child: child,
                  ),
                  child: GestureDetector(
                    onTapDown: (_) => _controller.forward(),
                    onTapUp: (_) => _controller.reverse(),
                    onTapCancel: () => _controller.reverse(),
                    child: Container(
                      width: 310.0.w,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            HexColor('03172C'),
                            HexColor('081F3C'),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20.r),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              navigateTo(
                                  context: context,
                                  widget: BlogDetailsScreen(
                                    blog: BlogsCubit.get(context).blogs[index],
                                  ));
                            },
                            child: Padding(
                              padding: EdgeInsets.all(16.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      _buildAvatar(index),
                                      Gap5(isHorizontal: true),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            _buildAuthorName(index: index),
                                            SizedBox(height: 4.h),
                                            _buildMetadata(index: index),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Gap5(),
                                  _buildContent(index: index),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) => Gap15(isHorizontal: true),
              itemCount: BlogsCubit.get(context).blogs.length,
            ),
          );
        },
      );
    }
  }

  Widget _buildAvatar(int index) {
    return Hero(
      tag: 'blog_avatar_$index',
      child: Container(
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              Colors.blue.withOpacity(0.5),
              Colors.purple.withOpacity(0.5),
            ],
          ),
        ),
        child: CircleAvatar(
          radius: 22.r,
          backgroundColor: Colors.white10,
          child: CircleAvatar(
            radius: 20.r,
            backgroundImage: CachedNetworkImageProvider(
              BlogsCubit.get(context).blogs[index].user!.imageUrl ?? '',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAuthorName({required int index}) {
    return Shimmer.fromColors(
      baseColor: Colors.white,
      highlightColor: Colors.white70,
      period: const Duration(seconds: 2),
      child: Text(
        BlogsCubit.get(context).blogs[index].user!.name ?? '',
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildMetadata({required int index}) {
    return SizedBox(
      height: 30.h,
      child: SingleChildScrollView(
        padding: EdgeInsets.zero,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            Icon(
              Icons.access_time_rounded,
              size: 12.sp,
              color: Colors.white70,
            ),
            SizedBox(width: 4.w),
            Text(
              formatDate(BlogsCubit.get(context).blogs[index].createdAt ?? ''),
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.white70,
              ),
            ),
            const Gap10(
              isHorizontal: true,
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 8.w,
                vertical: 4.h,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.withOpacity(0.2),
                    Colors.purple.withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: Colors.white24,
                  width: 1,
                ),
              ),
              child: Text(
                BlogsCubit.get(context).blogs[index].user?.title ?? '',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent({required int index}) {
    return Text(
      BlogsCubit.get(context).blogs[index].description ?? '',
      style: TextStyle(
        fontSize: 13.sp,
        color: Colors.white.withOpacity(0.9),
        height: 1.5,
        letterSpacing: 0.3,
      ),
      maxLines: 5,
      overflow: TextOverflow.ellipsis,
    );
  }
}
