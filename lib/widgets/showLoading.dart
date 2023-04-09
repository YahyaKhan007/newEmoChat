import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../colors/colors.dart';

class Loading {
  var spinkit = const SpinKitSpinningLines(
    color: Colors.black,
    size: 30.0,
  );

  static void showLoadingDialog(BuildContext context, String title) {
    AlertDialog loadingDialog = AlertDialog(
      // backgroundColor: Colors.lightBlue.shade100,
      backgroundColor: AppColors.foregroundColor,

      content: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SpinKitSpinningLines(
              color: Colors.black,
              size: 35.0,
            ),
            const SizedBox(
              height: 15,
            ),
            Text(
              title,
              style: TextStyle(fontSize: 14.sp),
            ),
          ],
        ),
      ),
    );

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          Future.delayed(Duration(seconds: 2), () {
            // Navigator.of(context).pop(true);
            // Navigator.pop(context);
          });
          return loadingDialog;
        });
  }

  static void showAlertDialog(
      BuildContext context, String title, String content) {
    AlertDialog alertDialog = AlertDialog(
      backgroundColor: AppColors.foregroundColor,
      shadowColor: Colors.grey.shade400,
      elevation: 1,
      buttonPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
      ),
      content: Text(
        content,
        style: TextStyle(fontSize: 13.sp),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
          },
          child: const Text("Ok"),
        ),
      ],
    );

    showDialog(
        context: context,
        builder: (context) {
          return alertDialog;
        });
  }
}
