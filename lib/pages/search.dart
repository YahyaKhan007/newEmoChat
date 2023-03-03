// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:simplechat/main.dart';
import 'package:simplechat/pages/chatroom.dart';
import 'package:simplechat/widgets/showLoading.dart';

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
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(backgroundColor: Theme.of(context).colorScheme.background),
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
                          color: Colors.white,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ListTile(
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
                                  leading: CircleAvatar(
                                    backgroundImage: NetworkImage(
                                        searchedUser.profilePicture!),
                                  ),
                                  title: Text("${searchedUser.fullName}"),
                                  subtitle: Text("${searchedUser.email}"))
                            ],
                          ),
                        ),
                      ),
                    );
                  } else {}
                } else {
                  return const Text("Nothing Found");
                }
              } else {
                return const Center(child: CircularProgressIndicator());
              }
              return const Text("");
            },
          )
        ],
      ),
    );
  }
}
