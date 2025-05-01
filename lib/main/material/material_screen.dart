import 'package:aiche/core/shared/components/components.dart';
import 'package:aiche/core/shared/components/gaps.dart';
import 'package:aiche/main/home/home_cubit/layout_cubit.dart';
import 'package:aiche/main/home/model/material_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shimmer/shimmer.dart';

class MaterialScreen extends StatefulWidget {
  const MaterialScreen({super.key});

  @override
  State<MaterialScreen> createState() => _MaterialScreenState();
}

class _MaterialScreenState extends State<MaterialScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Simplify animations by removing controllers that aren't essential
  // Removed: final List<AnimationController> _itemAnimationControllers = [];

  String? _selectedDepartment;
  String? _selectedSemester;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600), // Reduced from 800ms
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuint,
    ));

    // Simplified scroll listener with less work

    _animationController.forward();

    _selectedDepartment = null;
    _selectedSemester = null;
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    // Removed disposal of item animation controllers
    super.dispose();
  }

  // Simplified scroll effect

  // Filter materials based on search, department and semester
  List<MaterialModel> _filterMaterials(List<MaterialModel> materials) {
    if (materials.isEmpty) return [];

    return materials.where((material) {
      // Apply search filter
      final searchMatch = _searchController.text.isEmpty ||
          (material.name
                  ?.toLowerCase()
                  .contains(_searchController.text.toLowerCase()) ??
              false);

      // Apply department filter
      final departmentMatch = _selectedDepartment == null ||
          _selectedDepartment == 'All' ||
          material.department == _selectedDepartment;

      // Apply semester filter
      final semesterMatch = _selectedSemester == null ||
          _selectedSemester == 'All' ||
          material.semester == _selectedSemester;

      return searchMatch && departmentMatch && semesterMatch;
    }).toList();
  }

  // Get unique departments from materials list
  List<String> _getUniqueDepartments(List<MaterialModel> materials) {
    final Set<String> departmentSet = {};

    // Only add non-null, non-empty departments
    for (var material in materials) {
      if (material.department != null && material.department!.isNotEmpty) {
        departmentSet.add(material.department!);
      }
    }

    final departments = departmentSet.toList();
    departments.insert(0, 'All');
    return departments;
  }

  // Get unique semesters from materials list
  List<String> _getUniqueSemesters(List<MaterialModel> materials) {
    final Set<String> semesterSet = {};

    // Only add non-null, non-empty semesters
    for (var material in materials) {
      if (material.semester != null && material.semester!.isNotEmpty) {
        semesterSet.add(material.semester!);
      }
    }

    final semesters = semesterSet.toList();
    semesters.insert(0, 'All');
    return semesters;
  }

  // Launch URL for material
  Future<void> _launchUrl(String? url) async {
    if (url == null || url.isEmpty) return;

    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // Show snackbar if URL couldn't be launched
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open the link'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for better responsiveness
    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 360;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: BlocConsumer<LayoutCubit, LayoutState>(
        listener: (context, state) {
          // Handle state changes if needed
        },
        builder: (context, state) {
          var layoutCubit = LayoutCubit.get(context);
          var materials = layoutCubit.materialList;

          // Get the filtered departments and semesters BEFORE using them
          var departments = _getUniqueDepartments(materials);
          var semesters = _getUniqueSemesters(materials);

          // Make sure selected values exist in the lists, or nullify them
          if (_selectedDepartment != null &&
              !departments.contains(_selectedDepartment)) {
            _selectedDepartment = null;
          }

          if (_selectedSemester != null &&
              !semesters.contains(_selectedSemester)) {
            _selectedSemester = null;
          }

          var filteredMaterials = _filterMaterials(materials);

          return Stack(
            children: [
              const BackGround(),
              Scaffold(
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  title: Text(
                    'Study Materials',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  elevation: 0,
                  centerTitle: true,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  systemOverlayStyle: SystemUiOverlayStyle.light,
                ),
                body: SafeArea(
                  child: Column(
                    children: [
                      // Search bar with simplified animation
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Search materials...',
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: HexColor('#03172C').withOpacity(0.6),
                                ),
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear),
                                        onPressed: () {
                                          setState(() {
                                            _searchController.clear();
                                          });
                                        },
                                      )
                                    : null,
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 15.h,
                                  horizontal: 10.w,
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  // Simply update UI when search text changes
                                });
                              },
                            ),
                          ),
                        ),
                      ),

                      // Filters row with simplified animations
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(12.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        spreadRadius: 1,
                                        blurRadius: 5,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: DropdownButtonFormField<String>(
                                    decoration: InputDecoration(
                                      labelText: 'Department',
                                      labelStyle: TextStyle(
                                        fontSize: isSmallScreen ? 12.sp : 14.sp,
                                        color: HexColor('#03172C')
                                            .withOpacity(0.7),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(12.r),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: isSmallScreen ? 4.w : 4.w,
                                        vertical: isSmallScreen ? 6.h : 8.h,
                                      ),
                                    ),
                                    value: _selectedDepartment,
                                    items: departments.map((String department) {
                                      return DropdownMenuItem<String>(
                                        value: department,
                                        child: Text(
                                          department,
                                          style: TextStyle(
                                              fontSize: isSmallScreen
                                                  ? 12.sp
                                                  : 14.sp),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedDepartment = value;
                                      });
                                    },
                                    icon: Icon(
                                      Icons.arrow_drop_down_circle,
                                      color:
                                          HexColor('#03172C').withOpacity(0.5),
                                      size: 20.sp,
                                    ),
                                    dropdownColor:
                                        Colors.white.withOpacity(0.95),
                                  ),
                                ),
                              ),
                              const Gap15(isHorizontal: true),
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(12.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        spreadRadius: 1,
                                        blurRadius: 5,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: DropdownButtonFormField<String>(
                                    decoration: InputDecoration(
                                      labelText: 'Semester',
                                      labelStyle: TextStyle(
                                        fontSize: isSmallScreen ? 12.sp : 14.sp,
                                        color: HexColor('#03172C')
                                            .withOpacity(0.7),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(12.r),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: isSmallScreen ? 8.w : 12.w,
                                        vertical: isSmallScreen ? 6.h : 8.h,
                                      ),
                                    ),
                                    value: _selectedSemester,
                                    items: semesters.map((String semester) {
                                      return DropdownMenuItem<String>(
                                        value: semester,
                                        child: Text(
                                          semester,
                                          style: TextStyle(
                                              fontSize: isSmallScreen
                                                  ? 12.sp
                                                  : 14.sp),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedSemester = value;
                                      });
                                    },
                                    icon: Icon(
                                      Icons.arrow_drop_down_circle,
                                      color:
                                          HexColor('#03172C').withOpacity(0.5),
                                      size: 20.sp,
                                    ),
                                    dropdownColor:
                                        Colors.white.withOpacity(0.95),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const Gap15(),
                      // Materials list with enhanced scrolling and responsiveness
                      Expanded(
                        child: state is LayoutGetMaterialLoading
                            ? _buildLoadingShimmer()
                            : filteredMaterials.isEmpty
                                ? _buildEmptyState()
                                : RefreshIndicator(
                                    onRefresh: () async {
                                      await layoutCubit.getMaterial();
                                    },
                                    color: HexColor('#03172C'),
                                    child: ListView.builder(
                                      controller: _scrollController,
                                      physics:
                                          const AlwaysScrollableScrollPhysics(
                                        parent: BouncingScrollPhysics(),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16.w,
                                        vertical: 8.h,
                                      ),
                                      itemCount: filteredMaterials.length,
                                      itemBuilder: (context, index) {
                                        var material = filteredMaterials[index];
                                        return _buildMaterialCard(material);
                                      },
                                    ),
                                  ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMaterialCard(MaterialModel material) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          margin: EdgeInsets.only(bottom: 16.h),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _launchUrl(material.link),
              borderRadius: BorderRadius.circular(12.r),
              splashColor: HexColor('#03172C').withOpacity(0.1),
              highlightColor: HexColor('#03172C').withOpacity(0.05),
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Material icon with improved visuals
                        Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: HexColor('#03172C').withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Hero(
                            tag: 'material_${material.name}',
                            child: Image.asset(
                              'assets/images/material.png',
                              height: 32.h,
                              width: 32.w,
                            ),
                          ),
                        ),
                        const Gap15(isHorizontal: true),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                material.name ?? 'Unknown',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.sp,
                                  color: HexColor('#03172C'),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Gap5(),
                              Text(
                                '${material.department ?? 'Unknown Department'} • ${material.semester ?? 'Unknown Semester'}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Gap10(isHorizontal: true),
                        // Static download button without animations
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: HexColor('#03172C').withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.download_rounded,
                            color: HexColor('#03172C'),
                            size: 24.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: 8,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(bottom: 16.h),
            height: 80.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 50.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Simplified static icon without complex animations
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.folder_open,
                  size: 80.sp,
                  color: Colors.white,
                ),
              ),
              const Gap15(),
              // Simple fade transition for the text
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'No materials found',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Gap10(),
              // Simple fade transition for the subtitle
              FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                  child: Text(
                    'Try adjusting your filters',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const Gap20(),
              // Simple button without complex animations
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _searchController.clear();
                    _selectedDepartment = null;
                    _selectedSemester = null;
                  });
                },
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: Text(
                  'Reset Filters',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: HexColor('#03172C').withOpacity(0.6),
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
