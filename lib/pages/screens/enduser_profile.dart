import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:simplechat/colors/colors.dart';
import 'package:simplechat/pages/screens/screens.dart';

import '../../models/models.dart';
import '../../widgets/glass_morphism.dart';

class EndUserProfile extends StatelessWidget {
  const EndUserProfile({super.key, required this.endUser});

  final UserModel endUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.backgroudColor,
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(120.h),
            child: GlassDrop(
              width: MediaQuery.of(context).size.width,
              height: 120.h,
              blur: 20.0,
              opacity: 0.1,
              child: AppBar(
                backgroundColor: Colors.blue.shade100,
                leadingWidth: 70.w,
                centerTitle: true,
                title: Text(
                  "Profile",
                  style: TextStyle(
                      fontSize: 22.sp,
                      letterSpacing: -1.3,
                      fontWeight: FontWeight.bold,
                      color: Colors.black.withOpacity(0.7)),
                ),
                elevation: 0,
                leading: CupertinoButton(
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.black.withOpacity(0.7),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    }),
              ),
            )),
        body: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 25.w, top: 40.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, boxShadow: [avatarShadow]),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage:
                              NetworkImage(endUser.profilePicture!),
                        ),
                      ),
                      SizedBox(
                        width: 20.w,
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: 5.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                endUser.fullName!,
                                style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600),
                              ),
                              Text(
                                endUser.email!,
                                style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w300),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                // Container(
                //     height: 200,
                //     width: MediaQuery.of(context).size.width,
                //     decoration: BoxDecoration(
                //         color: Theme.of(context).colorScheme.background),
                //     child: Center(
                //       child: CircleAvatar(
                //         radius: 80,
                //         backgroundImage: NetworkImage(endUser.profilePicture!),
                //       ),
                //     )),

                option(context,
                    label: "Member Since",
                    value: DateFormat("EEE dd MMM   hh:mm").format(
                        DateTime.fromMillisecondsSinceEpoch(
                            endUser.memberSince!.millisecondsSinceEpoch))),

                option(context, label: "Bio", value: endUser.bio!),
              ]),
        ));
  }
}

Widget option(
  BuildContext context, {
  required String label,
  required String value,
}) {
  return Padding(
    padding: EdgeInsets.only(left: 20.w, top: 30.h),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
                color: Colors.blue,
                fontSize: 13.sp,
                fontWeight: FontWeight.w600),
          ),
        ),
        SizedBox(
          width: 25.w,
        ),

        // !   ********************************************************
        // !   ********************************************************
        // !   ********************************************************
        // !   ********************************************************
        // !   ********************************************************
        // !   ********************************************************

        //  String messgaeDate = DateFormat("EEE dd MMM   hh:mm")
        //             .format(DateTime.fromMillisecondsSinceEpoch(
        //                 currentMessage
        //                     .createdOn!.millisecondsSinceEpoch));

        SizedBox(
          width: MediaQuery.of(context).size.width * 0.64,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w300),
              ),
              SizedBox(
                height: 4.h,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: 0.3,
                color: Colors.black38,
              )
            ],
          ),
        ),
        SizedBox(
          width: 15.w,
        ),
      ],
    ),
  );
}
