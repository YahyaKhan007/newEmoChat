// ignore_for_file: use_build_context_synchronously

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
import 'package:shimmer/shimmer.dart';
import 'package:simplechat/colors/colors.dart';
import 'package:simplechat/firebase/firebase_helper.dart';
import 'package:simplechat/notification/local_notification.dart';
import 'package:simplechat/pages/profile.dart';

import '../models/models.dart';
import 'screens.dart';

class HomePage extends StatefulWidget {
  const HomePage(
      {super.key, required this.userModel, required this.firebaseUser});
  final UserModel userModel;
  final User firebaseUser;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController searchUserController = TextEditingController();

  var spinkit = const SpinKitSpinningLines(
    color: Colors.white,
    size: 25.0,
  );
  @override
  void initState() {
    FirebaseMessaging.onMessage.listen((event) {
      log("new Message  --->  ${event.notification!.title}");
      log("new Message  --->  ${event.notification!.body}");
      LocalNotificationServic.display(event);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroudColor,
      appBar: AppBar(
        actions: [
          CupertinoButton(
              child: const Icon(CupertinoIcons.chat_bubble_2_fill,
                  color: Colors.black),
              onPressed: () {
                // !   Logout here
                Navigator.push(
                    context,
                    PageTransition(
                        duration: const Duration(milliseconds: 700),
                        type: PageTransitionType.fade,
                        child: AllUsers(
                            firebaseUser: widget.firebaseUser,
                            userModel: widget.userModel),
                        isIos: true));
                // FirebaseController().signout(context: context);
              })
        ],
        leadingWidth: 80,
        elevation: 0,
        leading: CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 7),
            child: CircleAvatar(
                // radius: 40,
                backgroundImage: NetworkImage(widget.userModel.profilePicture!),
                backgroundColor: Theme.of(context).colorScheme.onBackground),
            onPressed: () {
              log("message");
              Navigator.push(
                  context,
                  PageTransition(
                      duration: const Duration(milliseconds: 700),
                      type: PageTransitionType.fade,
                      child: const Profile(),
                      isIos: true));
            }),
        automaticallyImplyLeading: true,
        backgroundColor: AppColors.backgroudColor,
        centerTitle: true,
        title: const Text(
          "Home Page",
          style: TextStyle(
              letterSpacing: -5,
              fontFamily: "zombie",
              fontSize: 32,
              color: Colors.black),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 15.h,
          ),
          SizedBox(
            height: 40.h,
            child: Row(
              children: [
                const SizedBox(
                  width: 15,
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15)),
                    child: TextField(
                      controller: searchUserController,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15)),
                          labelText: "Search User",
                          labelStyle: const TextStyle(fontSize: 16)),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 0,
                ),
                CupertinoButton(
                    child: const Icon(
                      Icons.search,
                      color: Colors.black,
                      size: 25,
                    ),
                    onPressed: () {
                      setState(() {
                        // search(
                        //     context: context,
                        //     userEmail: searchUserController.text
                        //         .toLowerCase()
                        //         .toString(),
                        //     currentUserModel: widget.userModel);
                      });
                    })
              ],
            ),
          ),
          SizedBox(
            height: 5.h,
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("chatrooms")
                  .where("users", arrayContains: widget.userModel.uid)
                  .orderBy("updatedOn", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.hasData) {
                    QuerySnapshot chatRoomSnapshot =
                        snapshot.data as QuerySnapshot;

                    return chatRoomSnapshot.docs.isNotEmpty
                        ? ListView.builder(
                            itemCount: chatRoomSnapshot.docs.length,
                            itemBuilder: ((context, index) {
                              // ! we need a chatroom model in Order to show it on the HomePage

                              ChatRoomModel chatRoomModel =
                                  ChatRoomModel.fromMap(
                                      chatRoomSnapshot.docs[index].data()
                                          as Map<String, dynamic>);

                              // ! we also need a target user model in Order to show the detail of the target user on the HomePage

                              Map<String, dynamic> chatrooms =
                                  chatRoomModel.participants!;

                              List<String> participantKey =
                                  chatrooms.keys.toList();

                              participantKey.remove(widget.userModel.uid);
                              // !                here we finally get the target user UID
                              // !                No we can fetch target user Model

                              return FutureBuilder(
                                  future: FirebaseHelper.getUserModelById(
                                      participantKey[0]),
                                  builder: (context, userData) {
                                    if (userData.connectionState ==
                                        ConnectionState.done) {
                                      UserModel userModel =
                                          userData.data as UserModel;
                                      // !

                                      // !   This Container will be shown on the Homepage as a chatroom

                                      // !
                                      return GestureDetector(
                                        onLongPress: () {
                                          log("deleted");
                                          dialogBox(
                                              context: context,
                                              onPressed: () {});
                                          // ! **********************
                                          // !    Delete
                                          // !  *********************
                                        },
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (builder) =>
                                                      ChatRoom(
                                                        chatRoomModel:
                                                            chatRoomModel,
                                                        enduser: userModel,
                                                        firebaseUser:
                                                            widget.firebaseUser,
                                                        currentUserModel:
                                                            widget.userModel,
                                                      )));
                                        },
                                        child: Container(
                                            margin: EdgeInsets.symmetric(
                                                vertical: 5.h,
                                                horizontal: 10.w),
                                            height: 60.h,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            decoration: BoxDecoration(
                                              boxShadow: [
                                                AppColors.containerShadow
                                              ],
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10.r),
                                            ),
                                            child: Center(
                                              child: ListTile(
                                                  minVerticalPadding: -30,
                                                  // dense: true,
                                                  contentPadding:
                                                      const EdgeInsets.only(
                                                          bottom: 0,
                                                          right: 10,
                                                          left: 7),
                                                  leading: CircleAvatar(
                                                    radius: 30.r,
                                                    backgroundColor:
                                                        Colors.grey.shade500,
                                                    backgroundImage:
                                                        NetworkImage(userModel
                                                            .profilePicture!),
                                                  ),
                                                  title: Text(
                                                    userModel.fullName!,
                                                    style: TextStyle(
                                                        fontFamily: "Aclonica",
                                                        color: Colors.black54,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 13.sp),
                                                  ),
                                                  subtitle: chatRoomModel
                                                              .lastMessage !=
                                                          ""
                                                      ? Text(
                                                          chatRoomModel
                                                              .lastMessage!,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                            fontStyle: FontStyle
                                                                .italic,
                                                            color: Colors.grey,
                                                            fontSize: 11.sp,
                                                          ),
                                                        )
                                                      : Text(
                                                          "Say Hi to Start a Conversation!",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.blue,
                                                              fontSize: 11.sp,
                                                              fontStyle:
                                                                  FontStyle
                                                                      .italic),
                                                        ),

                                                  // ! Option for Delete
                                                  trailing: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        DateFormat(
                                                                " dd MMM yyy")
                                                            .format(DateTime
                                                                .fromMillisecondsSinceEpoch(
                                                                    chatRoomModel
                                                                        .updatedOn!
                                                                        .millisecondsSinceEpoch)),
                                                        style: TextStyle(
                                                            fontSize: 8.sp,
                                                            fontStyle: FontStyle
                                                                .italic,
                                                            color: Colors.grey),
                                                      ),
                                                      Text(
                                                        DateFormat(" hh:mm").format(
                                                            DateTime.fromMillisecondsSinceEpoch(
                                                                chatRoomModel
                                                                    .updatedOn!
                                                                    .millisecondsSinceEpoch)),
                                                        style: TextStyle(
                                                            fontSize: 8.sp,
                                                            fontStyle: FontStyle
                                                                .italic,
                                                            color: Colors.grey),
                                                      ),
                                                    ],
                                                  )),
                                            )),
                                      );
                                    } else {
                                      return Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 5.h),
                                        child: Shimmer.fromColors(
                                          baseColor: Colors.grey.shade100,
                                          highlightColor: Colors.grey.shade500,
                                          child: ListTile(
                                            leading: CircleAvatar(
                                              radius: 27.r,
                                              backgroundColor: Colors.white,
                                            ),
                                            title: Container(
                                                height: 5,
                                                color: Colors.white,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.4),
                                            subtitle: Container(
                                                height: 3,
                                                color: Colors.white,
                                                width: 50),
                                          ),
                                        ),
                                      );
                                    }
                                  });
                            }))
                        : Center(
                            child:
                                Image.asset("assets/noMessageTransparent.png"));
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        snapshot.error.toString(),
                        style: TextStyle(color: Colors.white, fontSize: 14.sp),
                      ),
                    );
                  } else {
                    return Center(
                      child: Text(
                        "No Chats Yet",
                        style: TextStyle(color: Colors.white, fontSize: 14.sp),
                      ),
                    );
                  }
                } else {
                  return Center(
                    child: SizedBox(
                      height: 30,
                      width: 30,
                      child: spinkit,
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: CupertinoButton(
          child: CircleAvatar(
              radius: 25,
              backgroundColor: AppColors.backgroudColor,
              child: Icon(
                Icons.search,
                color: Colors.grey.shade800,
              )),
          onPressed: () {
            Navigator.push(
                context,
                PageTransition(
                    duration: const Duration(milliseconds: 700),
                    type: PageTransitionType.fade,
                    child: SearchPage(
                      firebaseUser: widget.firebaseUser,
                      userModel: widget.userModel,
                    ),
                    isIos: true));
          }),
    );
  }

  dialogBox({required BuildContext context, required VoidCallback onPressed}) {
    return showDialog(
        context: context,
        builder: (builder) {
          return AlertDialog(
            title: const Text("Delete Confirmaton"),
            contentPadding: EdgeInsets.only(left: 22.w, top: 5),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Are you sure you want to delete this",
                    style: TextStyle(fontSize: 12.sp, color: Colors.black87),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    CupertinoButton(
                        onPressed: onPressed,
                        child: Text(
                          "Yes",
                          style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue),
                        )),
                    CupertinoButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          "No",
                          style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue),
                        ))
                  ],
                )
              ],
            ),
          );
        });
  }
}
