import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:simplechat/firebase/auth_credential.dart';
import 'package:simplechat/models/models.dart';
import 'package:simplechat/widgets/showLoading.dart';

import '../main.dart';
import 'enduser_profile.dart';
import 'screens.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

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
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("users")
              .where("email",
                  isEqualTo: FirebaseAuth.instance.currentUser!.email)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.hasData) {
                QuerySnapshot dataSnapshot = snapshot.data as QuerySnapshot;
                if (dataSnapshot.docs.isNotEmpty) {
                  Map<String, dynamic> userMap =
                      dataSnapshot.docs[0].data() as Map<String, dynamic>;
                  UserModel userModel = UserModel.fromMap(userMap);
                  return Center(
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
                                  backgroundImage:
                                      NetworkImage(userModel.profilePicture!),
                                ),
                                SizedBox(
                                  width: 20.w,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      userModel.fullName!,
                                      style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 17.sp,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      userModel.email!,
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
                          option(context,
                              label: "Member Since",
                              value: DateFormat("EEE dd MMM   hh:mm").format(
                                  DateTime.fromMillisecondsSinceEpoch(userModel
                                      .memberSince!.millisecondsSinceEpoch))),
                          option(context,
                              label: "Bio", value: userModel.bio.toString()),
                          Padding(
                            padding: EdgeInsets.only(
                                top: 45.h, left: 10.w, right: 10.w),
                            child: GestureDetector(
                              onTap: () {
                                Loading.showLoadingDialog(
                                    context, "Please Wait!");
                                FirebaseController().signout(context: context);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15.r),
                                    color: const Color.fromARGB(
                                        255, 200, 220, 234)),
                                height: 60,
                                width: MediaQuery.of(context).size.width,
                                child: const Padding(
                                    padding:
                                        EdgeInsets.only(bottom: 25, left: 25),
                                    child: ListTile(
                                      contentPadding:
                                          EdgeInsets.only(right: 30),
                                      leading: Icon(
                                        Icons.logout_rounded,
                                        color: Colors.black,
                                        size: 26,
                                      ),
                                      title: Text("Logout from this Device"),
                                    )),
                              ),
                            ),
                          ),
                        ]),
                  );
                } else {
                  return Text("NoOne Found");
                }
              } else {
                return CircularProgressIndicator();
              }
            } else {
              return CircularProgressIndicator();
            }
          },
        ));
  }
}

Widget simpleText({
  required BuildContext context,
  required String text,
  TextStyle? style,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
    child: SizedBox(
      height: 60,
      width: MediaQuery.of(context).size.width,
      child: Card(
        color: Colors.grey.shade100,
        child: Padding(
          padding: const EdgeInsets.only(top: 15, left: 25),
          child: Text(
            text,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    ),
  );
}
