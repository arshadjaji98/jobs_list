import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Utils {
  static void fieldFocus(
      BuildContext context, FocusNode currentNode, FocusNode nextFocus) {
    currentNode.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  static toastMessage(String message, {BuildContext? context}) {
    // use theme primary color if context provided, otherwise fallback to blue
    Color bg = Colors.teal; // default if context not provided
    if (context != null) {
      bg = Theme.of(context).colorScheme.primary;
    }
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: bg,
        textColor: Colors.white,
        fontSize: 14.0);
  }
}
