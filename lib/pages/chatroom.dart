import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:simplechat/main.dart';
import 'package:simplechat/pages/screens.dart';

import '../models/models.dart';

class ChatRoom extends StatefulWidget {
  const ChatRoom(
      {super.key,
      required this.currentUserModel,
      required this.firebaseUser,
      required this.enduser,
      required this.chatRoomModel});

  final UserModel enduser;
  final User firebaseUser;
  final ChatRoomModel chatRoomModel;
  final UserModel currentUserModel;

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  final TextEditingController messageController = TextEditingController();

  void sendMessage() async {
    String msg = messageController.text.trim();
    messageController.clear();

    if (msg != "") {
      MessageModel messageModel = MessageModel(
          createdOn: Timestamp.now(),
          messageId: uuid.v1(),
          seen: false,
          sender: widget.currentUserModel.uid,
          text: msg);

      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatRoomModel.chatroomid)
          .collection("messages")
          .doc(messageModel.messageId)
          .set(messageModel.toMap());

      widget.chatRoomModel.lastMessage = msg;
      widget.chatRoomModel.updatedOn = Timestamp.now();
      // !   ***************************8
      // !   ***************************8
      // !   ***************************8
      // !   ***************************8

      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatRoomModel.chatroomid)
          .set(widget.chatRoomModel.toMap());

      log("Message has been send");
    }
  }

  var spinkit = const SpinKitSpinningLines(
    color: Colors.black,
    size: 50.0,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        leadingWidth: 40,
        leading: IconButton(
            icon: const Icon(
              CupertinoIcons.back,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            }),
        title: GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                PageTransition(
                    duration: const Duration(milliseconds: 700),
                    type: PageTransitionType.fade,
                    child: EndUserProfile(endUser: widget.enduser)));
          },
          child: Row(
            children: [
              CircleAvatar(
                  backgroundImage: NetworkImage(
                widget.enduser.profilePicture!,
              )),
              const SizedBox(
                width: 15,
              ),
              Text(
                widget.enduser.fullName!,
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(children: [
        Expanded(
            child: Container(
          padding: EdgeInsets.only(bottom: 10.h),
          child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("chatrooms")
                  .doc(widget.chatRoomModel.chatroomid)
                  .collection("messages")
                  .orderBy("createdOn", descending: true)
                  .snapshots(),
              builder: ((context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.hasData) {
                    QuerySnapshot dataSnapshot = snapshot.data as QuerySnapshot;

                    return ListView.builder(
                        reverse: true,
                        itemCount: dataSnapshot.docs.length,
                        itemBuilder: (context, index) {
                          // ! converting to message model
                          MessageModel currentMessage = MessageModel.fromMap(
                              dataSnapshot.docs[index].data()
                                  as Map<String, dynamic>);

                          log(currentMessage.createdOn!.millisecondsSinceEpoch
                              .toString());

                          String messgaeDate = DateFormat("EEE dd MMM   hh:mm")
                              .format(DateTime.fromMillisecondsSinceEpoch(
                                  currentMessage
                                      .createdOn!.millisecondsSinceEpoch));

                          return messageContainer(
                              messageText: currentMessage.text.toString(),
                              sender: currentMessage.sender ==
                                  widget.currentUserModel.uid.toString(),
                              time: messgaeDate);
                        });
                  } else if (snapshot.hasError) {
                    return const Center(
                      child: Text("Internet Issue"),
                    );
                  } else {
                    return const Center(
                      child: Text("Say hi! to start a conversation"),
                    );
                  }
                } else {
                  return Center(
                    child: spinkit,
                  );
                }
              })),
        )),
        Container(
          color: Colors.blue.shade50,
          child: Row(
            children: [
              Flexible(
                  child: TextFormField(
                controller: messageController,
                maxLines: null,
                decoration: const InputDecoration(
                    contentPadding: EdgeInsets.only(left: 15),
                    hintText: "Type a messgae ...",
                    hintStyle: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 14,
                    ),
                    border: InputBorder.none),
              )),
              CupertinoButton(
                  child: const Icon(Icons.send),
                  onPressed: () {
                    sendMessage();

                    log("");
                  })
            ],
          ),
        )
      ]),
    );
  }
// !  This is Widget in which we will show messages to the user

  Widget messageContainer(
      {required String messageText,
      required String time,
      required bool sender}) {
    return Padding(
      padding: EdgeInsets.only(
          top: 7.h,
          bottom: 7.h,
          left: sender ? 40.w : 7.w,
          right: sender ? 7.w : 40.w),
      child: Container(
        child: Column(
          crossAxisAlignment:
              sender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisAlignment:
              sender ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft:
                        sender ? Radius.circular(10.r) : Radius.circular(10.r),
                    topRight:
                        sender ? Radius.circular(10.r) : Radius.circular(10.r),
                    bottomLeft:
                        sender ? Radius.circular(10.r) : Radius.circular(0.r),
                    bottomRight:
                        sender ? Radius.circular(0.r) : Radius.circular(10.r),
                  ),
                  color: sender ? Colors.blue.shade100 : Colors.grey.shade300),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7),
                  child: Column(
                    children: [
                      Text(
                        messageText,
                        style: TextStyle(color: Colors.black, fontSize: 14.sp),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 3.h,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Text(
                time,
                style: TextStyle(fontSize: 9.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
