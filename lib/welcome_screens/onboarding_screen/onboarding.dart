import 'package:aiche/core/shared/components/gaps.dart';
import 'package:aiche/core/shared/constants/constants.dart';
import 'package:aiche/core/shared/functions/functions.dart';
import 'package:aiche/core/utils/cache-helper/cache-helper.dart';
import 'package:aiche/welcome_screens/onboarding_screen/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../auth/auth_screens/login_screen.dart';
import '../../core/shared/components/components.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}
//background: #4587C9;

class _OnboardingState extends State<Onboarding> {
  var boardController = PageController();
  bool isLast = false;

  @override
  Widget build(BuildContext context) {
    List<OnboardingModel> onboarding = [
      OnboardingModel(
        image: 'assets/images/onboarding_1.png',
        title: 'Welcome to AIChE Suez University App!',
        body:
            '"Connect, Learn, and Lead With AIChe." \n Stay Updated with Chapter Events, Access Exclusive Resources, Enhance Your Professional journey.',
      ),
      OnboardingModel(
        image: 'assets/images/onboarding_2.png',
        title: 'Your Engineering Journey Starts Here!',
        body:
            'View and Register for Upcoming Events, Workshops, and Competitions, Access Chapter Materials, and Resources.',
      ),
      OnboardingModel(
        image: 'assets/images/onboarding_3.png',
        title: 'Get Started Today!',
        body:
            'Join the AIChE Suez University Community, Connect with Members, and Stay Updated with the Latest News and Updates.',
      ),
    ];
    return Scaffold(
      backgroundColor: HexColor('#ffffff'),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          const BackGround(),
          Image.asset(
            'assets/images/onboarding_bg.png',
            height: screenHeight / 1.77,
            width: double.infinity,
            fit: BoxFit.fill,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Gap100(),
              SizedBox(
                height: screenHeight / 1.5,
                width: double.infinity,
                child: PageView.builder(
                  onPageChanged: (int index) {
                    if (index == onboarding.length - 1) {
                      setState(() {
                        isLast = true;
                      });
                    } else {
                      setState(() {
                        isLast = false;
                      });
                    }
                  },
                  controller: boardController,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return boardingItemBuilder(
                        onboarding[index], index, context);
                  },
                  itemCount: onboarding.length,
                ),
              ),
              const Spacer(),
              Padding(
                padding: EdgeInsets.only(
                  right: 20.w,
                  left: 20.w,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () async {
                        await CacheHelper.saveData(
                                key: 'onBoarding', value: true)
                            .then((value) {
                          navigateAndFinish(
                              context: context, widget: LoginScreen());
                        });
                      },
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                    SmoothPageIndicator(
                      controller: boardController,
                      count: onboarding.length,
                      effect: ExpandingDotsEffect(
                        dotColor: Colors.grey[400]!,
                        activeDotColor: Colors.white,
                        dotHeight: 7.0.h,
                        dotWidth: 7.0.w,
                        expansionFactor: 4,
                        spacing: 5.0,
                      ),
                    ),
                    SizedBox(
                      height: 41,
                      width: 41,
                      child: FloatingActionButton(
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.black,
                          size: 15.sp,
                        ),
                        onPressed: () async {
                          if (isLast) {
                            await CacheHelper.saveData(
                                    key: 'onBoarding', value: true)
                                .then((value) {
                              navigateAndFinish(
                                  context: context, widget: LoginScreen());
                            });
                          } else {
                            boardController
                                .nextPage(
                                  duration: const Duration(
                                    milliseconds: 250,
                                  ),
                                  curve: Curves.easeInCirc,
                                )
                                .then((value) {});
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const Gap60(),
            ],
          ),
        ],
      ),
    );
  }
}

Widget boardingItemBuilder(
        OnboardingModel model, int index, BuildContext context) =>
    Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          model.image,
          height: 300.h,
          width: 299.w,
          fit: BoxFit.cover,
        ),
        const Gap40(),
        Text(
          model.title,
          textAlign: TextAlign.center,
          style: TextStyle(
            //background:  #EDC53A;
            color: HexColor('EDC53A'),
            fontSize: 30.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Text(
            model.body,
            textAlign: TextAlign.start,
            style: TextStyle(
              color: Colors.white,
              fontSize: 17.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
