import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:simplechat/pages/zoom_drawer.dart';
import 'package:simplechat/provider/user_model_provider.dart';

Widget drawerIcon(BuildContext context) {
  final provider = Provider.of<UserModelProvider>(context, listen: false);
  return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 7),
      child: CircleAvatar(
          radius: 18.r,
          // radius: 40,
          backgroundImage: NetworkImage(provider.userModel.profilePicture!),
          backgroundColor: Theme.of(context).colorScheme.onBackground),
      onPressed: () {
        log("message");
        log(provider.firebaseUser!.uid);

        drawerController.toggle!();
      });
}
