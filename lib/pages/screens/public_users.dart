import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:simplechat/models/models.dart';
import 'package:simplechat/widgets/showLoading.dart';
import 'package:simplechat/widgets/utils.dart';
import '../../colors/colors.dart';
import '../../main.dart';
import '../../provider/user_model_provider.dart';
import '../../widgets/drawer_icon.dart';
import '../../widgets/glass_morphism.dart';
import 'screens.dart';

class PublicUsers extends StatefulWidget {
  final UserModel? userModel;
  final User? firebaseUser;

  const PublicUsers(
      {super.key, required this.firebaseUser, required this.userModel});

  @override
  State<PublicUsers> createState() => _PublicUsersState();
}

class _PublicUsersState extends State<PublicUsers> {
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
    final userModelProvider = Provider.of<UserModelProvider>(context);

    return Scaffold(
        backgroundColor: AppColors.backgroudColor,
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(120.h),
            child: GlassDrop(
              width: MediaQuery.of(context).size.width,
              height: 120.h,
              blur: 20.0,
              opacity: 0.1,
              child: AppBar(
                backgroundColor: Colors.blue.shade100,
                leadingWidth: 70.w,
                centerTitle: true,
                title: Text(
                  "Public User",
                  style: TextStyle(
                      fontSize: 22.sp,
                      letterSpacing: -1.3,
                      fontWeight: FontWeight.bold,
                      color: Colors.black.withOpacity(0.7)),
                ),
                elevation: 0,
                leading: CupertinoButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.black.withOpacity(0.7),
                  ),
                ),
              ),
            )),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("users")
              .where("uid", isNotEqualTo: widget.firebaseUser!.uid)
              // .where('accountType', isEqualTo: 'Public')
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
                          ? GlassMorphism(
                              width: MediaQuery.of(context).size.width,
                              height: 60.h,
                              blur: 20.0,
                              borderRadius: 20.0,
                              child: ListTile(
                                onTap: () async {
                                  // showWaiting(context: context, title: "creating");

                                  log("object");
                                  if (userModelProvider.userModel.isVarified!) {
                                    Loading.showLoadingDialog(
                                        context, "Creating");
                                    ChatRoomModel? chatRoom =
                                        await getChatroomModel(endUser);
                                    Navigator.pushReplacement(
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
                                                  widget.userModel!,
                                            ),
                                            isIos: true));
                                  } else {
                                    utils.showSnackbar(
                                        context: context,
                                        color: Colors.redAccent.shade400,
                                        content:
                                            "to Perform the Action, You must varify your acoount",
                                        seconds: 2);
                                  }
                                },
                                leading: Stack(
                                  children: [
                                    CircleAvatar(
                                      radius: 28,
                                      backgroundImage:
                                          NetworkImage(endUser.profilePicture!),
                                    ),
                                    Visibility(
                                      visible: endUser.isVarified!,
                                      child: Positioned(
                                          bottom: 0,
                                          right: 0,
                                          child: CircleAvatar(
                                              radius: 10.r,
                                              child: Image.asset(
                                                "assets/iconImages/blueTick.png",
                                                color: Colors.blue,
                                              ))),
                                    )
                                  ],
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
                  child: Text(
                    "No users in the Database",
                    style: TextStyle(color: Colors.black),
                  ),
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
