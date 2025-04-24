import 'package:aiche/auth/auth_cubit/auth_cubit.dart';
import 'package:aiche/core/shared/components/components.dart';
import 'package:aiche/core/shared/components/gaps.dart';
import 'package:aiche/core/shared/constants/constants.dart';
import 'package:aiche/core/shared/functions/functions.dart';
import 'package:aiche/main/home/home_screen/home_layout_screen.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:iconsax/iconsax.dart';

import '../auth_cubit/auth_state.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  var formKey = GlobalKey<FormState>();
  static var passwordController = TextEditingController();
  static var emailController = TextEditingController();
  static var nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  bool hidden = true;
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            alignment: Alignment.center,
            children: [
              const BackGround(),
              Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsetsDirectional.only(
                        top: 60.h,
                        start: 20.w,
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 22.5.r,
                          child: Padding(
                            padding: EdgeInsetsDirectional.only(
                              start: 5.w,
                            ),
                            child: Icon(
                              Icons.arrow_back_ios,
                              color: HexColor('5E616F'),
                              size: 18.sp,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        'Register',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 25.sp,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                    const Gap10(),
                    Center(
                      child: Text(
                        'Please fill the following fields to register',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                    const Gap60(),
                    Expanded(
                      child: Container(
                        width: screenWidth,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20.r),
                            topRight: Radius.circular(20.r),
                          ),
                          color: Colors.white,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(22.0),
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Name',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.bold),
                                ),
                                const Gap10(),
                                Directionality(
                                  textDirection: TextDirection.ltr,
                                  child: TextFormField(
                                    controller: nameController,
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    keyboardType: TextInputType.text,
                                    cursorColor: Colors.black,
                                    decoration: InputDecoration(
                                      filled: true,
                                      // Apply the background color
                                      fillColor: HexColor('F0F5FA'),
                                      // Same background color
                                      isDense: true,
                                      // Makes the field more compact
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: 20.h, // Adjust for height
                                        horizontal: 12.w,
                                      ),
                                      prefixIcon: Padding(
                                        padding: const EdgeInsets.all(15.0),
                                        child: Icon(
                                          Icons.person,
                                          color: HexColor('7E8A97'),
                                        ),
                                      ),
                                      hintText: 'Enter your name',
                                      hintStyle: TextStyle(),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.r),
                                        borderSide: const BorderSide(
                                          color: Colors.red,
                                          // Red border when in error state
                                          width: 1.5,
                                        ),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.r),
                                        borderSide: const BorderSide(
                                          color: Colors.red,
                                          // Red border when focused and in error state
                                          width: 1.5,
                                        ),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.r),
                                        borderSide: BorderSide
                                            .none, // No visible border
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Please enter your name';
                                      } else {
                                        return null;
                                      }
                                    },
                                  ),
                                ),
                                const Gap20(),
                                Text(
                                  'Email',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.bold),
                                ),
                                const Gap10(),
                                Directionality(
                                  textDirection: TextDirection.ltr,
                                  child: TextFormField(
                                    controller: emailController,
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    keyboardType: TextInputType.emailAddress,
                                    cursorColor: Colors.black,
                                    decoration: InputDecoration(
                                      filled: true,
                                      // Apply the background color
                                      fillColor: HexColor('F0F5FA'),
                                      // Same background color
                                      isDense: true,
                                      // Makes the field more compact
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: 20.h, // Adjust for height
                                        horizontal: 12.w,
                                      ),
                                      prefixIcon: Padding(
                                        padding: const EdgeInsets.all(15.0),
                                        child: Icon(
                                          Icons.email,
                                          color: HexColor('7E8A97'),
                                        ),
                                      ),
                                      hintText: 'Enter your email',
                                      hintStyle: TextStyle(),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.r),
                                        borderSide: const BorderSide(
                                          color: Colors.red,
                                          // Red border when in error state
                                          width: 1.5,
                                        ),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.r),
                                        borderSide: const BorderSide(
                                          color: Colors.red,
                                          // Red border when focused and in error state
                                          width: 1.5,
                                        ),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.r),
                                        borderSide: BorderSide
                                            .none, // No visible border
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Please enter your email';
                                      } else if (!RegExp(
                                              r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$')
                                          .hasMatch(value)) {
                                        return 'Please enter a valid email address';
                                      } else {
                                        return null;
                                      }
                                    },
                                  ),
                                ),
                                const Gap20(),
                                Text(
                                  'Password',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.bold),
                                ),
                                const Gap10(),
                                TextFormField(
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  controller: passwordController,
                                  obscureText: hidden,
                                  keyboardType: TextInputType.visiblePassword,
                                  cursorColor: Colors.black,
                                  decoration: InputDecoration(
                                    filled: true,
                                    // Apply the background color
                                    fillColor: HexColor('F0F5FA'),
                                    // Same background color
                                    isDense: true,
                                    // Makes the field more compact
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 20.h, // Adjust for height
                                      horizontal: 20.w,
                                    ),
                                    prefixIcon: Padding(
                                      padding: const EdgeInsets.all(15.0),
                                      child: Icon(
                                        Iconsax.lock,
                                        color: HexColor('7E8A97'),
                                      ),
                                    ),
                                    hintText: 'Enter your password',
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.r),
                                      borderSide: const BorderSide(
                                        color: Colors.red,
                                        // Red border when in error state
                                        width: 1.5,
                                      ),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.r),
                                      borderSide: const BorderSide(
                                        color: Colors.red,
                                        // Red border when focused and in error state
                                        width: 1.5,
                                      ),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.r),
                                      borderSide:
                                          BorderSide.none, // No visible border
                                    ),
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          hidden = !hidden;
                                        });
                                      },
                                      icon: Icon(
                                        hidden ? Iconsax.eye : Iconsax.eye_slash,
                                        color: HexColor('7E8A97'),
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value!.length < 8) {
                                      return 'Password must be at least 8 characters';
                                    } else {
                                      return null;
                                    }
                                  },
                                ),
                                const Gap20(),
                                ConditionalBuilder(
                                  condition: state is! RegisterLoading,
                                  builder: (context) {
                                    return myButton(
                                      context: context,
                                      backgroundColor: HexColor('0C0341'),
                                      width: double.infinity,
                                      textColor: Colors.white,
                                      text: 'Register',
                                      onTap: () async {
                                        if (formKey.currentState!
                                            .validate()) {
                                          await AuthCubit.get(context)
                                              .register(
                                            nameController.text,
                                            emailController.text,
                                            passwordController.text,
                                            context
                                          );
                                        }
                                      },
                                    );
                                  },
                                  fallback: (context) => loading(),
                                ),
                                const Gap20(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
