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

final drawerController = ZoomDrawerController();

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UserModelProvider>(context);
    List screens = [
      HomePage(
          userModel: provider.userModel, firebaseUser: provider.firebaseUser!),
      Profile(),
      Requests(currentUserModel: provider.userModel),
      MyFirends(
          currentUserModel: provider.userModel,
          firebaseUser: provider.firebaseUser!),
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
                      icon: Icons.home,
                      onTap: () {
                        provider.changeScreenIndex(0);

                        drawerController.toggle!();
                      }),
                  draweroption(
                      context: context,
                      title: "Profile",
                      icon: Icons.person,
                      onTap: () {
                        provider.changeScreenIndex(1);
                        drawerController.toggle!();
                      }),
                  draweroption(
                      context: context,
                      title: "Requests",
                      icon: Icons.person_add,
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
                      icon: Icons.person_pin_circle_sharp,
                      onTap: () {
                        provider.changeScreenIndex(3);

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
                        activeTrackColor: Colors.lightGreenAccent,
                        activeColor: Colors.green,
                      ),
                    ),
                    title: Text(
                      "Send Emotions",
                      style: TextStyle(fontSize: 14.sp),
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
                      icon: Icons.logout,
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
      required IconData icon,
      required VoidCallback onTap}) {
    return ListTile(
      contentPadding:
          EdgeInsets.only(left: 10.w, right: 10.w, top: 0.h, bottom: 0.h),
      leading: Icon(
        icon,
        size: 25.sp,
      ),
      title: Text(
        title,
        style: TextStyle(fontSize: 14.sp),
      ),
      onTap: onTap,
    );
  }
}
