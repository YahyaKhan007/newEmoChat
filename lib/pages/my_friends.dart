import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:simplechat/pages/zoom_drawer.dart';

import '../colors/colors.dart';
import '../main.dart';
import '../models/models.dart';
import '../provider/randomNameGenerator.dart';
import '../provider/user_model_provider.dart';
import '../widgets/showLoading.dart';
import 'screens.dart';

class MyFirends extends StatefulWidget {
  final UserModel? currentUserModel;
  final User? firebaseUser;
  const MyFirends(
      {super.key, required this.currentUserModel, required this.firebaseUser});

  @override
  State<MyFirends> createState() => _MyFirendsState();
}

class _MyFirendsState extends State<MyFirends> {
  late UserModelProvider userProvider;

  @override
  void initState() {
    userProvider = Provider.of<UserModelProvider>(context, listen: false);

    super.initState();
  }

  Future<ChatRoomModel?> getChatroomModel(
    UserModel targetUser,
  ) async {
    ChatRoomModel? chatRoom;
    // Loading.showLoadingDialog(context, "Creating");
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("chatrooms")
        .where("participants.${widget.currentUserModel?.uid}", isEqualTo: true)
        .where("participants.${targetUser.uid}", isEqualTo: true)
        .get();

    if (snapshot.docs.isNotEmpty) {
      var docData = snapshot.docs[0].data();

      ChatRoomModel existingChatRoom =
          ChatRoomModel.fromMap(docData as Map<String, dynamic>);

      chatRoom = existingChatRoom;

      log("Already Existed");
    } else {
      // Loading.showLoadingDialog(context, "Creating");

      ChatRoomModel newChatRoom = ChatRoomModel(
          createdOn: Timestamp.now(),
          chatroomid: uuid.v1(),
          lastMessage: "",
          readMessage: null,
          fromUser: null,
          participants: {
            widget.currentUserModel!.uid.toString(): true,
            targetUser.uid.toString(): true
          },
          users: [
            widget.currentUserModel!.uid.toString(),
            targetUser.uid.toString()
          ],
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

  Future<bool> myFriends({required UserModel endUser}) async {
    List frnds = await widget.currentUserModel!.friends!;
    Set myfrnds = frnds.toSet();
    bool cond = myfrnds.contains(endUser.uid);
    return cond;
  }

  void addUser() async {
    widget.currentUserModel!.friends!.add(widget.firebaseUser!.uid);
    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.currentUserModel!.uid)
        .set(widget.currentUserModel!.toMap());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.backgroudColor,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: AppColors.backgroudColor,
          elevation: 0.3,
          leading: CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 7),
              child: CircleAvatar(
                  // radius: 40,
                  backgroundImage:
                      NetworkImage(userProvider.userModel.profilePicture!),
                  backgroundColor: Theme.of(context).colorScheme.onBackground),
              onPressed: () {
                drawerController.toggle!();

                // Navigator.push(
                // context,
                // PageTransition(
                //     duration: const Duration(milliseconds: 700),
                //     type: PageTransitionType.fade,
                //     child: const Profile(),
                //     isIos: true));
              }),
          title: Text(
            "My Friends",
            style: TextStyle(letterSpacing: -2, color: Colors.grey.shade900),
          ),
        ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("users")
              .where("uid", isNotEqualTo: widget.currentUserModel!.uid)
              // .where('friends',arrayContains: )
              // .where("friends", )
              // .where('accountType', isNull: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.hasData) {
                log(snapshot.data!.size.toString());

                QuerySnapshot dataSnapshot = snapshot.data as QuerySnapshot;

                if (dataSnapshot.docs.isNotEmpty) {
                  return ListView.builder(
                    itemCount: dataSnapshot.docs.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> userData = dataSnapshot.docs[index]
                          .data() as Map<String, dynamic>;

                      UserModel endUser = UserModel.fromMap(userData);

                      //? *****************************************
                      //? *****************************************
                      //? *****************************************
                      //? *****************************************
                      //? *****************************************
                      //? *****************************************
                      //? *****************************************
                      //? *****************************************
                      //! addUser();
                      //                   List frnds = await widget.userModel!.friends!;
                      // Set myfrnds = frnds.toSet();
                      // widget.userModel!.friends!.contains(endUser.uid)
                      final provider = Provider.of<RandomName>(context);
                      // log("Length of frnds array are    --->  ");
                      // log(endUser.uid.toString());

                      log(widget.currentUserModel!.friends!
                          .contains(" " + endUser.uid.toString())
                          .toString());

                      return widget.currentUserModel!.friends!
                              .contains(endUser.uid.toString())
                          ? Container(
                              margin: EdgeInsets.only(bottom: 7),
                              decoration: BoxDecoration(
                                  color: AppColors.foregroundColor,
                                  boxShadow: [AppColors.containerShadow]),
                              child: ListTile(
                                  onTap: () async {
                                    // showWaiting(context: context, title: "creating");
                                    Loading.showLoadingDialog(
                                        context, "Creating");
                                    ChatRoomModel? chatRoom =
                                        await getChatroomModel(endUser);

                                    Navigator.push(
                                        context,
                                        PageTransition(
                                            duration: const Duration(
                                                milliseconds: 700),
                                            type: PageTransitionType.fade,
                                            child: ChatRoom(
                                              chatRoomModel: chatRoom!,
                                              enduser: endUser,
                                              firebaseUser:
                                                  widget.firebaseUser!,
                                              currentUserModel:
                                                  widget.currentUserModel!,
                                            ),
                                            isIos: true));
                                  },
                                  leading: CircleAvatar(
                                    radius: 28,
                                    backgroundImage:
                                        NetworkImage(endUser.profilePicture!),
                                  ),
                                  title: Text(
                                    endUser.fullName!,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 14.sp),
                                  ),
                                  subtitle: Text(
                                    endUser.bio!,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 11.sp),
                                  ),
                                  trailing: CircleAvatar(
                                    backgroundColor: AppColors.backgroudColor,
                                    child: CupertinoButton(
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.zero,
                                      onPressed: () {},
                                      child: Center(
                                          child: Icon(
                                        Icons.person_add_sharp,
                                        color: Colors.grey,
                                      )),
                                    ),
                                  )
                                  // Column(
                                  //   mainAxisAlignment: MainAxisAlignment.center,
                                  //   crossAxisAlignment: CrossAxisAlignment.center,
                                  //   mainAxisSize: MainAxisSize.min,
                                  //   children: [
                                  //     Text(
                                  //       "Since",
                                  //       style: TextStyle(
                                  //           fontSize: 9.sp, color: Colors.grey),
                                  //     ),
                                  //     Text(
                                  //       DateFormat(" dd MMM yyy").format(
                                  //           DateTime.fromMillisecondsSinceEpoch(
                                  //               endUser.memberSince!
                                  //                   .millisecondsSinceEpoch)),
                                  //       style: TextStyle(
                                  //           fontSize: 9.sp, color: Colors.grey),
                                  //     ),
                                  //   ],
                                  // ),
                                  ),
                            )
                          : SizedBox();
                    },
                  );
                } else {
                  log("Empty");
                  return Center(
                      child: Text(
                    "There are no other Users in the Database",
                    style:
                        TextStyle(fontStyle: FontStyle.italic, fontSize: 12.sp),
                  ));
                }
                // !   ***********
              } else {
                return const Center(
                  child: Text("No users in the Database"),
                );
              }
            } else {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 5.h),
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
                        width: MediaQuery.of(context).size.width * 0.4),
                    subtitle:
                        Container(height: 3, color: Colors.white, width: 50),
                  ),
                ),
              );
            }
          },
        ));
  }
}
