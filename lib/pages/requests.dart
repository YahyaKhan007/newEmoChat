import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:simplechat/provider/user_model_provider.dart';
import 'package:simplechat/widgets/drawer_icon.dart';

import '../colors/colors.dart';
import '../models/user_model.dart';
import '../provider/loading_provider.dart';

class ReceiverListWidget extends StatefulWidget {
  final String uid;

  ReceiverListWidget({required this.uid});

  @override
  _ReceiverListWidgetState createState() => _ReceiverListWidgetState();
}

class _ReceiverListWidgetState extends State<ReceiverListWidget> {
  List<Map<String, dynamic>> receiverNames = [];
  List<Map<String, dynamic>> senderNames = [];
  late UserModelProvider userModelProvider;
  void _initState() {
    // Your initState code here
    print('InitState executed');
  }

  @override
  void initState() {
    userModelProvider = Provider.of<UserModelProvider>(context, listen: false);
    _getReceiverNames();
    _getSenderNames();
    super.initState();
    _initState();

    log("Original init executed");
  }

  Future<void> _getReceiverNames() async {
    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userModelProvider.userModel.uid);
    final userSnapshot = await userRef.get();
    final receiverList = userSnapshot.get('reciever');

    for (final receiverUid in receiverList) {
      final receiverRef =
          FirebaseFirestore.instance.collection('users').doc(receiverUid);
      final receiverSnapshot = await receiverRef.get();
      final receiverData = receiverSnapshot.data();

      setState(() {
        try {
          receiverNames.add(receiverData!);
          log("=============> " + receiverData.toString());
        } catch (e) {
          log(e.toString());
        }
      });
    }
  }

  Future<void> _getSenderNames() async {
    final userRef =
        FirebaseFirestore.instance.collection('users').doc(widget.uid);
    final userSnapshot = await userRef.get();
    final senderList = userSnapshot.get('sender');

    if (senderList != null) {
      for (final senderUid in senderList) {
        final senderRef =
            FirebaseFirestore.instance.collection('users').doc(senderUid);
        final senderSnapshot = await senderRef.get();
        final senderData = senderSnapshot.data();

        if (senderData != null) {
          setState(() {
            senderNames.add(senderData);
          });
        }
      }
    } else {
      print("null");
    }
  }

  void userReference(String uid) async {
    final receiverRef =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final receiverData = receiverRef.data();

    List recievers = receiverData!['reciever'];
    log(recievers.toString());
  }

  @override
  Widget build(BuildContext context) {
    // _getReceiverNames();
    // _getSenderNames();
    final LoadingProvider provider = Provider.of<LoadingProvider>(context);
    final UserModelProvider userModelProvider =
        Provider.of<UserModelProvider>(context);
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 70.w,
        backgroundColor: AppColors.backgroudColor,
        elevation: 0.3,
        leading: drawerIcon(context),
        centerTitle: true,
        title: Text(
          "Requests",
          style: TextStyle(
              letterSpacing: -2,
              // fontFamily: "Zombie",
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade900),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 10.h,
          ),
          Container(
            decoration: BoxDecoration(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 50.w),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        setState(() {});
                        provider.changePending(value: true);
                        log(provider.pending.toString());
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 4.h),
                        decoration:
                            BoxDecoration(color: AppColors.backgroudColor),
                        height: 35.h,
                        child: Text(
                          "Pending Requests",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: provider.pending == true
                                  ? Colors.black
                                  : Colors.grey),
                        ),
                      ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        setState(() {});
                        provider.changePending(value: false);
                        log(provider.pending.toString());
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 4.h),
                        decoration:
                            BoxDecoration(color: AppColors.backgroudColor),
                        height: 35.h,
                        child: Text(
                          "Sent Requests",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: provider.pending == true
                                  ? Colors.grey
                                  : Colors.black),
                        ),
                      ),
                    )
                  ]),
            ),
          ),
          if (provider.pending)
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: receiverNames.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                        backgroundImage: NetworkImage(
                            receiverNames[index]['profilePicture'])),
                    title: Text(receiverNames[index]['fullName']),
                    subtitle: Text(receiverNames[index]['bio']),
                    trailing: SizedBox(
                        width: 90.w,
                        child: Row(children: [
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () async {
                              // log("Yes   Clicked");
                              log("=========>>  " +
                                  senderNames.length.toString());

                              FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(receiverNames[index]['uid'])
                                  .snapshots()
                                  .listen((snapshot) {
                                if (snapshot.data() != null) {
                                  Map<String, dynamic> userData =
                                      snapshot.data()!;
                                  String username = userData['fullName'];
                                  String age = userData['bio'];
                                  // Do something with the user data

                                  print('Username: $username');
                                  print('Age: $age');
                                } else {
                                  print("Empty");
                                }
                              });

                              // !   Stuff remaining
                              // !   Stuff remaining
                              // !   Stuff remaining
                              // !   Stuff remaining

                              // !   Stuff remaining

                              var updatedUser = UserModel(
                                  uid: receiverNames[index]['uid'],
                                  fullName: receiverNames[index]['fullName'],
                                  email: receiverNames[index]['email'],
                                  bio: receiverNames[index]['bio'],
                                  sender: receiverNames[index]['sender'],
                                  reciever: receiverNames[index]['reciever'],
                                  friends: receiverNames[index]['friends'],
                                  memberSince: receiverNames[index]
                                      ['memberSince'],
                                  accountType: receiverNames[index]
                                      ['accountType'],
                                  pushToken: receiverNames[index]['pushToken'],
                                  profilePicture: receiverNames[index]
                                      ['profilePicture']);

                              updatedUser.friends!
                                  .add(userModelProvider.userModel.uid);
                              updatedUser.sender!.removeAt(index);

                              userModelProvider.userModel.friends!
                                  .add(updatedUser.uid);

                              userModelProvider.userModel.reciever!
                                  .removeAt(index);
                              // .remove(receiverNames[index]['uid']);

                              final receiverRef = FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(updatedUser.uid);
                              final receiverSnapshot = await receiverRef.get();

                              userReference(receiverNames[index]['uid']);

                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(updatedUser.uid)
                                  .set(updatedUser.toMap());

                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(userModelProvider.userModel.uid)
                                  .set(userModelProvider.userModel.toMap())
                                  .then((value) => userModelProvider
                                      .updateUser(userModelProvider.userModel))
                                  .then((value) => ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                          duration: Duration(seconds: 1),
                                          content: Text(
                                              "You are now Officially Friends"))));

                              setState(() {
                                _initState();
                              });
                              // await FirebaseFirestore.instance
                              //     .collection('users')
                              //     .doc(receiverNames[index]['uid'])
                              //     .set(userModelProvider.userModel.toMap());
                            },
                            child: CircleAvatar(
                              radius: 15.r,
                              backgroundColor: AppColors.foregroundColor,
                              child: Icon(
                                Icons.check,
                                size: 18.sp,
                              ),
                            ),
                          ),
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {},
                            child: CircleAvatar(
                              radius: 15.r,
                              backgroundColor: AppColors.foregroundColor,
                              child: Icon(
                                Icons.close,
                                size: 18.sp,
                              ),
                            ),
                          )
                        ])),
                  );
                },
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: senderNames.length,
                itemBuilder: (context, index) {
                  log(senderNames.length.toString());
                  return ListTile(
                    onTap: () {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text("Waiting")));
                    },
                    leading: CircleAvatar(
                        backgroundImage:
                            NetworkImage(senderNames[index]['profilePicture'])),
                    title: Text(senderNames[index]['fullName']),
                    subtitle: Text(senderNames[index]['bio']),
                    trailing: Text(
                      "Status\nPending",
                      style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.green,
                          fontStyle: FontStyle.italic),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
