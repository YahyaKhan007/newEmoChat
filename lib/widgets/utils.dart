import 'package:flutter/material.dart';

class utils {
  static showSnackbar(
      {required BuildContext context,
      required Color color,
      required String content,
      required int seconds}) {
    return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: Duration(seconds: seconds),
        backgroundColor: color,
        content: Text(
          content,
          style: TextStyle(color: Colors.white),
        )));
  }
}
