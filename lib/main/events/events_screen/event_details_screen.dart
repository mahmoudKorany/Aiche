import 'package:aiche/core/shared/components/components.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../events_model/event_model.dart' as event_models;

class EventDetailsScreen extends StatelessWidget {
  final event_models.EventModel eventModel;

  const EventDetailsScreen({super.key, required this.eventModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const BackGround(),
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 200.h,
                floating: false,
                pinned: true,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    eventModel.title ?? "",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Display the first image as the header
                      CachedNetworkImage(
                        imageUrl: eventModel.image?.isNotEmpty == true
                            ? eventModel.image![0].imagePath ?? ""
                            : "",
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2.w,
                          ),
                        ),
                        errorWidget: (context, url, error) =>
                            Icon(Icons.error, size: 24.sp),
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
                leading: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  child: const Pop(),
                ),
                actions: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 18.r,
                    child: IconButton(
                      icon:
                          Icon(Iconsax.share, color: Colors.black, size: 18.sp),
                      onPressed: () {
                        // Implement share functionality
                      },
                    ),
                  ),
                  SizedBox(width: 8.w),
                ],
              ),
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Event Images Gallery
                      if (eventModel.image != null &&
                          eventModel.image!.length > 1)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Event Gallery',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            SizedBox(
                              height: 120.h,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: eventModel.image!.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: EdgeInsets.only(right: 12.w),
                                    child: GestureDetector(
                                      onTap: () {
                                        _showPhotoGallery(context, index);
                                      },
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(12.r),
                                        child: SizedBox(
                                          width: 160.w,
                                          child: CachedNetworkImage(
                                            imageUrl: eventModel
                                                    .image![index].imagePath ??
                                                "",
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                Container(
                                              color: Colors.grey[800],
                                              child: Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2.w,
                                                ),
                                              ),
                                            ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Container(
                                              color: Colors.grey[800],
                                              child: Icon(Icons.error,
                                                  color: Colors.white,
                                                  size: 24.sp),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(height: 24.h),
                          ],
                        ),

                      // Event Status Card
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF111347).withOpacity(0.8),
                              const Color(0xFF12426F).withOpacity(0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildInfoItem(Icons.calendar_today,
                                    eventModel.startDate ?? ''),
                                _buildInfoItem(
                                    Icons.location_on, eventModel.place ?? ''),
                              ],
                            ),
                            SizedBox(height: 16.h),
                          ],
                        ),
                      ),
                      SizedBox(height: 24.h),

                      // Description
                      Text(
                        'About Event',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        eventModel.description ?? '',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16.sp,
                          height: 1.5,
                        ),
                      ),

                      SizedBox(height: 32.h),

                      // Register Button
                      SizedBox(
                        width: double.infinity,
                        height: 56.h,
                        child: ElevatedButton(
                          onPressed: () {
                            // Implement registration logic
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                          ),
                          child: Text(
                            'Register Now',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showPhotoGallery(BuildContext context, int initialIndex) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      builder: (context) => PhotoGalleryViewer(
        images: eventModel.image!,
        initialIndex: initialIndex,
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.7), size: 20.sp),
        SizedBox(width: 8.w),
        Text(
          text,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 14.sp,
          ),
        ),
      ],
    );
  }

  Color _getTagColor(String tag) {
    switch (tag.toLowerCase()) {
      case 'workshop':
        return Colors.blue;
      case 'technical':
        return Colors.purple;
      case 'social':
        return Colors.green;
      default:
        return Colors.orange;
    }
  }
}

class PhotoGalleryViewer extends StatefulWidget {
  final List<event_models.Image> images;
  final int initialIndex;

  const PhotoGalleryViewer({
    Key? key,
    required this.images,
    required this.initialIndex,
  }) : super(key: key);

  @override
  State<PhotoGalleryViewer> createState() => _PhotoGalleryViewerState();
}

class _PhotoGalleryViewerState extends State<PhotoGalleryViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white, size: 24.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${_currentIndex + 1}/${widget.images.length}',
          style: TextStyle(color: Colors.white, fontSize: 16.sp),
        ),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: PageView.builder(
          controller: _pageController,
          itemCount: widget.images.length,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          itemBuilder: (context, index) {
            return InteractiveViewer(
              minScale: 0.5,
              maxScale: 3.0,
              child: Center(
                child: CachedNetworkImage(
                  imageUrl: widget.images[index].imagePath ?? "",
                  placeholder: (context, url) => Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.w,
                    ),
                  ),
                  errorWidget: (context, url, error) => Icon(
                    Icons.error,
                    color: Colors.white,
                    size: 50.sp,
                  ),
                  fit: BoxFit.contain,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
