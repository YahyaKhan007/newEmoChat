import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shimmer/shimmer.dart';
import 'package:simplechat/models/models.dart';
import 'package:simplechat/widgets/showLoading.dart';
import '../colors/colors.dart';
import '../main.dart';
import 'screens.dart';

class AllUsers extends StatefulWidget {
  final UserModel? userModel;
  final User? firebaseUser;

  const AllUsers(
      {super.key, required this.firebaseUser, required this.userModel});

  @override
  State<AllUsers> createState() => _AllUsersState();
}

class _AllUsersState extends State<AllUsers> {
  Future<ChatRoomModel?> getChatroomModel(
    UserModel targetUser,
  ) async {
    ChatRoomModel? chatRoom;
    // Loading.showLoadingDialog(context, "Creating");
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
      // Loading.showLoadingDialog(context, "Creating");

      ChatRoomModel newChatRoom = ChatRoomModel(
          createdOn: Timestamp.now(),
          chatroomid: uuid.v1(),
          lastMessage: "",
          readMessage: null,
          fromUser: null,
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
          backgroundColor: AppColors.backgroudColor,
          elevation: 0.3,
          leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(
                CupertinoIcons.back,
                color: Colors.grey.shade600,
              )),
          title: Text(
            "Public Users",
            style: TextStyle(letterSpacing: -2, color: Colors.grey.shade900),
          ),
        ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("users")
              .where("uid", isNotEqualTo: widget.firebaseUser!.uid)
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

                      return endUser.accountType == "Public"
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
                                          duration:
                                              const Duration(milliseconds: 700),
                                          type: PageTransitionType.fade,
                                          child: ChatRoom(
                                            chatRoomModel: chatRoom!,
                                            enduser: endUser,
                                            firebaseUser: widget.firebaseUser!,
                                            currentUserModel: widget.userModel!,
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
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "Since",
                                      style: TextStyle(
                                          fontSize: 9.sp, color: Colors.grey),
                                    ),
                                    Text(
                                      DateFormat(" dd MMM yyy").format(
                                          DateTime.fromMillisecondsSinceEpoch(
                                              endUser.memberSince!
                                                  .millisecondsSinceEpoch)),
                                      style: TextStyle(
                                          fontSize: 9.sp, color: Colors.grey),
                                    ),
                                  ],
                                ),
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

showWaiting({required BuildContext context, required String title}) {
  return showCupertinoDialog(
      context: context,
      builder: (builder) {
        return Column(
          children: [CircularProgressIndicator(), Text(title)],
        );
      });
}

// Future<dy> pop(BuildContext context) async{
//   Future.delayed(Duration(seconds: 3))
//       .then((value) => Navigator.of(context).pop());
// }
