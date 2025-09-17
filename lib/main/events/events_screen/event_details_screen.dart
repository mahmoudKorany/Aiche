import 'package:aiche/core/shared/components/components.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

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
                      // Display the first image as the header with better null checking
                      _buildHeaderImage(),
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
                      icon: Icon(Icons.share, color: Colors.black, size: 18.sp),
                      onPressed: () {
                        _shareEvent(context);
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
                      // Status & Category Tags
                      if (eventModel.status != null ||
                          eventModel.category != null)
                        Wrap(
                          spacing: 8.w,
                          children: [
                            if (eventModel.status != null)
                              _buildTag(eventModel.status!, Colors.blue),
                            if (eventModel.category != null)
                              _buildTag(eventModel.category!,
                                  _getTagColor(eventModel.category!)),
                          ],
                        ),
                      SizedBox(height: 16.h),

                      // Event Images Gallery - Show for all events with images
                      if (eventModel.image != null &&
                          eventModel.image!.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              eventModel.image!.length > 1
                                  ? 'Event Gallery'
                                  : 'Event Image',
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
                                physics: const BouncingScrollPhysics(),
                                scrollDirection: Axis.horizontal,
                                itemCount: eventModel.image!.length,
                                itemBuilder: (context, index) {
                                  final imageUrl =
                                      eventModel.image![index].imagePath;

                                  // Skip images with null or empty URLs
                                  if (imageUrl == null || imageUrl.isEmpty) {
                                    return const SizedBox.shrink();
                                  }

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
                                            imageUrl: imageUrl,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                Container(
                                              color: Colors.grey[800],
                                              child: Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2.w,
                                                  color: Colors.white,
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
                            _buildDateDisplay(
                                eventModel.startDate, eventModel.endDate),

                            // Location info
                            _buildInfoItem(
                                Icons.location_on, eventModel.place ?? 'TBA'),

                            if (eventModel.facebookLink != null &&
                                eventModel.facebookLink!.isNotEmpty)
                              Padding(
                                padding: EdgeInsets.only(top: 16.h),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    icon: Icon(Icons.facebook,
                                        color: Colors.white, size: 20.sp),
                                    label: Text(
                                      'View on Facebook',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                          color: Colors.white.withOpacity(0.3)),
                                      padding:
                                          EdgeInsets.symmetric(vertical: 12.h),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.r),
                                      ),
                                    ),
                                    onPressed: () =>
                                        _launchUrl(eventModel.facebookLink),
                                  ),
                                ),
                              ),
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

                      // Register Button - only show if formLink is available
                      if (eventModel.formLink != null &&
                          eventModel.formLink!.isNotEmpty &&
                          eventModel.status != 'closed')
                        SizedBox(
                          width: double.infinity,
                          height: 56.h,
                          child: ElevatedButton(
                            onPressed: () {
                              _launchUrl(eventModel.formLink);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E88E5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              elevation: 8,
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.7), size: 20.sp),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14.sp,
              height: 1.4,
            ),
            overflow: TextOverflow.visible,
            maxLines: 3,
          ),
        ),
      ],
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
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
      case 'academic':
        return Colors.amber;
      default:
        return Colors.orange;
    }
  }

  String _formatDateRange(String? start, String? end) {
    if (start == null) return 'TBA';

    try {
      // Parse the date strings to DateTime objects
      final DateTime startDate = DateTime.parse(start);
      final DateTime? endDate = end != null ? DateTime.parse(end) : null;

      // Format for displaying date with time
      final DateFormat fullFormat = DateFormat('MMM d, yyyy · h:mm a');
      final DateFormat dateOnlyFormat = DateFormat('MMM d, yyyy');

      // Check if the dates are on the same day
      if (endDate != null) {
        if (startDate.year == endDate.year &&
            startDate.month == endDate.month &&
            startDate.day == endDate.day) {
          // Same day event (e.g., "May 15, 2025 · 9:00 AM - 5:00 PM")
          return '${dateOnlyFormat.format(startDate)} · ${DateFormat('h:mm a').format(startDate)} - ${DateFormat('h:mm a').format(endDate)}';
        } else {
          // Multi-day event (e.g., "May 15 - May 17, 2025")
          return '${DateFormat('MMM d').format(startDate)} - ${dateOnlyFormat.format(endDate)}';
        }
      }

      // Single date with time if available
      return fullFormat.format(startDate);
    } catch (e) {
      // Fallback to original strings if parsing fails
      if (end == null || start == end) return start;
      return '$start - $end';
    }
  }

  Future<void> _launchUrl(String? url) async {
    if (url == null || url.isEmpty) return;

    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _shareEvent(BuildContext context) {
    final String text = 'Check out this event: ${eventModel.title}\n'
        '${eventModel.description?.substring(0, eventModel.description!.length > 100 ? 100 : eventModel.description!.length)}...\n'
        'Date: ${_formatDateRange(eventModel.startDate, eventModel.endDate)}\n'
        'Location: ${eventModel.place}\n\n'
        '${eventModel.formLink != null ? 'Register here: ${eventModel.formLink}' : ''}';

    Share.share(text);
  }

  // Create a dedicated date display widget
  Widget _buildDateDisplay(String? startDate, String? endDate) {
    final formattedDate = _formatDateRange(startDate, endDate);

    return Container(
      margin: EdgeInsets.only(top: 12.h, bottom: 16.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.event,
            color: Colors.blue.withOpacity(0.9),
            size: 24.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Event Date & Time',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  formattedDate,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build header image with proper null checking and fallback
  Widget _buildHeaderImage() {
    // Check if we have images and the first image has a valid URL
    if (eventModel.image != null &&
        eventModel.image!.isNotEmpty &&
        eventModel.image![0].imagePath != null &&
        eventModel.image![0].imagePath!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: eventModel.image![0].imagePath!,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[800],
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2.w,
              color: Colors.white,
            ),
          ),
        ),
        errorWidget: (context, url, error) => _buildFallbackHeader(),
      );
    } else {
      return _buildFallbackHeader();
    }
  }

  // Fallback header when no image is available
  Widget _buildFallbackHeader() {
    return Container(
      color: const Color(0xFF111347),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event,
              color: Colors.white.withOpacity(0.7),
              size: 48.sp,
            ),
            SizedBox(height: 8.h),
            Text(
              'Event Image',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
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
    // Filter out images with null or empty URLs
    final validImages = widget.images
        .where(
            (image) => image.imagePath != null && image.imagePath!.isNotEmpty)
        .toList();

    if (validImages.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: Icon(Icons.close, color: Colors.white, size: 24.sp),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_not_supported,
                color: Colors.white.withOpacity(0.7),
                size: 64.sp,
              ),
              SizedBox(height: 16.h),
              Text(
                'No images available',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 16.sp,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white, size: 24.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${_currentIndex + 1}/${validImages.length}',
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
          itemCount: validImages.length,
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
                  imageUrl: validImages[index].imagePath!,
                  placeholder: (context, url) => Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.w,
                    ),
                  ),
                  errorWidget: (context, url, error) => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.white,
                        size: 50.sp,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Failed to load image',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
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
