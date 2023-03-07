// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:page_transition/page_transition.dart';
import 'package:simplechat/firebase/firebase_helper.dart';
import 'package:simplechat/pages/profile.dart';

import '../main.dart';
import '../models/models.dart';
import '../widgets/showLoading.dart';
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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(164, 124, 77, 255),
      appBar: AppBar(
        actions: [
          CupertinoButton(
              child: const Icon(CupertinoIcons.chat_bubble_2_fill,
                  color: Colors.white),
              onPressed: () {
                // !   Logout here
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
        backgroundColor: Colors.deepPurpleAccent.shade200,
        centerTitle: true,
        title: const Text(
          "Home Page",
          style: TextStyle(
              letterSpacing: -5,
              fontFamily: "zombie",
              fontSize: 32,
              color: Colors.white),
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
                  width: 15,
                ),
                CupertinoButton(
                    child: const Icon(
                      Icons.search,
                      color: Colors.white,
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

                    return chatRoomSnapshot.docs.length != 0
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
                                            height: 70.h,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            decoration: BoxDecoration(
                                              color: Colors
                                                  .deepPurpleAccent.shade200,
                                              borderRadius:
                                                  BorderRadius.circular(10.r),
                                            ),
                                            child: Center(
                                              child: ListTile(
                                                minVerticalPadding: -30,
                                                // dense: true,
                                                contentPadding:
                                                    const EdgeInsets.only(
                                                        bottom: 0),

                                                leading: CircleAvatar(
                                                  radius: 30.r,
                                                  backgroundColor:
                                                      Colors.grey.shade500,
                                                  backgroundImage: NetworkImage(
                                                      userModel
                                                          .profilePicture!),
                                                ),
                                                title: Text(
                                                  userModel.fullName!,
                                                  style: TextStyle(
                                                      fontFamily: "Aclonica",
                                                      color: Colors.white,
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
                                                          color: Colors.white,
                                                          fontSize: 11.sp,
                                                        ),
                                                      )
                                                    : Text(
                                                        "Say Hi to Start a Conversation!",
                                                        style: TextStyle(
                                                            color: Colors.amber,
                                                            fontSize: 12.sp),
                                                      ),

                                                // ! Option for Delete
                                                trailing: GestureDetector(
                                                    behavior: HitTestBehavior
                                                        .deferToChild,
                                                    onTap: () {},
                                                    child: const Icon(
                                                      Icons.more_vert,
                                                      color: Colors.white,
                                                    )),
                                              ),
                                            )),
                                      );
                                    } else {
                                      return spinkit;
                                    }
                                  });
                            }))
                        : Text(
                            "No Conversations yet! Search a user and start a Conversation",
                            style: TextStyle(fontSize: 13, color: Colors.amber),
                          );
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
              backgroundColor: Colors.deepPurpleAccent.shade200,
              child: const Icon(
                Icons.search,
                color: Colors.white,
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
}
