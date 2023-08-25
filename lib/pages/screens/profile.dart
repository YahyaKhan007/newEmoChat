import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:simplechat/models/models.dart';
import 'package:simplechat/provider/user_model_provider.dart';

import '../../colors/colors.dart';
import '../../widgets/drawer_icon.dart';
import '../../widgets/glass_morphism.dart';
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
                actions: [
                  CupertinoButton(
                      child: Icon(
                        Icons.personal_injury_outlined,
                        color: Colors.black.withOpacity(0.7),
                      ),
                      // Image.asset("assets/iconImages/editProfile.png"),
                      onPressed: () {
                        Navigator.push(
                            context,
                            PageTransition(
                                duration: const Duration(milliseconds: 700),
                                type: PageTransitionType.fade,
                                child: EditProfile(
                                  userModel: userModel!,
                                  firebaseUser:
                                      FirebaseAuth.instance.currentUser!,
                                ),
                                isIos: true));
                      })
                ],
                elevation: 0,
                leading: drawerIcon(context),
              ),
            )),
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 25.w, top: 40.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      boxShadow: [avatarShadow],
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
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(right: 5.w),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          userModel!.fullName!,
                                          style: TextStyle(
                                              color: Colors.blue,
                                              fontSize: 17.sp,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        FittedBox(
                                          fit: BoxFit.cover,
                                          child: Text(
                                            userModel!.email!,
                                            style: TextStyle(
                                                color: Colors.black87,
                                                fontStyle: FontStyle.italic,
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.w300),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
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
                          option(context,
                              label: "Account Type",
                              value: userModel!.accountType.toString()),
                          Padding(
                            padding: EdgeInsets.only(
                                top: 45.h, left: 10.w, right: 10.w),
                            child: Container(
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [avatarShadow]),
                              child: CircleAvatar(
                                backgroundColor: Colors.white,
                                child: CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  child: Center(
                                      child: Icon(
                                    Icons.login_outlined,
                                    color: Colors.blue,
                                  )
                                      // Image.asset(
                                      //   "assets/iconImages/logout.png",
                                      //   scale: 2,
                                      // ),
                                      ),
                                  onPressed: () async {
                                    await FirebaseAuth.instance.signOut();

                                    Navigator.popUntil(
                                        context, (route) => route.isFirst);
                                    Navigator.pushReplacement(
                                        context,
                                        PageTransition(
                                            duration: const Duration(
                                                milliseconds: 700),
                                            type: PageTransitionType.fade,
                                            child: Login(),
                                            isIos: true));
                                  },
                                ),
                              ),
                            ),
                          ),
                        ]),
                  );
                } else {
                  return const Text("NoOne Found");
                }
              } else {
                return Center(
                  child: SpinKitCircle(
                    size: 20.r,
                    color: Colors.blue,
                  ),
                );
              }
            } else {
              return Center(
                child: SpinKitCircle(
                  size: 20.r,
                  color: Colors.blue,
                ),
              );
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
