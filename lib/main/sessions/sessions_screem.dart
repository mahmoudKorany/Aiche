import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aiche/main/sessions/model/session_model.dart';
import 'package:aiche/main/home/home_cubit/layout_cubit.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:aiche/core/shared/components/components.dart';

class SessionsScreen extends StatefulWidget {
  const SessionsScreen({Key? key}) : super(key: key);

  @override
  State<SessionsScreen> createState() => _SessionsScreenState();
}

class _SessionsScreenState extends State<SessionsScreen> {
  bool _isMembershipInactive = false; // Start as active; will switch on 403

  @override
  void initState() {
    super.initState();
    // Fetch sessions when the screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      LayoutCubit.get(context).getUserSessions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          const BackGround(),

          // Main content
          Padding(
            padding: EdgeInsets.all(16.0.r),
            child: RefreshIndicator(
              onRefresh: () async {
                // Try again on pull-to-refresh
                setState(() {
                  _isMembershipInactive = false;
                });
                await LayoutCubit.get(context).getUserSessions();
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 50.h),

                  // Header with drawer icon
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Pop(),
                      SizedBox(width: 10.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sessions',
                            style: TextStyle(
                              fontSize: 20.0.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          BlocBuilder<LayoutCubit, LayoutState>(
                            builder: (context, state) {
                              final sessions =
                                  LayoutCubit.get(context).userSessions;
                              if (_isMembershipInactive) {
                                return Text(
                                  'Access restricted',
                                  style: TextStyle(
                                    fontSize: 12.0.sp,
                                    color: Colors.orange.withOpacity(0.8),
                                  ),
                                );
                              }
                              return Text(
                                '${sessions.length} sessions available',
                                style: TextStyle(
                                  fontSize: 12.0.sp,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      // Removed test button
                    ],
                  ),

                  SizedBox(height: 16.h),

                  // Sessions list
                  Expanded(
                    child: BlocConsumer<LayoutCubit, LayoutState>(
                      listener: (context, state) {
                        if (state is LayoutGetUserSessionsError) {
                          // Check if the error is related to inactive membership
                          if (state.error
                                  .toLowerCase()
                                  .contains('membership') &&
                              state.error.toLowerCase().contains('inactive')) {
                            setState(() {
                              _isMembershipInactive = true;
                            });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Could not load sessions: ${state.error}'),
                                backgroundColor: Colors.red,
                                duration: const Duration(seconds: 4),
                                action: SnackBarAction(
                                  label: 'Retry',
                                  textColor: Colors.white,
                                  onPressed: () {
                                    LayoutCubit.get(context).getUserSessions();
                                  },
                                ),
                              ),
                            );
                          }
                        }
                      },
                      builder: (context, state) {
                        final sessions = LayoutCubit.get(context).userSessions;

                        if (state is LayoutGetUserSessionsLoading) {
                          return _buildLoadingShimmer();
                        }

                        // Show membership inactive state by default
                        if (_isMembershipInactive) {
                          return _buildMembershipInactiveState();
                        }

                        if (sessions.isEmpty) {
                          return _buildEmptyState();
                        }

                        return ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          padding: EdgeInsets.zero,
                          itemCount: sessions.length,
                          itemBuilder: (context, index) {
                            final session = sessions[index];
                            return TweenAnimationBuilder(
                              duration:
                                  Duration(milliseconds: 300 + (index * 100)),
                              tween: Tween<double>(begin: 0, end: 1),
                              builder: (context, double value, child) {
                                return Transform.translate(
                                  offset: Offset(0, 32.h * (1 - value)),
                                  child: Opacity(
                                    opacity: value,
                                    child: SessionCard(session: session),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
            'No sessions available',
            style: TextStyle(
              fontSize: 18.sp,
              color: Colors.white.withOpacity(0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Check back later for upcoming sessions',
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
      padding: EdgeInsets.zero,
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300.withOpacity(0.3),
          highlightColor: Colors.grey.shade100.withOpacity(0.5),
          child: Container(
            margin: EdgeInsets.only(bottom: 16.h),
            height: 200.h,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20.0.r),
            ),
            child: Column(
              children: [
                // Session Header Shimmer
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

                // Session Body Shimmer
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
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMembershipInactiveState() {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated warning icon
            TweenAnimationBuilder(
              duration: const Duration(milliseconds: 800),
              tween: Tween<double>(begin: 0, end: 1),
              builder: (context, double value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: 100.r,
                    height: 100.r,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.orange.withOpacity(0.3),
                          Colors.red.withOpacity(0.3),
                        ],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.orange.withOpacity(0.5),
                        width: 2.r,
                      ),
                    ),
                    child: Icon(
                      Icons.warning_amber_rounded,
                      size: 56.r,
                      color: Colors.orange[300],
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 24.h),
            Text(
              'Access Restricted',
              style: TextStyle(
                fontSize: 22.sp,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              child: Text(
                'Your membership in this committee is currently inactive. Please contact an administrator to restore your access to sessions.',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.white.withOpacity(0.7),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 32.h),

            // Action buttons
            Column(
              children: [
                SizedBox(
                  width: 200.w,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _isMembershipInactive = false;
                      });
                      LayoutCubit.get(context).getUserSessions();
                    },
                    icon: Icon(
                      Icons.refresh_rounded,
                      size: 20.r,
                    ),
                    label: Text(
                      'Try Again',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue.shade600,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 3,
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                SizedBox(
                  width: 200.w,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Navigate back or to contact page
                      Navigator.of(context).pop();
                    },
                    icon: Icon(
                      Icons.arrow_back_rounded,
                      size: 20.r,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    label: Text(
                      'Go Back',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      side: BorderSide(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5.r,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),

            // Additional help text
            Container(
              margin: EdgeInsets.symmetric(horizontal: 24.w),
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: Colors.blue.withOpacity(0.3),
                  width: 1.r,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: Colors.blue[300],
                    size: 24.r,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'If you believe this is an error, please contact your committee administrator.',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.white.withOpacity(0.8),
                        height: 1.4,
                      ),
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
}

class SessionCard extends StatelessWidget {
  final SessionModel session;

  const SessionCard({
    Key? key,
    required this.session,
  }) : super(key: key);

  // Format date to a more readable format
  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return 'N/A';
    }

    try {
      final date = DateTime.parse(dateString);
      return DateFormat('EEEE, MMM d, yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  // Launch URL when tapped
  Future<void> _launchUrl(String? url) async {
    if (url == null || url.isEmpty) {
      return;
    }

    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF111347).withOpacity(0.8),
            const Color(0xFF12426F).withOpacity(0.8),
            const Color(0xFF180438).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20.0.r),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1.r,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Session Header
          _buildSessionHeader(),

          // Session Body with Description
          _buildSessionBody(),

          // Session Footer with Date and Link
          if (session.date != null || session.link != null)
            _buildSessionFooter(),
        ],
      ),
    );
  }

  Widget _buildSessionHeader() {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0.r),
          topRight: Radius.circular(20.0.r),
        ),
      ),
      child: Row(
        children: [
          // Session icon
          Container(
            width: 48.r,
            height: 48.r,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.school_rounded,
              color: Colors.blue[300],
              size: 28.r,
            ),
          ),
          SizedBox(width: 16.w),

          // Session title and user details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.title ?? 'Untitled Session',
                  style: TextStyle(
                    fontSize: 18.0.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (session.user != null && session.user!.name != null)
                  Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        'By ${session.user!.name}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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

  Widget _buildSessionBody() {
    if (session.description == null || session.description!.isEmpty) {
      return SizedBox(height: 16.h);
    }

    return Padding(
      padding: EdgeInsets.all(16.r),
      child: Text(
        session.description!,
        style: TextStyle(
          fontSize: 15.sp,
          color: Colors.white.withOpacity(0.85),
          height: 1.5,
        ),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildSessionFooter() {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20.0.r),
          bottomRight: Radius.circular(20.0.r),
        ),
      ),
      child: Column(
        children: [
          if (session.date != null)
            Row(
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
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    _formatDate(session.date),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          if (session.date != null && session.link != null)
            SizedBox(height: 16.h),
          if (session.link != null && session.link!.isNotEmpty)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _launchUrl(session.link),
                icon: Icon(
                  Icons.videocam_rounded,
                  size: 18.r,
                ),
                label: Text(
                  'Join Session',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue.shade600,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 2,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
