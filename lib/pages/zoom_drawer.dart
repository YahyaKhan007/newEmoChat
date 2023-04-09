import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_zoom_drawer/config.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:provider/provider.dart';
import 'package:simplechat/firebase/auth_credential.dart';
import 'package:simplechat/pages/homepage.dart';
import 'package:simplechat/pages/my_friends.dart';
import 'package:simplechat/pages/profile.dart';
import 'package:simplechat/pages/requests.dart';
import 'package:simplechat/provider/user_model_provider.dart';

import '../checking camera/send_photo_check.dart';

final drawerController = ZoomDrawerController();

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UserModelProvider>(context);
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
      ChatPage()
    ];
    return Scaffold(
        body: ZoomDrawer(
            // style: DrawerStyle.defaultStyle,
            slideWidth: 250.w,
            controller: drawerController,
            menuScreen: Container(
              color: Colors.grey[200],
              child: ListView(
                children: [
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
                  CircleAvatar(
                    radius: 70.r,
                    backgroundImage:
                        NetworkImage(provider.userModel.profilePicture!),
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  draweroption(
                      context: context,
                      title: "Chats",
                      image: "assets/iconImages/home.png",
                      onTap: () {
                        provider.changeScreenIndex(0);

                        drawerController.toggle!();
                      }),
                  draweroption(
                      context: context,
                      title: "Profile",
                      image: "assets/iconImages/profile.png",
                      onTap: () {
                        provider.changeScreenIndex(1);
                        drawerController.toggle!();
                      }),
                  draweroption(
                      context: context,
                      title: "Requests",
                      image: "assets/iconImages/request.png",
                      onTap: () {
                        provider.changeScreenIndex(2);

                        drawerController.toggle!();
                      }),
                  // draweroption(
                  //     context: context,
                  //     title: "Settings",
                  //     icon: Icons.settings,
                  //     onTap: () {
                  //       drawerController.toggle!();
                  //     }),
                  draweroption(
                      context: context,
                      title: "My Friends",
                      image: "assets/iconImages/friends.png",
                      onTap: () {
                        provider.changeScreenIndex(3);

                        drawerController.toggle!();
                      }),

                  draweroption(
                      context: context,
                      title: "take captures demo",
                      image: "assets/iconImages/friends.png",
                      onTap: () {
                        provider.changeScreenIndex(4);

                        drawerController.toggle!();
                      }),

                  ListTile(
                    contentPadding: EdgeInsets.only(
                        left: 0.w, right: 10.w, top: 0.h, bottom: 0.h),
                    leading: Transform.scale(
                      scale: 0.75.sp,
                      child: Switch(
                        splashRadius: 10,
                        value: provider.sendEmotion,
                        onChanged: (value) {
                          provider.changeSendEmotionOption(value);
                        },
                        activeTrackColor: Color.fromARGB(255, 106, 111, 106),
                        inactiveTrackColor: Colors.black,
                        activeColor: Colors.green,
                      ),
                    ),
                    title: Text(
                      "Send Emotions",
                      style: TextStyle(
                          fontSize: 13.sp, fontWeight: FontWeight.w600),
                    ),
                    onTap: () {},
                  ),

                  Divider(
                    height: 15,
                    endIndent: 10,
                    indent: 10,
                    thickness: 1,
                  ),
                  draweroption(
                      context: context,
                      title: "Logout",
                      image: "assets/iconImages/logout.png",
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
      required String image,
      required VoidCallback onTap}) {
    return ListTile(
      contentPadding:
          EdgeInsets.only(left: 10.w, right: 10.w, top: 0.h, bottom: 0.h),
      leading: CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 15,
          child: Image.asset(image)),
      title: Text(
        title,
        style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
      ),
      onTap: onTap,
    );
  }
}
