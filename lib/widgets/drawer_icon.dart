import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:simplechat/pages/screens/screens.dart';
import 'package:simplechat/provider/user_model_provider.dart';

import '../zoom_drawer.dart';

Widget drawerIcon(BuildContext context) {
  final provider = Provider.of<UserModelProvider>(context, listen: false);
  return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 7),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
                shape: BoxShape.circle, boxShadow: [avatarShadow]),
            child: CircleAvatar(
                radius: 22.r,
                // radius: 40,
                backgroundImage:
                    NetworkImage(provider.userModel.profilePicture!),
                backgroundColor: Theme.of(context).colorScheme.onBackground),
          ),
          Visibility(
            visible: provider.userModel.isVarified!,
            child: Positioned(
                bottom: 0,
                right: 0,
                child: CircleAvatar(
                    radius: 8.r,
                    child: Image.asset(
                      "assets/iconImages/blueTick.png",
                      color: Colors.blue,
                    ))),
          )
        ],
      ),
      onPressed: () {
        log("message");
        log(provider.firebaseUser!.uid);

        drawerController.toggle!();
      });
}
