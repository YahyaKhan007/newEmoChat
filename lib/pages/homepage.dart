import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:simplechat/firebase/auth_credential.dart';
import 'package:simplechat/firebase/firebase_helper.dart';
import 'package:simplechat/pages/profile.dart';
import 'package:simplechat/pages/search.dart';

import '../main.dart';
import '../models/models.dart';
import 'screens.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key, required this.userModel, required this.firebaseUser});
  final UserModel userModel;
  final User firebaseUser;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController searchUserController = TextEditingController();

  var spinkit = const SpinKitSpinningLines(
    color: Colors.black,
    size: 50.0,
  );
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        leading: CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 7),
            child: CircleAvatar(
                // radius: 40,
                backgroundImage: NetworkImage(widget.userModel.profilePicture!),
                backgroundColor: Theme.of(context).colorScheme.onBackground),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (builder) => const Profile()));
            }),
        automaticallyImplyLeading: true,
        backgroundColor: Theme.of(context).colorScheme.background,
        centerTitle: true,
        title: const Text(
          "Home Page",
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 15.h,
          ),
          Container(
            height: 50.h,
            child: Row(
              children: [
                const SizedBox(
                  width: 15,
                ),
                Expanded(
                  child: TextField(
                    controller: searchUserController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15)),
                        labelText: "Search User",
                        labelStyle: const TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(
                  width: 15,
                ),
                CupertinoButton(
                    child: const Icon(Icons.search),
                    onPressed: () {
                      setState(() {});
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
                  .where("participants.${widget.userModel.uid}",
                      isEqualTo: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.hasData) {
                    QuerySnapshot chatRoomSnapshot =
                        snapshot.data as QuerySnapshot;

                    return ListView.builder(
                        itemCount: chatRoomSnapshot.docs.length,
                        itemBuilder: ((context, index) {
                          // ! we need a chatroom model in Order to show it on the HomePage

                          ChatRoomModel chatRoomModel = ChatRoomModel.fromMap(
                              chatRoomSnapshot.docs[index].data()
                                  as Map<String, dynamic>);

                          // ! we also need a target user model in Order to show the detail of the target user on the HomePage

                          Map<String, dynamic> chatrooms =
                              chatRoomModel.participants!;

                          List<String> participantKey = chatrooms.keys.toList();

                          participantKey.remove(widget.userModel.uid);
                          // !                here we finally get the target user UID
                          // !                No we can fetch target user Model

                          return FutureBuilder(
                              future: FirebaseHelper.getUserModelById(
                                  participantKey[0]),
                              builder: (context, userData) {
                                if (userData.connectionState ==
                                    ConnectionState.done) {
                                  if (userData != null) {
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
                                                builder: (builder) => ChatRoom(
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
                                              vertical: 5.h),
                                          height: 70.h,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10.r),
                                              color: Colors.blueGrey.shade50),
                                          child: Card(
                                              elevation: 0.1,
                                              child: ListTile(
                                                leading: CircleAvatar(
                                                  backgroundImage: NetworkImage(
                                                      userModel
                                                          .profilePicture!),
                                                ),
                                                title: Text(
                                                  userModel.fullName!,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 15.sp),
                                                ),
                                                subtitle: Text(
                                                  chatRoomModel.lastMessage!,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontSize: 15.sp),
                                                ),

                                                // ! Option for Delete
                                                trailing: GestureDetector(
                                                    behavior: HitTestBehavior
                                                        .deferToChild,
                                                    onTap: () {},
                                                    child: const Icon(
                                                        Icons.more_vert)),
                                              ))),
                                    );
                                  } else {
                                    return Container();
                                  }
                                } else {
                                  return Center(
                                    child: SizedBox(
                                      height: 70,
                                      width: 70,
                                      child: spinkit,
                                    ),
                                  );
                                }
                              });
                        }));
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        snapshot.error.toString(),
                        style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                      ),
                    );
                  } else {
                    return Center(
                      child: Text(
                        "No Chats Yet",
                        style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                      ),
                    );
                  }
                } else {
                  return Center(
                    child: SizedBox(
                      height: 70,
                      width: 70,
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
              backgroundColor: Theme.of(context).colorScheme.background,
              child: const Icon(Icons.search)),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (builder) => SearchPage(
                          firebaseUser: widget.firebaseUser,
                          userModel: widget.userModel,
                        )));
          }),
    );
  }
}
