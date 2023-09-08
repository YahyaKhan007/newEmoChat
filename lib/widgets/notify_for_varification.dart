import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:simplechat/provider/notifyProvider.dart';
import 'glass_morphism.dart';

Widget NotifyForVarification({
  required BuildContext context,
}) {
  final provider = Provider.of<NotifyProvider>(context, listen: false);
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 10.w),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GlassDrop(
            opacity: 0.30,
            width: MediaQuery.of(context).size.width * 0.7,
            height: 80.h,
            blur: 20.0,
            // borderRadius: 20.0,
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Text(
                  "Go to Profile Section to varify your account, otherwise you will not be able to perform any action",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.pink),
                ),
              ),
            )),
        SizedBox(
          width: 5.w,
        ),
        InkWell(
          onTap: () {
            provider.changeCloseOption(value: false);
          },
          child: CircleAvatar(
            backgroundColor: Colors.grey.shade300,
            child: Icon(
              Icons.close,
              color: Colors.red.withOpacity(0.7),
            ),
          ),
        )
      ],
    ),
  );
}
