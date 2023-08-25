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
      child: Container(
        decoration:
            BoxDecoration(shape: BoxShape.circle, boxShadow: [avatarShadow]),
        child: CircleAvatar(
            radius: 22.r,
            // radius: 40,
            backgroundImage: NetworkImage(provider.userModel.profilePicture!),
            backgroundColor: Theme.of(context).colorScheme.onBackground),
      ),
      onPressed: () {
        log("message");
        log(provider.firebaseUser!.uid);

        drawerController.toggle!();
      });
}
