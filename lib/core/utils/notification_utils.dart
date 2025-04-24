import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class NotificationUtils {
  // Show a toast message when a notification is received
  static void showNotificationToast({
    required String title,
    required String body,
  }) {
    Fluttertoast.showToast(
      msg: "$title: $body",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 3,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  // Display a dialog for important notifications
  static void showNotificationDialog(
    BuildContext context, {
    required String title,
    required String body,
    String? actionText,
    VoidCallback? onAction,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: [
            if (actionText != null && onAction != null)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onAction();
                },
                child: Text(actionText),
              ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }
}
