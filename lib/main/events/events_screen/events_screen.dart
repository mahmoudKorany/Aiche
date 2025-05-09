import 'package:aiche/core/shared/components/components.dart';
import 'package:aiche/core/shared/functions/functions.dart';
import 'package:aiche/main/events/events_cubit/events_cubit.dart';
import 'package:aiche/main/events/events_cubit/events_state.dart';
import 'package:aiche/main/events/events_model/event_model.dart';
import 'package:aiche/main/events/events_screen/event_details_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../home/home_component/drawer_icon.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EventsCubit, EventsState>(
      listener: (context, state) {},
      builder: (context, state) {
        var cubit = EventsCubit.get(context);
        return Scaffold(
          body: Stack(
            children: [
              const BackGround(),
              Padding(
                padding: EdgeInsets.all(16.0.r),
                child: RefreshIndicator(
                  onRefresh: () async {
                    await cubit.fetchEvents();
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 50.h),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const DrawerIcon(),
                          SizedBox(width: 10.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Upcoming Events',
                                style: TextStyle(
                                  fontSize: 20.0.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                '${cubit.events.length} events available',
                                style: TextStyle(
                                  fontSize: 12.0.sp,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      Expanded(
                        child: state is EventsLoading
                            ? _buildLoadingShimmer()
                            : cubit.events.isEmpty
                                ? _buildEmptyState()
                                : ListView.builder(
                                    physics: const BouncingScrollPhysics(),
                                    padding: EdgeInsets.only(top: 10.0.h),
                                    itemCount: cubit.events.length,
                                    itemBuilder: (context, index) {
                                      final event = cubit.events[index];
                                      return Hero(
                                        tag: 'event-${event.id}',
                                        child: Container(
                                          margin: EdgeInsets.symmetric(
                                              vertical: 8.0.h,
                                              horizontal: 4.0.w),
                                          child: InkWell(
                                            onTap: () {
                                              navigateTo(
                                                context: context,
                                                widget: EventDetailsScreen(
                                                  eventModel: event,
                                                ),
                                              );
                                            },
                                            child: TweenAnimationBuilder(
                                              duration: const Duration(
                                                  milliseconds: 300),
                                              tween: Tween<double>(
                                                  begin: 0, end: 1),
                                              builder: (context, double value,
                                                  child) {
                                                return Transform.translate(
                                                  offset: Offset(
                                                      0, 32.h * (1 - value)),
                                                  child: Opacity(
                                                    opacity: value,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        gradient:
                                                            LinearGradient(
                                                          begin:
                                                              Alignment.topLeft,
                                                          end: Alignment
                                                              .bottomRight,
                                                          colors: [
                                                            const Color(
                                                                    0xFF111347)
                                                                .withOpacity(
                                                                    0.8),
                                                            const Color(
                                                                    0xFF12426F)
                                                                .withOpacity(
                                                                    0.8),
                                                            const Color(
                                                                    0xFF180438)
                                                                .withOpacity(
                                                                    0.8),
                                                          ],
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    20.0.r),
                                                        border: Border.all(
                                                          color: Colors.white
                                                              .withOpacity(0.1),
                                                          width: 1.r,
                                                        ),
                                                      ),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          // Event Header with Image
                                                          _buildEventHeader(
                                                              event),

                                                          // Event Description
                                                          Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    16.0.r),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  event.description ??
                                                                      '',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        15.0.sp,
                                                                    color: Colors
                                                                        .white
                                                                        .withOpacity(
                                                                            0.85),
                                                                    height: 1.5,
                                                                  ),
                                                                  maxLines: 3,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                                SizedBox(
                                                                    height:
                                                                        16.0.h),
                                                                Wrap(
                                                                  spacing:
                                                                      8.0.w,
                                                                  children: [
                                                                    if (event
                                                                            .category !=
                                                                        null)
                                                                      Chip(
                                                                        label: Text(
                                                                            event.category!),
                                                                        backgroundColor: Colors
                                                                            .blue
                                                                            .withOpacity(0.7),
                                                                        labelStyle:
                                                                            TextStyle(
                                                                          color:
                                                                              Colors.white,
                                                                          fontSize:
                                                                              12.sp,
                                                                        ),
                                                                      ),
                                                                    if (event
                                                                            .status !=
                                                                        null)
                                                                      Chip(
                                                                        label: Text(
                                                                            event.status!),
                                                                        backgroundColor: Colors
                                                                            .green
                                                                            .withOpacity(0.7),
                                                                        labelStyle:
                                                                            TextStyle(
                                                                          color:
                                                                              Colors.white,
                                                                          fontSize:
                                                                              12.sp,
                                                                        ),
                                                                      ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),

                                                          // Event Footer Info
                                                          _buildEventFooter(
                                                              event),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                      ),
                      SizedBox(height: 85.h)
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEventHeader(EventModel event) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16.0.w,
        vertical: 12.0.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0.r),
          topRight: Radius.circular(20.0.r),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Event image or placeholder
          Container(
            width: 48.r,
            height: 48.r,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              color: Colors.blue.withOpacity(0.2),
            ),
            clipBehavior: Clip.antiAlias,
            child: event.image != null &&
                    event.image!.isNotEmpty &&
                    event.image!.first.imagePath != null
                ? CachedNetworkImage(
                    imageUrl: event.image!.first.imagePath!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Center(
                      child: SizedBox(
                        width: 24.r,
                        height: 24.r,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.r,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Icon(
                      Icons.event,
                      color: Colors.blue,
                      size: 28.r,
                    ),
                  )
                : Icon(
                    Icons.event,
                    color: Colors.blue,
                    size: 28.r,
                  ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title ?? 'Untitled Event',
                  style: TextStyle(
                    fontSize: 18.0.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.0.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.0.w,
                    vertical: 4.0.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12.0.r),
                  ),
                  child: Text(
                    event.status ?? "Upcoming",
                    style: TextStyle(
                      fontSize: 12.0.sp,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventFooter(EventModel event) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 12.h,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20.0.r),
          bottomRight: Radius.circular(20.0.r),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.calendar_today_rounded,
                      size: 16.r,
                      color: Colors.blue[300],
                    ),
                  ),
                  SizedBox(width: 12.0.w),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Date",
                          style: TextStyle(
                            fontSize: 12.0.sp,
                            color: Colors.white.withOpacity(0.6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          event.startDate ?? '',
                          style: TextStyle(
                            fontSize: 14.0.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            VerticalDivider(
              color: Colors.white.withOpacity(0.2),
              thickness: 1.r,
              width: 32.w,
            ),
            Expanded(
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.location_on_rounded,
                      size: 16.r,
                      color: Colors.purple[300],
                    ),
                  ),
                  SizedBox(width: 12.0.w),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Location',
                          style: TextStyle(
                            fontSize: 12.0.sp,
                            color: Colors.white.withOpacity(0.6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          event.place ?? '',
                          style: TextStyle(
                            fontSize: 14.0.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Shimmer effect for the empty state icon
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300.withOpacity(0.3),
            highlightColor: Colors.grey.shade100.withOpacity(0.5),
            child: Container(
              width: 80.r,
              height: 80.r,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.event_busy,
                size: 48.r,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'No events available',
            style: TextStyle(
              fontSize: 18.sp,
              color: Colors.white.withOpacity(0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Check back later for upcoming events',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.white.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(top: 10.0.h),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300.withOpacity(0.3),
          highlightColor: Colors.grey.shade100.withOpacity(0.5),
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 8.0.h, horizontal: 4.0.w),
            height: 220.h,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20.0.r),
            ),
            child: Column(
              children: [
                // Event Header Shimmer
                Container(
                  height: 70.h,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.0.r),
                      topRight: Radius.circular(20.0.r),
                    ),
                  ),
                  padding: EdgeInsets.all(16.0.r),
                  child: Row(
                    children: [
                      Container(
                        width: 40.r,
                        height: 40.r,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 150.w,
                            height: 16.h,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          SizedBox(height: 8.h),
                          Container(
                            width: 80.w,
                            height: 12.h,
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Event Body Shimmer
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(16.0.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 12.h,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        SizedBox(height: 8.h),
                        Container(
                          width: double.infinity,
                          height: 12.h,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        SizedBox(height: 8.h),
                        Container(
                          width: 200.w,
                          height: 12.h,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        SizedBox(height: 16.h),
                      ],
                    ),
                  ),
                ),

                // Event Footer Shimmer
                Container(
                  height: 50.h,
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20.0.r),
                      bottomRight: Radius.circular(20.0.r),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              width: 30.r,
                              height: 30.r,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Container(
                              width: 60.w,
                              height: 20.h,
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 1.w,
                        height: 30.h,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              width: 30.r,
                              height: 30.r,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Container(
                              width: 60.w,
                              height: 20.h,
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
