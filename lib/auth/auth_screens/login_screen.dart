import 'package:aiche/auth/auth_cubit/auth_cubit.dart';
import 'package:aiche/auth/auth_cubit/auth_state.dart';
import 'package:aiche/auth/auth_screens/register_screen.dart';
import 'package:aiche/core/shared/components/components.dart';
import 'package:aiche/core/shared/components/gaps.dart';
import 'package:aiche/core/shared/constants/constants.dart';
import 'package:aiche/core/utils/cache-helper/cache-helper.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:iconsax/iconsax.dart';
import 'package:sign_in_button/sign_in_button.dart';

import '../../core/shared/functions/functions.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final formKey = GlobalKey<FormState>();
  static var passwordController = TextEditingController();
  static var emailController = TextEditingController();
  bool rememberMe = CacheHelper.getData(key: 'email') != null ? true : false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        emailController.text = CacheHelper.getData(key: 'email') ?? '';
        passwordController.text = CacheHelper.getData(key: 'password') ?? '';
      });
    });
  }

  bool hiddenPass = true;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            alignment: AlignmentDirectional.bottomCenter,
            children: [
              const BackGround(),
              Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Gap100(),
                    Center(
                      child: Text(
                        'Login',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 25.sp,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                    const Gap10(),
                    Center(
                      child: Text(
                        'Welcome back! Please login to your account',
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
                            topLeft: Radius.circular(30.r), // increased radius
                            topRight: Radius.circular(30.r), // increased radius
                          ),
                          color: Colors.white,
                          boxShadow: [
                            // added subtle shadow
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 10,
                              offset: Offset(0, -2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 24.w,
                              vertical: 30.h), // increased padding
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Email',
                                  style: TextStyle(
                                    color: HexColor('0C0341'),
                                    fontSize: 16.sp, // increased font size
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Gap10(),
                                AnimatedContainer(
                                  duration: Duration(milliseconds: 300),
                                  margin: EdgeInsets.only(
                                      bottom: 10.h), // increased margin
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
                                      } else {
                                        return null;
                                      }
                                    },
                                  ),
                                ),
                                Text(
                                  'Password',
                                  style: TextStyle(
                                    color: HexColor('0C0341'),
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Gap10(),
                                AnimatedContainer(
                                  duration: Duration(milliseconds: 300),
                                  margin: EdgeInsets.only(bottom: 10.h),
                                  child: TextFormField(
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    obscureText: hiddenPass,
                                    controller: passwordController,
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
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            hiddenPass = !hiddenPass;
                                          });
                                        },
                                        icon: Icon(
                                          hiddenPass
                                              ? Iconsax.eye
                                              : Iconsax.eye_slash,
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
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        SizedBox(
                                          height: 24.h,
                                          width: 24.w,
                                          child: Checkbox(
                                            value: rememberMe,
                                            onChanged: (value) {
                                              setState(() {
                                                rememberMe = value!;
                                              });
                                            },
                                            activeColor: HexColor('0C0341'),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 8.w),
                                        Text(
                                          'Remember me',
                                          style: TextStyle(
                                            color: HexColor('0C0341'),
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    // TextButton(
                                    //   onPressed: () {},
                                    //   style: TextButton.styleFrom(
                                    //     padding: EdgeInsets.symmetric(
                                    //         horizontal: 8),
                                    //   ),
                                    //   child: Text(
                                    //     'Forgot Password?',
                                    //     style: TextStyle(
                                    //       color: HexColor('0C0341'),
                                    //       fontSize: 14.sp,
                                    //       fontWeight: FontWeight.w600,
                                    //       decoration:
                                    //           TextDecoration.underline,
                                    //     ),
                                    //   ),
                                    // ),
                                  ],
                                ),
                                const Gap10(),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Divider(
                                        color: HexColor('E8ECF4'),
                                        thickness: 1,
                                      ),
                                    ),
                                    const Gap5(
                                      isHorizontal: true,
                                    ),
                                    Text(
                                      'Or continue with',
                                      style: TextStyle(
                                        color: HexColor('7E8A97'),
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const Gap5(
                                      isHorizontal: true,
                                    ),
                                    Expanded(
                                      child: Divider(
                                        color: HexColor('E8ECF4'),
                                        thickness: 1,
                                      ),
                                    ),
                                  ],
                                ),
                                const Gap15(),
                                Container(
                                  height: 50.h,
                                  width: double.infinity,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: SignInButton(
                                    Buttons.google,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    elevation: 30,
                                    onPressed: () {
                                      AuthCubit.get(context)
                                          .signInWithGoogle(context);
                                    },
                                  ),
                                ),
                                const Gap20(),
                                // Container(
                                //   height: 50.h,
                                //   width: double.infinity,
                                //   clipBehavior: Clip.antiAlias,
                                //   decoration: BoxDecoration(
                                //     borderRadius:
                                //         BorderRadius.circular(12.r),
                                //     boxShadow: [
                                //       BoxShadow(
                                //         color:
                                //             Colors.black.withOpacity(0.05),
                                //         spreadRadius: 2,
                                //         blurRadius: 5,
                                //         offset: Offset(0, 2),
                                //       ),
                                //     ],
                                //   ),
                                //   child: SignInButton(
                                //     Buttons.apple,
                                //     shape: RoundedRectangleBorder(
                                //       borderRadius:
                                //           BorderRadius.circular(12.r),
                                //     ),
                                //     onPressed: () {},
                                //   ),
                                // ),
                                // const Gap30(),
                                ConditionalBuilder(
                                  condition: state is! AuthLoading,
                                  builder: (context) {
                                    return myButton(
                                      context: context,
                                      backgroundColor: HexColor('0C0341'),
                                      width: double.infinity,
                                      textColor: Colors.white,
                                      text: 'Login',
                                      onTap: () {
                                        if (formKey.currentState!.validate()) {
                                          AuthCubit.get(context).login(
                                            emailController.text,
                                            passwordController.text,
                                            context,
                                          );
                                          if (rememberMe) {
                                            CacheHelper.saveData(
                                                key: 'email',
                                                value: emailController.text);
                                            CacheHelper.saveData(
                                                key: 'password',
                                                value: passwordController.text);
                                          } else {
                                            CacheHelper.removeData(
                                                key: 'email');
                                            CacheHelper.removeData(
                                                key: 'password');
                                          }
                                        }
                                      },
                                    );
                                  },
                                  fallback: (context) => loading(),
                                ),
                                const Gap10(),
                                Center(
                                  child: InkWell(
                                    onTap: () {
                                      navigateTo(
                                          context: context,
                                          widget: RegisterScreen());
                                    },
                                    child: Text(
                                      'Don\'t have an account? Sign up',
                                      style: TextStyle(
                                        color: HexColor('0C0341'),
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ),
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
