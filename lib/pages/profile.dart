import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:simplechat/models/models.dart';
import 'package:simplechat/pages/zoom_drawer.dart';
import 'package:simplechat/provider/user_model_provider.dart';

import '../colors/colors.dart';
import 'screens.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  static FirebaseMessaging messaging = FirebaseMessaging.instance;
  UserModel? userModel;
  late UserModelProvider provider;
  @override
  void initState() {
    provider = Provider.of<UserModelProvider>(context, listen: false);
    getoken();
    super.initState();
  }

  static Future<void> getoken() async {
    await messaging.requestPermission();

    await messaging.getToken().then((t) {
      if (t != null) {
        log("Push Token ----->   $t");
      }
    });

    // log("Push Token ----->   $messaging.getToken()");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.backgroudColor,
        appBar: AppBar(
          leadingWidth: 70.w,
          centerTitle: true,
          title: Text(
            "Profile",
            style: TextStyle(
                fontSize: 22.sp,
                letterSpacing: -1.3,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade900),
          ),
          actions: [
            CupertinoButton(
                child: Row(children: [
                  Icon(
                    CupertinoIcons.pencil_ellipsis_rectangle,
                    size: 18,
                    color: Colors.grey.shade900,
                  ),
                  SizedBox(
                    width: 4,
                  ),
                  Text(
                    "Edit Profile",
                    style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 13.sp,
                        color: Colors.grey.shade900),
                  )
                ]),
                onPressed: () {
                  Navigator.push(
                      context,
                      PageTransition(
                          duration: const Duration(milliseconds: 700),
                          type: PageTransitionType.fade,
                          child: EditProfile(
                            userModel: userModel!,
                            firebaseUser: FirebaseAuth.instance.currentUser!,
                          ),
                          isIos: true));
                })
          ],
          elevation: 0,
          leading: CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 7),
              child: CircleAvatar(
                  // radius: 40,
                  backgroundImage:
                      NetworkImage(provider.userModel.profilePicture!),
                  backgroundColor: Theme.of(context).colorScheme.onBackground),
              onPressed: () {
                log("message");
                log(provider.firebaseUser!.uid);

                drawerController.toggle!();

                // Navigator.push(
                // context,
                // PageTransition(
                //     duration: const Duration(milliseconds: 700),
                //     type: PageTransitionType.fade,
                //     child: const Profile(),
                //     isIos: true));
              }),
          backgroundColor: AppColors.backgroudColor,
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
                  userModel = UserModel.fromMap(userMap);
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
                                Container(
                                  decoration: BoxDecoration(
                                      boxShadow: [AppColors.containerShadow],
                                      shape: BoxShape.circle),
                                  child: CircleAvatar(
                                    radius: 60,
                                    backgroundImage: NetworkImage(
                                        userModel!.profilePicture!),
                                  ),
                                ),
                                SizedBox(
                                  width: 20.w,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      userModel!.fullName!,
                                      style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 17.sp,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      userModel!.email!,
                                      style: TextStyle(
                                          color: Colors.black87,
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
                                  DateTime.fromMillisecondsSinceEpoch(userModel!
                                      .memberSince!.millisecondsSinceEpoch))),
                          option(context,
                              label: "Bio", value: userModel!.bio.toString()),
                          Padding(
                            padding: EdgeInsets.only(
                                top: 45.h, left: 10.w, right: 10.w),
                            child: GestureDetector(
                              onTap: () async {
                                await FirebaseAuth.instance.signOut();

                                Navigator.popUntil(
                                    context, (route) => route.isFirst);
                                Navigator.pushReplacement(
                                    context,
                                    PageTransition(
                                        duration:
                                            const Duration(milliseconds: 700),
                                        type: PageTransitionType.fade,
                                        child: Login(),
                                        isIos: true));
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
                  return const Text("NoOne Found");
                }
              } else {
                return const CircularProgressIndicator();
              }
            } else {
              return const CircularProgressIndicator();
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
