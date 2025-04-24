import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import '../components/components.dart';
import 'package:share_plus/share_plus.dart';

String convertArrayToString(List<String> stringArray) {
  return stringArray.join('\n');
}

Future<void> navigateTo(
    {required BuildContext context, required Widget widget}) async {
  if (Platform.isIOS) {
    Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) => widget,
        ));
  } else {
    Navigator.push(
        context,
        MyCustomRoute(
          builder: (context) => widget,
        ));
  }
}

String getFirstWord({required String text}) {
  for (int i = 0; i < text.length; i++) {
    if (text.startsWith(' ')) {
      text = text.substring(1);
    } else {
      break;
    }
  }
  var list = text.split(' ');
  return list[0];
}

void navigateAndFinish(
    {required BuildContext context, required Widget widget}) {
  try {
    if (Platform.isIOS) {
      Navigator.of(context)
          .pushReplacement(CupertinoPageRoute(builder: (_) => widget));
    } else {
      Navigator.of(context)
          .pushReplacement(MyCustomRoute(builder: (_) => widget));
    }
  } catch (e) {
    debugPrint("Navigation error: $e");
  }
}

String removeSpaces({required String text}) {
  for (int i = 0; i < text.length; i++) {
    if (text.startsWith(' ')) {
      text = text.substring(1);
    } else {
      break;
    }
  }
  return text;
}

void printLongText(String text) {
  final pattern = RegExp('.{1,2000}');
  for (var chunk in pattern.allMatches(text)) {
    if (kDebugMode) {
      print(chunk.group(0));
    } // Print each chunk
  }
}


Future<void> shareText(String text, {String? subject}) async {
  final result;
  try {
  result = await Share.share(
      text,
      subject: subject,
    );

    return result;
  } catch (e) {
    rethrow;
  }
}