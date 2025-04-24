import 'dart:io';

import 'package:aiche/core/shared/components/components.dart';
import 'package:aiche/core/shared/components/gaps.dart';
import 'package:aiche/core/shared/functions/functions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import '../../profile/profile_util.dart';
import '../model/blog_model.dart';

class BlogDetailsScreen extends StatefulWidget {
  final BlogModel blog;

  const BlogDetailsScreen({super.key, required this.blog});

  @override
  State<BlogDetailsScreen> createState() => _BlogDetailsScreenState();
}

String formatDate(String date) {
  DateTime parsedDate = DateTime.parse(date);
  String formattedDate =
      "${parsedDate.day}/${parsedDate.month}/${parsedDate.year}";
  return formattedDate;
}

class _BlogDetailsScreenState extends State<BlogDetailsScreen>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  // bool _isLiked = false;
  // bool _isBookmarked = false;
  // final TextEditingController _commentController = TextEditingController();
  // bool _isCommentFocused = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    //_commentController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        BackGround(),
        Scaffold(
          backgroundColor: const Color(0xFF111347).withOpacity(0),
          resizeToAvoidBottomInset: true,
          body: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(),
              SliverPadding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                sliver: SliverToBoxAdapter(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF111347).withOpacity(0.0),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30.r),
                        topRight: Radius.circular(30.r),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTitle(),
                          const Gap10(),
                          _buildAuthorSection(),
                          const Gap10(),
                          _buildBody(),
                          // _buildTagsSection(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: _buildShareButton(),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300.h,
      pinned: true,
      stretch: true,
      backgroundColor: const Color(0xFF111347),
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          tag: 'blog_image_${widget.blog.image}',
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: widget.blog.image ?? '',
                fit: BoxFit.cover,
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
      ),
      leading: _buildBackButton(),
    );
  }

  Widget _buildBackButton() {
    return Padding(
      padding: EdgeInsets.all(5.w),
      child: Pop(),
    );
  }

  Widget _buildTitle() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Text(
        widget.blog.title ?? "",
        style: TextStyle(
          fontSize: 24.sp,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          height: 1.4,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildAuthorSection() {
    return GestureDetector(
      onTap: () {
        ProfileUtil.navigateToProfileFromBlog(
          context,
          blogUser: widget.blog.user,
        );
      },
      child: Row(
        children: [
          Hero(
            tag: 'author_avatar',
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
                radius: 24.r,
                backgroundColor: Colors.white,
                child: (widget.blog.user?.imageUrl == null ||
                        widget.blog.user?.imageUrl?.length == 0)
                    ? CircleAvatar(
                        radius: 22.r,
                        backgroundImage:
                            const AssetImage('assets/images/person.png'),
                      )
                    : Container(
                        width: 48.w,
                        height: 48.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: CachedNetworkImageProvider(
                                widget.blog.user?.imageUrl ?? ''),
                            fit: BoxFit.cover,
                          ),
                          border: Border.all(
                            color: Colors.white,
                            width: 0.w,
                          ),
                        )),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.white,
                  highlightColor: Colors.black,
                  child: Text(
                    widget.blog.user?.name ?? 'Author Name',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 14.sp,
                      color: Colors.white,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      formatDate(widget.blog.createdAt ?? ''),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 8.w,
              vertical: 12.h,
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
              widget.blog.user?.title ?? '',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          //_buildAuthorFollowButton(),
        ],
      ),
    );
  }

  // Widget _buildAuthorFollowButton() {
  //   return Container(
  //     padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
  //     decoration: BoxDecoration(
  //       gradient: LinearGradient(
  //         colors: [Colors.blue, Colors.purple],
  //       ),
  //       borderRadius: BorderRadius.circular(20.r),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.blue.withOpacity(0.3),
  //           blurRadius: 8,
  //           offset: const Offset(0, 2),
  //         ),
  //       ],
  //     ),
  //     child: Text(
  //       'Follow',
  //       style: TextStyle(
  //         color: Colors.white,
  //         fontSize: 14.sp,
  //         fontWeight: FontWeight.w600,
  //       ),
  //     ),
  //   );
  // }

  Widget _buildBody() {
    return Text(
      widget.blog.description ?? '',
      style: TextStyle(
        fontSize: 16.sp,
        color: Colors.white,
        height: 1.8,
        letterSpacing: 0.3,
      ),
    );
  }

  // Widget _buildTagsSection() {
  //   return Wrap(
  //     spacing: 8.w,
  //     runSpacing: 8.h,
  //     children: [
  //       _buildTag('Chemical Engineering'),
  //       _buildTag('Research'),
  //       _buildTag('Innovation'),
  //     ],
  //   );
  // }
  //
  // Widget _buildTag(String tag) {
  //   return Container(
  //     padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
  //     decoration: BoxDecoration(
  //       color: Colors.blue.withOpacity(0.1),
  //       borderRadius: BorderRadius.circular(15.r),
  //       border: Border.all(
  //         color: Colors.blue.withOpacity(0.3),
  //       ),
  //     ),
  //     child: Text(
  //       '#$tag',
  //       style: TextStyle(
  //         fontSize: 14.sp,
  //         color: Colors.blue,
  //         fontWeight: FontWeight.w500,
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildBottomBar() {
  //   return Container(
  //     padding: EdgeInsets.all(16.w),
  //     decoration: BoxDecoration(
  //       color: const Color(0xFF111347),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.05),
  //           offset: const Offset(0, -4),
  //           blurRadius: 16,
  //         ),
  //       ],
  //     ),
  //     child: SafeArea(
  //       child: Row(
  //         children: [
  //           _buildInteractionButton(
  //             icon: Icons.favorite,
  //             isActive: _isLiked,
  //             activeColor: Colors.red,
  //             count: '24',
  //             onTap: () => setState(() => _isLiked = !_isLiked),
  //           ),
  //           SizedBox(width: 16.w),
  //           Expanded(
  //             child: Container(
  //               padding: EdgeInsets.symmetric(horizontal: 16.w),
  //               decoration: BoxDecoration(
  //                 color: Colors.white.withOpacity(0.1),
  //                 borderRadius: BorderRadius.circular(25.r),
  //                 border: Border.all(
  //                   color: _isCommentFocused ? Colors.blue : Colors.transparent,
  //                   width: 1,
  //                 ),
  //               ),
  //               child: TextField(
  //                 controller: _commentController,
  //                 style: TextStyle(
  //                   color: Colors.white,
  //                   fontSize: 14.sp,
  //                 ),
  //                 onTap: () => setState(() => _isCommentFocused = true),
  //                 onSubmitted: (_) => setState(() => _isCommentFocused = false),
  //                 decoration: InputDecoration(
  //                   hintText: 'Add a comment...',
  //                   hintStyle: TextStyle(
  //                     color: Colors.white.withOpacity(0.6),
  //                     fontSize: 14.sp,
  //                   ),
  //                   border: InputBorder.none,
  //                   contentPadding: EdgeInsets.symmetric(vertical: 12.h),
  //                   prefixIcon: Icon(
  //                     Icons.chat_bubble_outline_rounded,
  //                     size: 20.sp,
  //                     color: Colors.white,
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ),
  //           SizedBox(width: 16.w),
  //           _buildInteractionButton(
  //             icon: Icons.bookmark,
  //             isActive: _isBookmarked,
  //             activeColor: Colors.blue,
  //             onTap: () => setState(() => _isBookmarked = !_isBookmarked),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildInteractionButton({
  //   required IconData icon,
  //   required bool isActive,
  //   required Color activeColor,
  //   String? count,
  //   required VoidCallback onTap,
  // })
  // {
  //   return GestureDetector(
  //     onTap: onTap,
  //     child: Container(
  //       padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
  //       decoration: BoxDecoration(
  //         color: isActive ? activeColor.withOpacity(0.1) : Colors.transparent,
  //         borderRadius: BorderRadius.circular(20.r),
  //       ),
  //       child: Row(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           Icon(
  //             icon,
  //             size: 24.sp,
  //             color: isActive ? activeColor : Colors.white,
  //           ),
  //           if (count != null) ...[
  //             SizedBox(width: 4.w),
  //             Text(
  //               count,
  //               style: TextStyle(
  //                 fontSize: 14.sp,
  //                 color: isActive ? activeColor : Colors.white,
  //                 fontWeight: FontWeight.w600,
  //               ),
  //             ),
  //           ],
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildShareButton() {
    return Padding(
      padding:EdgeInsets.only( bottom: Platform.isIOS ?  0.h : 20),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.purple],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            // share the blog text
            shareText(
              widget.blog.description ?? '',
              subject: widget.blog.title ?? '',
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Icon(
            Icons.share_rounded,
            color: Colors.white,
            size: 24.sp,
          ),
        ),
      ),
    );
  }
}
