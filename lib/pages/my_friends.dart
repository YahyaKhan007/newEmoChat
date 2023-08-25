import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:simplechat/provider/loading_provider.dart';

import '../colors/colors.dart';
import '../firebase/firebase_helper.dart';
import '../main.dart';
import '../models/models.dart';
import '../provider/user_model_provider.dart';
import '../widgets/widgets.dart';
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
    final LoadingProvider provider = Provider.of<LoadingProvider>(context);
    return Scaffold(
        backgroundColor: AppColors.backgroudColor,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: AppColors.backgroudColor,
          elevation: 0.3,
          leading: drawerIcon(context),
          title: Text(
            "My Friends",
            style: TextStyle(
                letterSpacing: -2,
                // fontFamily: "Zombie",
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade900),
          ),
        ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("users")
              .where("uid", isEqualTo: widget.currentUserModel!.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.hasData) {
                QuerySnapshot dataSnapshot = snapshot.data as QuerySnapshot;
                if (dataSnapshot.docs.isNotEmpty) {
                  Map<String, dynamic> userData =
                      dataSnapshot.docs[0].data() as Map<String, dynamic>;

                  UserModel endUser = UserModel.fromMap(userData);
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: endUser.friends!.length,
                    itemBuilder: (context, index) {
                      log(dataSnapshot.docs.length.toString());
                      return FutureBuilder(
                          future: FirebaseHelper.getUserModelById(
                              endUser.friends![index]),
                          builder: ((context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              if (snapshot.hasData) {
                                log("has data");
                                return ListTile(
                                    leading: CircleAvatar(
                                        backgroundImage: NetworkImage(
                                            snapshot.data!.profilePicture!)),
                                    title: Text(
                                        snapshot.data!.fullName.toString()),
                                    subtitle:
                                        Text(snapshot.data!.bio.toString()),
                                    trailing: CircleAvatar(
                                      radius: 18,
                                      child: Image.asset(
                                        "assets/iconImages/sendMessage.png",
                                      ),
                                    ));
                              } else {
                                return Center(
                                  child: Text("No Sent Request"),
                                );
                              }
                            } else {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                          }));
                      // ListTile(
                      //   onTap: () {
                      //     ScaffoldMessenger.of(context).showSnackBar(
                      //         SnackBar(content: Text("Waiting")));
                      //   },
                      //   leading: CircleAvatar(
                      //       backgroundImage:
                      //           NetworkImage(endUser.profilePicture!)),
                      //   title: Text(endUser.fullName!),
                      //   subtitle: Text(senderNames[index]['bio']),
                      //   trailing: Text(
                      //     "Status\nPending",
                      //     style: TextStyle(
                      //         fontSize: 11.sp,
                      //         color: Colors.green,
                      //         fontStyle: FontStyle.italic),
                      //   ),
                      // );
                    },
                  );
                } else {
                  return Center(
                    child: Text("No Sent Requests"),
                  );
                }
              } else {
                return Center(
                  child: Text("No Sent Requests"),
                );
              }
            } else {
              return Center(
                child: CircularProgressIndicator.adaptive(),
              );
            }
          },

          // if (snapshot.connectionState == ConnectionState.active) {
          //   if (snapshot.hasData) {
          //     log(snapshot.data!.size.toString());

          //     QuerySnapshot dataSnapshot = snapshot.data as QuerySnapshot;

          //     if (dataSnapshot.docs.isNotEmpty) {
          //       var friends = 0;
          //       print("came 1");
          //       return ListView.builder(
          //         itemCount: dataSnapshot.docs.length,
          //         itemBuilder: (context, index) {
          //           Map<String, dynamic> userData = dataSnapshot.docs[index]
          //               .data() as Map<String, dynamic>;

          //           UserModel endUser = UserModel.fromMap(userData);

          //           return widget.currentUserModel!.friends!
          //                   .contains(endUser.uid.toString())
          //               ? Container(
          //                   margin: EdgeInsets.only(bottom: 7),
          //                   decoration: BoxDecoration(
          //                       color: AppColors.foregroundColor,
          //                       boxShadow: [AppColors.containerShadow]),
          //                   child: ListTile(
          //                       onTap: () async {
          //                         // showWaiting(context: context, title: "creating");
          //                         Loading.showLoadingDialog(
          //                             context, "Creating");
          //                         ChatRoomModel? chatRoom =
          //                             await getChatroomModel(endUser);
          //                         Navigator.of(context, rootNavigator: true)
          //                             .pop();
          //                         // Navigator.of(context, rootNavigator: true)
          //                         // .pop();

          //                         Navigator.push(
          //                             context,
          //                             PageTransition(
          //                                 duration: const Duration(
          //                                     milliseconds: 700),
          //                                 type: PageTransitionType.fade,
          //                                 child: ChatRoom(
          //                                   chatRoomModel: chatRoom!,
          //                                   enduser: endUser,
          //                                   firebaseUser:
          //                                       widget.firebaseUser!,
          //                                   currentUserModel:
          //                                       widget.currentUserModel!,
          //                                 ),
          //                                 isIos: true));
          //                       },
          //                       leading: CircleAvatar(
          //                         radius: 28,
          //                         backgroundImage:
          //                             NetworkImage(endUser.profilePicture!),
          //                       ),
          //                       title: Text(
          //                         endUser.fullName!,
          //                         overflow: TextOverflow.ellipsis,
          //                         style: TextStyle(fontSize: 14.sp),
          //                       ),
          //                       subtitle: Text(
          //                         endUser.bio!,
          //                         overflow: TextOverflow.ellipsis,
          //                         style: TextStyle(fontSize: 11.sp),
          //                       ),
          //                       trailing: CircleAvatar(
          //                         radius: 18,
          //                         child: Image.asset(
          //                           "assets/iconImages/sendMessage.png",
          //                         ),
          //                       )),
          //                 )
          //               : SizedBox();
          //         },
          //       );
          //     } else {
          //       log("Empty");
          //       return Center(
          //           child: Text(
          //         "There are no other Users in the Database",
          //         style:
          //             TextStyle(fontStyle: FontStyle.italic, fontSize: 12.sp),
          //       ));
          //     }
          //     // !   ***********
          //   } else {
          //     return const Center(
          //       child: Text("No users in the Database"),
          //     );
          //   }
          // } else {
          //   return Padding(
          //     padding: EdgeInsets.symmetric(vertical: 5.h),
          //     child: Shimmer.fromColors(
          //       baseColor: Colors.grey.shade100,
          //       highlightColor: Colors.grey.shade500,
          //       child: ListTile(
          //         leading: CircleAvatar(
          //           radius: 27.r,
          //           backgroundColor: Colors.white,
          //         ),
          //         title: Container(
          //             height: 5,
          //             color: Colors.white,
          //             width: MediaQuery.of(context).size.width * 0.4),
          //         subtitle:
          //             Container(height: 3, color: Colors.white, width: 50),
          //       ),
          //     ),
          //   );
          // }
          // },
        ));
  }
}
