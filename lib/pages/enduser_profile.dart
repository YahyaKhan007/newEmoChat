import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/models.dart';

class EndUserProfile extends StatelessWidget {
  const EndUserProfile({super.key, required this.endUser});

  final UserModel endUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.blue.shade50,
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
              icon: const Icon(
                CupertinoIcons.back,
                color: Colors.grey,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              }),
          backgroundColor: Colors.blue.shade50,
        ),
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
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: NetworkImage(endUser.profilePicture!),
                      ),
                      SizedBox(
                        width: 20.w,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            endUser.fullName!,
                            style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w600),
                          ),
                          Text(
                            endUser.email!,
                            style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w300),
                          )
                        ],
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
                    label: "Member Since", value: "7 Jan 2020 06:53"),
                option(context,
                    label: "Bio", value: "Dont put all your eggs in one plate"),
              ]),
        ));
  }
}

Widget option(BuildContext context,
    {required String label, required String value}) {
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
                color: Colors.grey.shade600,
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
              FittedBox(
                fit: BoxFit.cover,
                child: Text(
                  value,
                  style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w300),
                ),
              ),
              SizedBox(
                height: 8.h,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: 1,
                color: Colors.grey.shade600,
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
