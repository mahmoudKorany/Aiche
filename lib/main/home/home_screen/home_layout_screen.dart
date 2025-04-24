import 'package:aiche/main/home/home_component/custom_drawer.dart';
import 'package:aiche/main/home/home_cubit/layout_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

class HomeLayoutScreen extends StatefulWidget {
  const HomeLayoutScreen({super.key});

  @override
  State<HomeLayoutScreen> createState() => _HomeLayoutScreenState();
}

class _HomeLayoutScreenState extends State<HomeLayoutScreen> {

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LayoutCubit, LayoutState>(
      listener: (context, state) {},
      builder: (context, state) {
        var layoutCubit = LayoutCubit.get(context);
        return Scaffold(
          key: layoutCubit.scaffoldKey,
          drawer: const CustomDrawer(),
          body: Stack(
            alignment: AlignmentDirectional.bottomCenter,
            children: [
              layoutCubit.screens[layoutCubit.currentIndex],
              Container(
                height: 96.h,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: const Color(0xff0C0341),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.r),
                    topRight: Radius.circular(30.r),
                  ),
                ),
                child: BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: const Color(0xff0C0341),
                  elevation: 20.0,
                  currentIndex: layoutCubit.currentIndex,
                  selectedItemColor: Colors.white,
                  unselectedItemColor: Colors.grey,
                  onTap: (int index) {
                    layoutCubit.changeBottomNavBar(index, context);
                  },
                  selectedLabelStyle: TextStyle(
                    fontSize: 12.sp,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontSize: 12.sp,
                  ),
                  items: <BottomNavigationBarItem>[
                    BottomNavigationBarItem(
                      icon: Icon(
                        Iconsax.home,
                        size: 24.sp,
                        color: Colors.grey,
                      ),
                      activeIcon: Icon(
                        Iconsax.home,
                        size: 24.sp,
                        color: Colors.white,
                      ),
                      label: 'Home',
                      tooltip: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(
                        Iconsax.activity,
                        size: 24.sp,
                        color: Colors.grey,
                      ),
                      activeIcon: Icon(
                        Iconsax.activity,
                        size: 24.sp,
                        color: Colors.white,
                      ),
                      label: 'Blogs',
                      tooltip: 'Blogs',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(
                        Icons.event,
                        size: 24.sp,
                        color: Colors.grey,
                      ),
                      activeIcon: Icon(
                        Icons.event,
                        size: 24.sp,
                        color: Colors.white,
                      ),
                      label: 'Events',
                      tooltip: 'Events',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(
                        Iconsax.task_square,
                        size: 24.sp,
                        color: Colors.grey,
                      ),
                      activeIcon: Icon(
                        Iconsax.task_square,
                        size: 24.sp,
                        color: Colors.white,
                      ),
                      label: 'Tasks',
                      tooltip: 'Tasks',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(
                        Iconsax.shop,
                        size: 24.sp,
                        color: Colors.grey,
                      ),
                      activeIcon: Icon(
                        Iconsax.shop,
                        size: 24.sp,
                        color: Colors.white,
                      ),
                      label: 'Shop',
                      tooltip: 'Shop',
                    ),
                  ],
                ),
              ),
            ],
          ),
          //bottomNavigationBar:,
        );
      },
    );
  }
}
