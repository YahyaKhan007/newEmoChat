import 'package:flutter/material.dart';
import 'package:simplechat/pages/profile.dart';

import '../models/models.dart';

class EndUserProfile extends StatelessWidget {
  const EndUserProfile({super.key, required this.endUser});

  final UserModel endUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Theme.of(context).colorScheme.background,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  height: 200,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.background),
                  child: Center(
                    child: CircleAvatar(
                      radius: 80,
                      backgroundImage: NetworkImage(endUser.profilePicture!),
                    ),
                  )),
              const Padding(
                padding: EdgeInsets.only(top: 10, left: 10),
                child: Text(
                  "Full Name :",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                ),
              ),
              simpleText(
                context: context,
                text: endUser.fullName!,
              ),
              const Padding(
                padding: EdgeInsets.only(top: 10, left: 10),
                child: Text(
                  "Email :",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                ),
              ),
              simpleText(context: context, text: endUser.email!),
            ],
          ),
        ));
  }
}
