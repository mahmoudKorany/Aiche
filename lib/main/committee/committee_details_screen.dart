import 'dart:io';
import 'package:aiche/core/shared/components/components.dart';
import 'package:aiche/core/shared/components/gaps.dart';
import 'package:aiche/core/shared/functions/functions.dart';
import 'package:aiche/main/committee/model/committee_model.dart';
import 'package:aiche/main/committee/profile/profile_screen.dart';
import 'package:aiche/main/home/home_cubit/layout_cubit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class CommitteeDetailsScreen extends StatefulWidget {
  final CommitteeModel committee;

  const CommitteeDetailsScreen({
    Key? key,
    required this.committee,
  }) : super(key: key);

  @override
  State<CommitteeDetailsScreen> createState() => _CommitteeDetailsScreenState();
}

class _CommitteeDetailsScreenState extends State<CommitteeDetailsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutQuint),
      ),
    );

    // Start the animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Helper function to launch URLs
  Future<void> _launchUrl(String? url) async {
    if (url == null || url.isEmpty) return;

    final Uri uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

  // Share committee information
  void _shareCommittee() {
    final String shareText =
        'Check out the ${widget.committee.name} committee at AIChE!\n\n'
        '${widget.committee.description}\n\n'
        'Join us and be part of our journey!';

    Share.share(shareText);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            // Gradient background
            const BackGround(),

            // Animated background circles for visual appeal
            _buildAnimatedBackgroundCircles(),

            // Main content
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // App bar with committee name
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  expandedHeight: 220.h,
                  floating: false,
                  pinned: true,
                  stretch: true,
                  leading: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      margin: EdgeInsets.only(left: 16.w),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 22.sp,
                      ),
                    ),
                  ),
                  actions: [
                    // Share button
                    GestureDetector(
                      onTap: _shareCommittee,
                      child: Container(
                        margin: EdgeInsets.only(right: 16.w),
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.share,
                          color: Colors.white,
                          size: 22.sp,
                        ),
                      ),
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      widget.committee.name ?? 'Committee',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18.sp,
                        shadows: [
                          Shadow(
                            blurRadius: 4,
                            color: Colors.black.withOpacity(0.5),
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Committee image with gradient overlay
                        Hero(
                          tag: 'committee_${widget.committee.id}',
                          child: _buildCommitteeImage(),
                        ),

                        // Gradient overlay for better text readability
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.3),
                                Colors.black.withOpacity(0.7),
                              ],
                              stops: const [0.4, 0.75, 1.0],
                            ),
                          ),
                        ),
                      ],
                    ),
                    stretchModes: const [
                      StretchMode.zoomBackground,
                      StretchMode.blurBackground,
                    ],
                    centerTitle: true,
                  ),
                ),

                // Committee details content with animations
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Padding(
                          padding: EdgeInsets.all(20.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Committee stats/info row
                              _buildCommitteeStatsRow(),
                              const Gap10(),

                              // Committee description
                              _buildSectionTitle('About', Icons.info_outline),
                              const Gap10(),
                              _buildDescriptionCard(),
                              const Gap10(),

                              // Committee admins section
                              _buildSectionTitle(
                                  'Committee Admins', Icons.people),
                              const Gap10(),

                              widget.committee.admins == null ||
                                      widget.committee.admins!.isEmpty
                                  ? _buildEmptyAdminsMessage()
                                  : ListView.builder(
                                      padding: EdgeInsets.zero,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount:
                                          widget.committee.admins!.length,
                                      itemBuilder: (context, index) {
                                        final delay = 0.2 + (index * 0.1);
                                        return _buildAnimatedAdminCard(
                                          widget.committee.admins![index],
                                          delay,
                                        );
                                      },
                                    ),
                              const Gap10(),

                              // Join committee button
                              _buildJoinButton(),
                              const Gap10(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Build animated background circles for visual appeal
  Widget _buildAnimatedBackgroundCircles() {
    return Stack(
      children: [
        // Top-left circle
        Positioned(
          top: -50.h,
          left: -50.w,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              height: 200.h,
              width: 200.w,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),

        // Bottom-right circle
        Positioned(
          bottom: -80.h,
          right: -80.w,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              height: 250.h,
              width: 250.w,
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Build committee stats row (member count, etc.)
  Widget _buildCommitteeStatsRow() {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF111347).withOpacity(0.7),
            const Color(0xFF12426F).withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1.r,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Committee ID stat
            // _buildStatItem(
            //   'ID',
            //   '${widget.committee.id ?? "N/A"}',
            //   Icons.tag,
            //   Colors.blue.withOpacity(0.8),
            // ),

            // VerticalDivider(
            //   color: Colors.white.withOpacity(0.2),
            //   thickness: 1.r,
            //   width: 32.w,
            // ),

            // Admin count stat
            _buildStatItem(
              'Admins',
              '${widget.committee.admins?.length ?? 0}',
              Icons.people,
              Colors.purple.withOpacity(0.8),
            ),

            VerticalDivider(
              color: Colors.white.withOpacity(0.2),
              thickness: 1.r,
              width: 32.w,
            ),

            // Activity status
            _buildStatItem(
              'Status',
              'Active',
              Icons.check_circle,
              Colors.green.withOpacity(0.8),
            ),
          ],
        ),
      ),
    );
  }

  // Build a single stat item
  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 20.r,
          ),
        ),
        const Gap10(),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12.sp,
          ),
        ),
        const Gap5(),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // Build the committee image section
  Widget _buildCommitteeImage() {
    return widget.committee.img != null && widget.committee.img!.isNotEmpty
        ? CachedNetworkImage(
            imageUrl: widget.committee.img!,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: Colors.blue.withOpacity(0.2),
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.r,
                ),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.blue.withOpacity(0.2),
              child: Center(
                child: Image.asset(
                  'assets/images/committee.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          )
        : Container(
            color: Colors.blue.withOpacity(0.2),
            child: Center(
              child: Image.asset(
                'assets/images/committee.jpg',
                fit: BoxFit.cover,
              ),
            ),
          );
  }

  // Build section title with icon
  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20.r,
          ),
        ),
        const Gap10(isHorizontal: true),
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // Build committee description card
  Widget _buildDescriptionCard() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: Container(
        padding: EdgeInsets.all(16.r),
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
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1.r,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Description text
            Text(
              widget.committee.description ?? 'No description available.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16.sp,
                height: 1.5,
              ),
              maxLines: _isExpanded ? null : 5,
              overflow: _isExpanded ? null : TextOverflow.ellipsis,
            ),

            // Show more/less button
            if ((widget.committee.description?.length ?? 0) > 100)
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.only(top: 8.r),
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue.shade300,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _isExpanded ? 'Show Less' : 'Show More',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Icon(
                          _isExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          size: 16.r,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Build empty admins message
  Widget _buildEmptyAdminsMessage() {
    return Container(
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Icon(
            Icons.people_outline,
            color: Colors.white.withOpacity(0.5),
            size: 48.r,
          ),
          const Gap15(),
          Text(
            'No admins available for this committee.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16.sp,
            ),
          ),
        ],
      ),
    );
  }

  // Build animated admin card with delay
  Widget _buildAnimatedAdminCard(Admins admin, double delay) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: (500 * delay).toInt()),
      curve: Curves.easeOutQuart,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: _buildAdminCard(admin),
    );
  }

  // Build admin card
  Widget _buildAdminCard(Admins admin) {
    String? name = admin.name;
    if (name == 'superadmin' || name == 'admin') {
      name = 'AIChE SUSC';
    }
    String? title = admin.title;
    if (title == 'admim') {
      title = 'admin';
    }
    return Container(
      margin: EdgeInsets.only(bottom: 16.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF111347).withOpacity(0.7),
            const Color(0xFF12426F).withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1.r,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Admin header with image, name and title
          ListTile(
            onTap: () {
              navigateTo(
                  context: context,
                  widget: ProfileDetailScreen(
                    userModel: admin,
                  ));
            },
            contentPadding: EdgeInsets.all(16.r),
            leading: _buildAdminAvatar(admin),
            title: Shimmer.fromColors(
              baseColor: Colors.white,
              highlightColor: Colors.white.withOpacity(0.7),
              period: const Duration(seconds: 3),
              child: Text(
                name ?? 'Unknown',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp,
                ),
              ),
            ),
            subtitle: Padding(
              padding: EdgeInsets.only(top: 4.r),
              child: Text(
                title ?? 'Member',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14.sp,
                ),
              ),
            ),
          ),

          // Display admin profile details if available
          if (admin.profile != null) ...[
            // Divider
            Divider(
              color: Colors.white.withOpacity(0.1),
              thickness: 1,
              indent: 16.r,
              endIndent: 16.r,
            ),

            // Bio if available
            if (admin.profile!.bio != null && admin.profile!.bio!.isNotEmpty)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 8.r),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue.withOpacity(0.7),
                      size: 20.r,
                    ),
                    const Gap10(isHorizontal: true),
                    Expanded(
                      child: Text(
                        admin.profile!.bio!,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14.sp,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Phone if available
            if (admin.profile!.phone != null &&
                admin.profile!.phone!.isNotEmpty)
              InkWell(
                onTap: () => _launchUrl('tel:${admin.profile!.phone}'),
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.r, vertical: 8.r),
                  child: Row(
                    children: [
                      Icon(
                        Icons.phone,
                        color: Colors.green.withOpacity(0.7),
                        size: 20.r,
                      ),
                      const Gap10(isHorizontal: true),
                      Text(
                        admin.profile!.phone!,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Created at date if available
            if (admin.profile!.createdAt != null &&
                admin.profile!.createdAt!.isNotEmpty)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 8.r),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: Colors.amber.withOpacity(0.7),
                      size: 20.r,
                    ),
                    const Gap10(isHorizontal: true),
                    Text(
                      _formatDate(admin.profile!.createdAt!),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ),

            // LinkedIn button if available
            if (admin.profile!.linkedin != null &&
                admin.profile!.linkedin!.isNotEmpty)
              Padding(
                padding: EdgeInsets.all(16.r),
                child: InkWell(
                  onTap: () => _launchUrl(admin.profile!.linkedin),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 10.r, horizontal: 16.r),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: Colors.blue.withOpacity(0.3),
                        width: 1.r,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/linkedin.png',
                          height: 24.r,
                          width: 24.r,
                        ),
                        const Gap10(isHorizontal: true),
                        Text(
                          'View LinkedIn Profile',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  // Build admin avatar
  Widget _buildAdminAvatar(Admins admin) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 2.r,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.white,
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 30.r,
        backgroundColor: Colors.white,
        backgroundImage:
            admin.profile?.image != null && admin.profile!.image!.isNotEmpty
                ? CachedNetworkImageProvider(
                    admin.profile!.image!,
                  )
                : const AssetImage('assets/images/person.png') as ImageProvider,
      ),
    );
  }

  // Build join button
  Widget _buildJoinButton() {
    return Center(
      child: Container(
        width: 0.6.sw,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF111347), Color(0xFF12426F)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(30.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF111347).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: BlocConsumer<LayoutCubit, LayoutState>(
          listener: (context, state) {},
          builder: (context, state) {
            return ConditionalBuilder(
              condition: state is! LayoutRequestJoinLoading,
              fallback: (context) {
                if (Platform.isIOS) {
                  return const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(
                      child: CupertinoActivityIndicator(
                        radius: 20,
                        color: Colors.white,
                      ),
                    ),
                  );
                } else {
                  return const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(
                      child: SizedBox(
                        height: 50,
                        width: 50,
                        child: LoadingIndicator(
                          indicatorType: Indicator.ballRotateChase,
                          colors: [
                            Colors.white,
                          ],
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  );
                }
              },
              builder: (context) => ElevatedButton(
                onPressed: () {
                  LayoutCubit.get(context).requestJoinCommittee(
                    committeeId: widget.committee.id!,
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.r),
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_add,
                      size: 22.r,
                    ),
                    const Gap10(isHorizontal: true),
                    Text(
                      'Join Committee',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Format date string
  String _formatDate(String dateString) {
    try {
      final DateTime date = DateTime.parse(dateString);
      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return dateString;
    }
  }
}
