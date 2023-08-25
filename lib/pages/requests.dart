import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:simplechat/firebase/firebase_helper.dart';
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
              fontSize: 20.sp,
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
                              fontSize: 15.sp,
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
                              fontSize: 15.sp,
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
                              // ! For                 Confirm Click

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
                              updatedUser.reciever!
                                  .remove(userModelProvider.userModel.uid);

                              userModelProvider.userModel.sender!
                                  .remove(updatedUser.uid);

                              userModelProvider.userModel.friends!
                                  .add(updatedUser.uid);

                              userModelProvider
                                  .updateUser(userModelProvider.userModel);

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
                                receiverNames.removeAt(index);
                              });
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
                            onPressed: () async {
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

                              updatedUser.sender!
                                  .remove(userModelProvider.userModel.uid);

                              userModelProvider.userModel.reciever!
                                  .remove(updatedUser.uid);

                              userModelProvider
                                  .updateUser(userModelProvider.userModel);

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
                                receiverNames.removeAt(index);
                              });
                            },
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
                child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('uid', isEqualTo: userModelProvider.firebaseUser!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.hasData) {
                    QuerySnapshot dataSnapshot = snapshot.data as QuerySnapshot;
                    if (dataSnapshot.docs.isNotEmpty) {
                      Map<String, dynamic> userData =
                          dataSnapshot.docs[0].data() as Map<String, dynamic>;

                      UserModel endUser = UserModel.fromMap(userData);
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: endUser.sender!.length,
                        itemBuilder: (context, index) {
                          log(dataSnapshot.docs.length.toString());
                          return FutureBuilder(
                              future: FirebaseHelper.getUserModelById(
                                  endUser.sender![index]),
                              builder: ((context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  if (snapshot.hasData) {
                                    log("has data");
                                    return ListTile(
                                      leading: CircleAvatar(
                                          backgroundImage: NetworkImage(
                                              snapshot.data!.profilePicture!)),
                                      title: Text(
                                          snapshot.data!.fullName.toString()),
                                      subtitle:
                                          Text(snapshot.data!.bio.toString()),
                                      trailing: Text(
                                        "Status\nPending",
                                        style: TextStyle(
                                            fontSize: 11.sp,
                                            color: Colors.green,
                                            fontStyle: FontStyle.italic),
                                      ),
                                    );
                                  } else {
                                    return Center(
                                      child: Text("No Sent Request"),
                                    );
                                  }
                                } else {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                              }));
                        },
                      );
                    } else {
                      return Center(
                        child: Text("No Sent Requests"),
                      );
                    }
                  } else {
                    return Center(
                      child: Text("No Sent Requests"),
                    );
                  }
                } else {
                  return Center(
                    child: CircularProgressIndicator.adaptive(),
                  );
                }
              },
            )),
        ],
      ),
    );
  }
}
