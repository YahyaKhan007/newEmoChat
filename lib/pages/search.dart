// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:simplechat/main.dart';
import 'package:simplechat/models/request_user_model.dart';
import 'package:simplechat/pages/chatroom.dart';
import 'package:simplechat/provider/loading_provider.dart';
import 'package:simplechat/provider/user_model_provider.dart';
import 'package:simplechat/widgets/showLoading.dart';
import 'package:uuid/uuid.dart';

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
  bool isFriend = false;
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
          fromUser: null,
          readMessage: null,
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
    checkFriend({required BuildContext context}) {}
    final LoadingProvider provider = Provider.of<LoadingProvider>(context);
    final UserModelProvider userModelProvider =
        Provider.of<UserModelProvider>(context);
    return Scaffold(
      backgroundColor: AppColors.backgroudColor,
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          "Search User",
          style: TextStyle(
            color: Colors.black87, letterSpacing: -2,
            // fontFamily: "Zombie",
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.backgroudColor,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context).pop(),
          child: Image.asset(
            "assets/iconImages/back.png",
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
                flex: 3,
                child: Container(
                  height: 40.h,
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
                        hintStyle: TextStyle(fontSize: 13.sp)),
                  ),
                ),
              ),
              const SizedBox(
                width: 0,
              ),
              Expanded(
                flex: 1,
                child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Container(
                      width: 60.w,
                      height: 30.h,
                      child: Image.asset(
                        "assets/iconImages/searchText.png",
                        fit: BoxFit.fill,
                        scale: 1,
                      ),
                    ),
                    onPressed: () {
                      setState(() {});
                    }),
              )
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
                  QuerySnapshot dataSnapshot = snapshot.data as QuerySnapshot;
                  if (dataSnapshot.docs.isNotEmpty) {
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
                                    if (searchedUser.accountType == "Public") {
                                      log("public");
                                      // Loading.showLoadingDialog(
                                      //     context, "Creating a chatroom");

                                      ChatRoomModel? chatRoom =
                                          await getChatroomModel(searchedUser);
                                      // Navigator.of(context).pop(true);
                                      // Navigator.pop(context);
                                      Navigator.popUntil(
                                          context, (route) => route.isFirst);

                                      Navigator.pushReplacement(
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
                                    } else if (widget.userModel!.friends!
                                        .contains(searchedUser.uid)) {
                                      Loading.showLoadingDialog(
                                          context, "Creating a chatroom");

                                      ChatRoomModel? chatRoom =
                                          await getChatroomModel(searchedUser);
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
                                    } else {
                                      log("private");
                                      Loading.showAlertDialog(
                                          context,
                                          "Warning",
                                          "in order to Communicate, You must first be friend with the user");
                                    }
                                  },
                                  trailing: searchedUser.accountType == "Public"
                                      ? const Icon(Icons.keyboard_arrow_right)
                                      : CircleAvatar(
                                          backgroundColor:
                                              AppColors.backgroudColor,
                                          child: CupertinoButton(
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.zero,
                                            onPressed: () {
                                              //? *****************************
                                              //? *****************************

                                              try {
                                                if (!(userModelProvider
                                                        .userModel.friends!
                                                        .contains(
                                                            searchedUser.uid) ||
                                                    userModelProvider
                                                        .userModel.sender!
                                                        .contains(
                                                            searchedUser.uid) ||
                                                    searchedUser.reciever!
                                                        .contains(
                                                            userModelProvider
                                                                .userModel
                                                                .uid) ||
                                                    searchedUser.sender!
                                                        .contains(
                                                            userModelProvider
                                                                .userModel
                                                                .uid))) {
                                                  addFriend(
                                                      userModelProvider:
                                                          userModelProvider,
                                                      context: context,
                                                      currentUserModel:
                                                          widget.userModel!,
                                                      provider: provider,
                                                      searchedUser:
                                                          searchedUser);
                                                } else {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(SnackBar(
                                                          duration: Duration(
                                                              seconds: 1),
                                                          content: Text(
                                                              "Already requested")));
                                                }
                                              } catch (e) {
                                                log(e.toString());
                                              }

                                              //? *****************************
                                              //? *****************************
                                            },
                                            child: (userModelProvider
                                                        .userModel.friends!
                                                        .contains(
                                                            searchedUser.uid) ||
                                                    userModelProvider
                                                        .userModel.sender!
                                                        .contains(
                                                            searchedUser.uid) ||
                                                    searchedUser.reciever!
                                                        .contains(
                                                            userModelProvider
                                                                .userModel
                                                                .uid) ||
                                                    searchedUser.sender!
                                                        .contains(
                                                            userModelProvider
                                                                .userModel.uid))
                                                ? Icon(Icons.check)
                                                : Center(
                                                    child: Icon(
                                                    Icons.person_add_sharp,
                                                    color: Colors.grey,
                                                  )),
                                          )),
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
                          "No One ",
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
                    color: Colors.black,
                    size: 25.0,
                  )),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

addFriend({
  required BuildContext context,
  required UserModel currentUserModel,
  required UserModel searchedUser,
  required LoadingProvider provider,
  required UserModelProvider userModelProvider,
}) async {
  currentUserModel.sender!.add(searchedUser.uid);
  searchedUser.reciever!.add(currentUserModel.uid);

  await FirebaseFirestore.instance
      .collection("users")
      .doc(searchedUser.uid)
      .set(searchedUser.toMap())
      .then((value) => provider.changeSendRequest(value: false));

  await FirebaseFirestore.instance
      .collection("users")
      .doc(currentUserModel.uid)
      .set(currentUserModel.toMap())
      .then((value) => provider.changeSendRequest(value: false))
      .then((value) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: Duration(seconds: 2),
          content: Text("Request has been Sent"))));
}
