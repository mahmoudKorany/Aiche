import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class ShowImageScreen extends StatefulWidget {
  const ShowImageScreen({
    super.key,
    required this.images, // updated to images (List<String>)
    required this.heroTag,
  });

  final List<String> images; // changed from image to images
  final String heroTag;

  @override
  State<ShowImageScreen> createState() => _ShowImageScreenState();
}

class _ShowImageScreenState extends State<ShowImageScreen> {
  late TransformationController _transformationController;
  bool _zoomedIn = false; // Tracks whether the image is zoomed in

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _handleDoubleTap(BuildContext context) {
    setState(() {
      if (_zoomedIn) {
        // Reset the scale to its original size
        _transformationController.value = Matrix4.identity();
      } else {
        // Get the size of the screen
        final screenSize = MediaQuery.of(context).size;

        // Translate and scale the image to double size while keeping it centered
        final xTranslate = (screenSize.width / 2) - (screenSize.width / 2 * 2);
        final yTranslate =
            (screenSize.height / 2) - (screenSize.height / 2 * 2);

        _transformationController.value = Matrix4.identity()
          ..translate(xTranslate, yTranslate)
          ..scale(2.0);
      }
      _zoomedIn = !_zoomedIn; // Toggle the zoom state
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsetsDirectional.only(
              top: 54.h,
              start: 20.w,
              end: 20.w,
              bottom: 10.h,
            ),
            child: Pop(),
          ),
          Expanded(
            child: InteractiveViewer(
              transformationController: _transformationController,
              child: GestureDetector(
                onDoubleTap: () => _handleDoubleTap(context),
                child: PageView.builder(
                  itemCount: widget.images.length,
                  itemBuilder: (context, index) {
                    return Hero(
                      tag: widget.heroTag, // Use unique hero tag for each image
                      child: CachedNetworkImage(
                        imageUrl: widget
                            .images[index], // Access each image in the list
                        placeholder: (context, string) => Shimmer.fromColors(
                          baseColor: Colors.grey,
                          highlightColor: Colors.grey[700]!,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height / 3,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.r)),
                            ),
                          ),
                        ),
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.contain,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MyCustomRoute<T> extends MaterialPageRoute<T> {
  MyCustomRoute({
    required super.builder,
    super.settings,
  }) : super(maintainState: true);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    // if (settings.isInitialRoute) {
    //   return child;
    // }
    // Fades between routes. (If you don't want any animation,
    // just return child.)
    return FadeTransition(opacity: animation, child: child);
  }
}

Widget loading() {
  if (Platform.isIOS) {
    return const Center(
      child: CupertinoActivityIndicator(
        radius: 20,
        color: Color(0xFF111347),
      ),
    );
  } else {
    return const Center(
      child: SizedBox(
        height: 50,
        width: 50,
        child: LoadingIndicator(
          indicatorType: Indicator.ballRotateChase,
          colors: [
            Color(0xFF111347),
            Color(0xFF12426F),
            Color(0xFF180438),
          ],
          strokeWidth: 2,
        ),
      ),
    );
  }
}

void showToast({
  required String msg,
  required MsgState state,
}) {
  Fluttertoast.showToast(
    msg: msg,
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 3,
    backgroundColor: chooseColor(state: state),
    textColor: Colors.white,
    fontSize: 16.0.sp,
  );
}

enum MsgState { success, warning, error, information }

Color chooseColor({
  required MsgState state,
}) {
  if (state == MsgState.success) {
    return Colors.green;
  } else if (state == MsgState.warning) {
    return Colors.amber;
  } else if (state == MsgState.information) {
    return HexColor('0450e9');
  } else {
    return Colors.red;
  }
}

class Pop extends StatelessWidget {
  const Pop({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: CircleAvatar(
        backgroundColor: HexColor('ecf0f4'),
        radius: 23.r,
        child: Padding(
          padding: EdgeInsetsDirectional.only(start: 5.w),
          child: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
            size: 18.sp,
          ),
        ),
      ),
    );
  }
}

class BackGround extends StatelessWidget {
  const BackGround({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF111347),
            const Color(0xFF12426F),
            const Color(0xFF180438),
          ],
        ),
      ),
    );
  }
}

Widget myButton({
  required BuildContext context,
  required Function onTap,
  required double width,
  required String text,
  required Color backgroundColor,
  required Color textColor,
}) {
  return InkWell(
    onTap: () {
      onTap();
    },
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.r),
        ),
      ),
      onPressed: () {
        onTap();
      },
      child: SizedBox(
        height: 55.h,
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
