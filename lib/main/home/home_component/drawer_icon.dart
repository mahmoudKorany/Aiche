import 'package:aiche/main/home/home_cubit/layout_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

class DrawerIcon extends StatelessWidget {
  const DrawerIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return  InkWell(
      onTap: () {
        LayoutCubit.get(context).scaffoldKey.currentState?.openDrawer();
      },
      child : Icon(
        Iconsax.menu_15,
        color: Colors.white,
        size: 25.sp,
      ),
    );
  }
}
