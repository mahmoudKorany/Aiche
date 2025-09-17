import 'package:aiche/core/shared/functions/functions.dart';
import 'package:aiche/main/blogs/blog_details/blog_details_screen.dart';
import 'package:aiche/main/blogs/blogs_cubit/blogs_cubit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/shared/components/gaps.dart';

class BlogItem extends StatelessWidget {
  const BlogItem({super.key, required this.index});
  final int index;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        navigateTo(
            context: context,
            widget: BlogDetailsScreen(
              blog: BlogsCubit.get(context).blogs[index],
            ));
      },
      child: Container(
        width: 260.0.w,
        padding: EdgeInsets.all(15.0.r),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              HexColor('03172C'),
              HexColor('03172C').withOpacity(0.9),
            ],
          ),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white24,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 5,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 20.r,
                    backgroundColor: Colors.white,
                    backgroundImage: CachedNetworkImageProvider(
                      BlogsCubit.get(context).blogs[index].user?.imageUrl ?? '',
                    ),
                  ),
                ),
                const Gap5(isHorizontal: true),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        BlogsCubit.get(context).blogs[index].user?.name ?? '',
                        style: TextStyle(
                          fontSize: 16.0.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        '${BlogsCubit.get(context).blogs[index].user?.name}',
                        style: TextStyle(
                          fontSize: 13.0.sp,
                          color: Colors.grey[400],
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Gap10(),
            Container(
              padding: EdgeInsets.symmetric(vertical: 10.h),
              child: Text(
                '${BlogsCubit.get(context).blogs[index].title}',
                style: TextStyle(
                  fontSize: 14.0.sp,
                  color: Colors.white.withOpacity(0.9),
                  height: 1.6,
                  letterSpacing: 0.3,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Gap10(),
            Container(
              padding: EdgeInsets.only(top: 10.h),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(5.r),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          Iconsax.activity,
                          color: Colors.red[400],
                          size: 18.sp,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14.sp,
                        color: Colors.grey[400],
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '2 hours ago',
                        style: TextStyle(
                          fontSize: 13.0.sp,
                          color: Colors.grey[300],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
