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
import 'package:simplechat/widgets/showLoading.dart';

import '../main.dart';
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
    color: Colors.black,
    size: 25.0,
  );
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
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
          SizedBox(
            height: 40.h,
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
                    child: const Icon(
                      Icons.search,
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
                        searchUserController.clear();
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
                                              vertical: 2.h),
                                          height: 60.h,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          decoration: BoxDecoration(
                                            color: Color.fromARGB(
                                                255, 197, 215, 225),
                                            borderRadius:
                                                BorderRadius.circular(10.r),
                                          ),
                                          child: ListTile(
                                            leading: CircleAvatar(
                                              backgroundImage: NetworkImage(
                                                  userModel.profilePicture!),
                                            ),
                                            title: Text(
                                              userModel.fullName!,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 13.sp),
                                            ),
                                            subtitle: Text(
                                              chatRoomModel.lastMessage!,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(fontSize: 11.sp),
                                            ),

                                            // ! Option for Delete
                                            trailing: GestureDetector(
                                                behavior: HitTestBehavior
                                                    .deferToChild,
                                                onTap: () {},
                                                child: const Icon(
                                                    Icons.more_vert)),
                                          )),
                                    );
                                  } else {
                                    return Container();
                                  }
                                } else {
                                  return spinkit;
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
              backgroundColor: Theme.of(context).colorScheme.background,
              child: const Icon(Icons.search)),
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

// search(
//     {required BuildContext context,
//     required String userEmail,
//     required UserModel currentUserModel}) {
//   log("33");
//   StreamBuilder(
//     stream: FirebaseFirestore.instance
//         .collection("users")
//         .where("email", isEqualTo: userEmail)
//         .where("email", isNotEqualTo: currentUserModel.email)
//         .snapshots(),
//     builder: (context, snapshot) {
//       if (snapshot.connectionState == ConnectionState.active) {
//         if (snapshot.hasData) {
//           log("has Data");

//           QuerySnapshot dataSnapshot = snapshot.data as QuerySnapshot;
//           if (dataSnapshot.docs.isNotEmpty) {
//             log("not Empty");
//             Map<String, dynamic> userMap =
//                 dataSnapshot.docs[0].data() as Map<String, dynamic>;
//             UserModel searchedUser = UserModel.fromMap(userMap);

//             return Material(
//               type: MaterialType.transparency,
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(),
//                 child: Container(
//                   color: Colors.white,
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       ListTile(
//                           onTap: () async {
//                             // !  ******************************

//                             Loading.showLoadingDialog(
//                                 context, "Creating a chatroom");

//                             // ChatRoomModel? chatRoom =
//                             //     await getChatroomModel(searchedUser);
//                             // Navigator.pop(context);
//                             Navigator.pop(context);

//                             // Navigator.push(
//                             //     context,
//                             //     PageTransition(
//                             //         duration: const Duration(milliseconds: 700),
//                             //         type: PageTransitionType.fade,
//                             //         child: ChatRoom(
//                             //           chatRoomModel: chatRoom!,
//                             //           enduser: searchedUser,
//                             //           firebaseUser: widget.firebaseUser!,
//                             //           currentUserModel: widget.userModel!,
//                             //         ),
//                             //         isIos: true));
//                           },
//                           trailing: const Icon(Icons.keyboard_arrow_right),
//                           leading: CircleAvatar(
//                             backgroundImage:
//                                 NetworkImage(searchedUser.profilePicture!),
//                           ),
//                           title: Text("${searchedUser.fullName}"),
//                           subtitle: Text("${searchedUser.email}"))
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           } else {}
//         } else {
//           return const Text("Nothing Found");
//         }
//       } else {
//         return const Center(child: CircularProgressIndicator());
//       }
//       return const Text("");
//     },
//   );
// }

// Future<ChatRoomModel?> getChatroomModel(
//     UserModel targetUser, UserModel userModel) async {
//   ChatRoomModel? chatRoom;
//   QuerySnapshot snapshot = await FirebaseFirestore.instance
//       .collection("chatrooms")
//       .where("participants.${userModel.uid}", isEqualTo: true)
//       .where("participants.${targetUser.uid}", isEqualTo: true)
//       .get();

//   if (snapshot.docs.isNotEmpty) {
//     var docData = snapshot.docs[0].data();

//     ChatRoomModel existingChatRoom =
//         ChatRoomModel.fromMap(docData as Map<String, dynamic>);

//     chatRoom = existingChatRoom;
//     log("Already Existed");
//   } else {
//     ChatRoomModel newChatRoom = ChatRoomModel(
//         timeChatroom: Timestamp.now(),
//         chatroomid: uuid.v1(),
//         lastMessage: "",
//         participants: {
//           userModel.uid.toString(): true,
//           targetUser.uid.toString(): true
//         });
//     await FirebaseFirestore.instance
//         .collection("chatrooms")
//         .doc(newChatRoom.chatroomid)
//         .set(newChatRoom.toMap());

//     chatRoom = newChatRoom;
//     log("New Charoom Created");
//   }
//   return chatRoom;
// }
