import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:simplechat/bloc/internetBloc.dart';

Widget showConnection({
  required BuildContext context,
}) {
  return BlocBuilder<InternetCubit, InternetState>(
    builder: (context, state) {
      if (state == InternetState.wifi) {
        return Padding(
          padding: EdgeInsets.only(top: 10.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "Connected\t\t",
                style: TextStyle(fontSize: 9.sp, color: Colors.green),
              ),
              Icon(
                Icons.wifi,
                size: 9.sp,
                color: Colors.green,
              )
            ],
          ),
        );
      } else if (state == ConnectivityResult.mobile) {
        return Padding(
          padding: EdgeInsets.only(top: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "Connected\t\t",
                style: TextStyle(fontSize: 9.sp, color: Colors.green),
              ),
              Icon(
                Icons.four_g_mobiledata_sharp,
                size: 9.sp,
                color: Colors.green,
              )
            ],
          ),
        );
      } else {
        return Text(
          "Not Connected",
          style: TextStyle(fontSize: 9.sp, color: Colors.red),
        );
      }
    },
  );
}
