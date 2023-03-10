// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:page_transition/page_transition.dart';
import 'package:simplechat/main.dart';
import 'package:simplechat/pages/chatroom.dart';
import 'package:simplechat/widgets/showLoading.dart';

import '../colors/colors.dart';
import '../models/models.dart';

class SearchPage extends StatefulWidget {
  final UserModel? userModel;
  final User? firebaseUser;
  const SearchPage(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  bool isClicked = false;
  final TextEditingController searchUserController = TextEditingController();

  Future<ChatRoomModel?> getChatroomModel(UserModel targetUser) async {
    ChatRoomModel? chatRoom;
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("chatrooms")
        .where("participants.${widget.userModel?.uid}", isEqualTo: true)
        .where("participants.${targetUser.uid}", isEqualTo: true)
        .get();

    if (snapshot.docs.isNotEmpty) {
      var docData = snapshot.docs[0].data();

      ChatRoomModel existingChatRoom =
          ChatRoomModel.fromMap(docData as Map<String, dynamic>);

      chatRoom = existingChatRoom;
      log("Already Existed");
    } else {
      ChatRoomModel newChatRoom = ChatRoomModel(
          createdOn: Timestamp.now(),
          chatroomid: uuid.v1(),
          lastMessage: "",
          participants: {
            widget.userModel!.uid.toString(): true,
            targetUser.uid.toString(): true
          },
          users: [widget.userModel!.uid.toString(), targetUser.uid.toString()],
          updatedOn: Timestamp.now());
      await FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(newChatRoom.chatroomid)
          .set(newChatRoom.toMap());

      chatRoom = newChatRoom;
      log("New Charoom Created");
    }
    return chatRoom;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroudColor,
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          "Search User",
          style: TextStyle(color: Colors.black87, letterSpacing: -1.8),
        ),
        backgroundColor: AppColors.backgroudColor,
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Icon(
            CupertinoIcons.back,
            color: Colors.grey.shade700,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 15,
          ),
          Row(
            children: [
              const SizedBox(
                width: 15,
              ),
              Expanded(
                child: Container(
                  height: 50.h,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.r)),
                  child: TextField(
                    controller: searchUserController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(15.r)),
                        hintText: "Search User",
                        hintStyle: const TextStyle(fontSize: 16)),
                  ),
                ),
              ),
              const SizedBox(
                width: 0,
              ),
              CupertinoButton(
                  child: const Icon(
                    Icons.search,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {});
                  })
            ],
          ),
          SizedBox(
            height: 30.h,
          ),
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("users")
                .where("email", isEqualTo: searchUserController.text.toString())
                .where("email", isNotEqualTo: widget.userModel!.email)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.hasData) {
                  log("has Data");

                  QuerySnapshot dataSnapshot = snapshot.data as QuerySnapshot;
                  if (dataSnapshot.docs.isNotEmpty) {
                    log("not Empty");
                    Map<String, dynamic> userMap =
                        dataSnapshot.docs[0].data() as Map<String, dynamic>;
                    UserModel searchedUser = UserModel.fromMap(userMap);

                    return Material(
                      type: MaterialType.transparency,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(),
                        child: Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: 15.w, vertical: 10.h),
                          decoration: BoxDecoration(
                              boxShadow: [AppColors.containerShadow],
                              color: AppColors.foregroundColor,
                              borderRadius: BorderRadius.circular(8)),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ListTile(
                                  minLeadingWidth: 50,
                                  onTap: () async {
                                    // !  ******************************

                                    Loading.showLoadingDialog(
                                        context, "Creating a chatroom");

                                    ChatRoomModel? chatRoom =
                                        await getChatroomModel(searchedUser);
                                    Navigator.pop(context);
                                    Navigator.pop(context);

                                    Navigator.push(
                                        context,
                                        PageTransition(
                                            duration: const Duration(
                                                milliseconds: 700),
                                            type: PageTransitionType.fade,
                                            child: ChatRoom(
                                              chatRoomModel: chatRoom!,
                                              enduser: searchedUser,
                                              firebaseUser:
                                                  widget.firebaseUser!,
                                              currentUserModel:
                                                  widget.userModel!,
                                            ),
                                            isIos: true));
                                  },
                                  trailing:
                                      const Icon(Icons.keyboard_arrow_right),
                                  leading: Container(
                                    decoration: BoxDecoration(boxShadow: [
                                      AppColors.containerShadow,
                                    ], shape: BoxShape.circle),
                                    child: CircleAvatar(
                                      backgroundImage: NetworkImage(
                                          searchedUser.profilePicture!),
                                    ),
                                  ),
                                  title: Text("${searchedUser.fullName}"),
                                  subtitle: Text("${searchedUser.email}"))
                            ],
                          ),
                        ),
                      ),
                    );
                  } else {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 50),
                        child: Text(
                          "NoOne Found with this specefic email",
                          style:
                              TextStyle(fontSize: 14.sp, color: Colors.amber),
                        ),
                      ),
                    );
                  }
                } else {
                  return const Text("Nothing Found");
                }
              } else {
                return const Padding(
                  padding: EdgeInsets.only(top: 30),
                  child: Center(
                      child: SpinKitSpinningLines(
                    color: Colors.white,
                    size: 25.0,
                  )),
                );
              }
            },
          )
        ],
      ),
    );
  }
}
