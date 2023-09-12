import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_zoom_drawer/config.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:simplechat/firebase/auth_credential.dart';
import 'package:simplechat/pages/screens/picture%20emotion/picture_emotion.dart';
import 'package:simplechat/pages/screens/screens.dart';
import 'package:simplechat/provider/notifyProvider.dart';
import 'package:simplechat/provider/user_model_provider.dart';
import 'package:badges/badges.dart' as badges;

final drawerController = ZoomDrawerController();

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UserModelProvider>(context);
    final notifyProvider = Provider.of<NotifyProvider>(context);
    List screens = [
      HomePage(
          userModel: provider.userModel, firebaseUser: provider.firebaseUser!),
      Profile(),
      // Requests(currentUserModel: provider.userModel),
      ReceiverListWidget(
        uid: provider.firebaseUser!.uid,
      ),
      MyFirends(
          currentUserModel: provider.userModel,
          firebaseUser: provider.firebaseUser!),

      PictureEmotion()

      // ChatPage()
      // EmotionDetector()
    ];
    return Scaffold(
        backgroundColor: Colors.blue.shade100,
        body: ZoomDrawer(
            // style: DrawerStyle.defaultStyle,
            slideWidth: 250.w,
            controller: drawerController,
            menuScreen: Container(
              // color: Colors.grey[200],
              child: ListView(
                children: [
                  // Container(
                  //   height: 200,
                  //   width: MediaQuery.of(context).size.width,
                  //   color: Colors.black,
                  //   child: Image.network(
                  //     provider.userModel.profilePicture!,
                  //     fit: BoxFit.cover,
                  //   ),
                  // ),
                  SizedBox(
                    height: 10.h,
                  ),
                  // SizedBox(
                  //   height: 150,
                  //   child: Image.network(
                  //     provider.userModel.profilePicture!,
                  //     fit: BoxFit.cover,
                  //   ),
                  // ),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, boxShadow: [avatarShadow]),
                        child: CircleAvatar(
                          radius: 60.r,
                          backgroundImage:
                              NetworkImage(provider.userModel.profilePicture!),
                        ),
                      ),
                      Visibility(
                        visible: provider.userModel.isVarified!,
                        child: Positioned(
                            bottom: 0,
                            right: 50.w,
                            child: CircleAvatar(
                                radius: 15.r,
                                child: Image.asset(
                                  "assets/iconImages/blueTick.png",
                                  color: Colors.blue,
                                ))),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  draweroption(
                      // provider: provider,
                      context: context,
                      title: "Chats",
                      // image: "assets/iconImages/home.png",
                      icon: Icon(
                        color: Colors.black,
                        Icons.home,
                        size: 15,
                      ),
                      onTap: () {
                        provider.changeScreenIndex(0);
                        notifyProvider.changeCloseOption(value: true);

                        drawerController.toggle!();
                      }),
                  draweroption(
                      // provider: provider,
                      context: context,
                      title: "Profile",
                      // image: "assets/iconImages/profile.png",
                      icon: Icon(
                        color: Colors.black,
                        Icons.person_2_outlined,
                        size: 15,
                      ),
                      onTap: () {
                        provider.changeScreenIndex(1);
                        drawerController.toggle!();
                      }),
                  badges.Badge(
                    showBadge: (provider.userModel.reciever!.isNotEmpty ||
                        provider.userModel.sender!.isNotEmpty),
                    position: badges.BadgePosition.custom(top: 10.h, end: 0.w),
                    badgeStyle: badges.BadgeStyle(badgeColor: Colors.green),
                    badgeContent: Text(
                      "${provider.userModel.sender!.length + provider.userModel.reciever!.length}",
                      style: TextStyle(color: Colors.white),
                    ),
                    child: draweroption(
                        // provider: provider,
                        context: context,
                        title: "Requests",

                        // image: "assets/iconImages/request.png",
                        icon: Icon(
                          color: Colors.black,
                          Icons.person_add,
                          size: 15,
                        ),
                        onTap: () {
                          log("Friends are ======> ${provider.userModel.friends!.length}");
                          provider.changeScreenIndex(2);

                          drawerController.toggle!();
                        }),
                  ),
                  // draweroption(
                  //     context: context,
                  //     title: "Settings",
                  //     icon: Icons.settings,
                  //     onTap: () {
                  //       drawerController.toggle!();
                  //     }),
                  draweroption(
                      // provider: provider,
                      context: context,
                      title: "My Friends",
                      // image: "assets/iconImages/friends.png",
                      icon: Icon(
                        color: Colors.black,
                        Icons.groups_2_outlined,
                        size: 15,
                      ),
                      onTap: () {
                        provider.changeScreenIndex(3);

                        drawerController.toggle!();
                      }),

                  draweroption(
                      // provider: provider,
                      context: context,
                      title: "Check Modes",
                      // image: "assets/iconImages/profile.png",
                      icon: Icon(
                        color: Colors.black,
                        Icons.emoji_emotions_outlined,
                        size: 15,
                      ),
                      onTap: () {
                        provider.changeScreenIndex(4);
                        drawerController.toggle!();
                      }),
                  // draweroption(
                  //     context: context,
                  //     title: "take captures demo",
                  //     // image: "assets/iconImages/friends.png",
                  //     icon: Icon(
                  //       Icons.camera_enhance_outlined,
                  //       color: Colors.white,
                  //       size: 15,
                  //     ),
                  //     onTap: () {
                  //       provider.changeScreenIndex(4);

                  //       drawerController.toggle!();
                  //     }),

                  ListTile(
                    contentPadding: EdgeInsets.only(
                        left: 0.w, right: 10.w, top: 0.h, bottom: 0.h),
                    leading: Transform.scale(
                      scale: 0.6.sp,
                      child: Switch(
                        splashRadius: 10,
                        value: provider.sendEmotion,
                        onChanged: (value) {
                          provider.changeSendEmotionOption(value);
                        },
                        // activeTrackColor: Color.fromARGB(255, 106, 111, 106),
                        // inactiveTrackColor: Colors.black,
                        activeColor: Colors.green,
                      ),
                    ),
                    title: Text("Send Emotions",
                        style: GoogleFonts.blackOpsOne(
                            textStyle: Theme.of(context).textTheme.bodyMedium,
                            // fontWeight: FontWeight.w600,
                            decorationColor: Colors.black,
                            color: Colors.black.withOpacity(0.7),
                            fontSize: 13.sp)),
                    onTap: () {},
                  ),

                  Divider(
                    height: 15,
                    endIndent: 10,
                    indent: 10,
                    thickness: 1,
                  ),
                  draweroption(
                      // provider: provider,
                      context: context,
                      title: "Logout",
                      // image: "assets/iconImages/logout.png",
                      icon: Icon(
                        Icons.login_rounded,
                        color: Colors.black,
                        size: 15,
                      ),
                      onTap: () {
                        FirebaseController.signout(context: context);
                        drawerController.toggle!();
                      }),
                ],
              ),
            ),
            mainScreen: screens[provider.screenIndex]));
  }

  Widget draweroption(
      {required BuildContext context,
      required String title,
      // required UserModelProvider provider,
      required Icon icon,
      required VoidCallback onTap}) {
    return ListTile(
      contentPadding:
          EdgeInsets.only(left: 10.w, right: 10.w, top: 0.h, bottom: 0.h),
      leading: CircleAvatar(
        backgroundColor: Colors.blue.withOpacity(0.2),
        radius: 15.r, child: icon,
        // Image.asset(image),
      ),
      title: Text(title,
          style: GoogleFonts.blackOpsOne(
              textStyle: Theme.of(context).textTheme.bodyMedium,
              // fontWeight: FontWeight.w600,
              decorationColor: Colors.black,
              color: Colors.black.withOpacity(0.7),
              fontSize: 13.sp)),
      onTap: onTap,
    );
  }
}
