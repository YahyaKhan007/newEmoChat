// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:simplechat/bloc/internetBloc.dart';
import 'package:simplechat/firebase/firebase_helper.dart';
import 'package:simplechat/notification/local_notification.dart';
import 'package:simplechat/provider/modeprovider.dart';
import 'package:simplechat/provider/notifyProvider.dart';
import 'package:simplechat/provider/spaceControllerProvider.dart';
import 'package:simplechat/provider/tokenProvider.dart';
import 'package:simplechat/widgets/glass_morphism.dart';
import 'package:simplechat/widgets/show_connection.dart';

import '../../models/chatroom_model.dart';
import '../../models/user_model.dart';
import '../../provider/user_model_provider.dart';
import '../../widgets/drawer_icon.dart';
import 'screens.dart';

class HomePage extends StatefulWidget {
  const HomePage(
      {super.key,
      required this.userModel,
      required this.firebaseUser,
      required this.spaceControlProvider});

  final SpaceControlProvider spaceControlProvider;
  final UserModel userModel;
  final User firebaseUser;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController searchUserController = TextEditingController();

  // !****************************************************
// ! ****************************************************
// !****************************************************

  // Future<void> readMessageStatus()
  //   {required MessageModel message, required ChatRoomModel chatModel}) async {
  // QuerySnapshot? chatRoomSnapshot = await FirebaseFirestore.instance
  //     .collection("chatrooms")
  //     .doc(chatModel.chatroomid)
  //     .collection("messages")
  //     .where("chatroomid", isEqualTo: chatModel.chatroomid)
  //     .snapshots();

  // final status = await FirebaseFirestore.instance
  //     .collection("chatrooms")
  //     .doc(chatModel.chatroomid)
  //     .collection("messages")
  //     .doc(message.messageId)
  //     .get();

  // if (status.data() != null) {
  //   ChatRoomModel chatModel =
  //       ChatRoomModel.fromMap(status.data() as Map<String, dynamic>);

  //   log("$chatModel.lastMessage");
  // }
  // }

  var spinkit = const SpinKitCircle(
    color: Colors.white,
    size: 25.0,
  );
  late UserModelProvider userModelProvider;
  late NotifyProvider notifyProvider;
  late TokenProvider tokenProvider;
  void uploaddata(
      {required User user,
      required UserModelProvider userModelProvider}) async {
    print(
        "*****************************************************\n********************************\n\n\nDONE\n************************\n***************************");
    widget.userModel.isVarified = user.emailVerified;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userModel.uid!)
        .set(widget.userModel.toMap())
        .then((value) => userModelProvider.updateUser(widget.userModel));
  }

  Future<void> checkEmailVerificationStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    await user!.reload(); // Reloads the user's authentication state
    uploaddata(user: user, userModelProvider: userModelProvider);
    print(user.emailVerified);
  }

  @override
  void initState() {
    userModelProvider = Provider.of<UserModelProvider>(context, listen: false);
    tokenProvider = Provider.of<TokenProvider>(context, listen: false);
    notifyProvider = Provider.of<NotifyProvider>(context, listen: false);

    // checkEmailVerificationStatus();

    log(userModelProvider.userModel.fullName.toString());
    log(userModelProvider.firebaseUser.toString());

    FirebaseMessaging.onMessage.listen((event) {
      log("new Message  --->  ${event.notification!.title}");
      log("new Message  --->  ${event.notification!.body}");
      LocalNotificationServic.display(event);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ModeProvider modeProvider =
        Provider.of<ModeProvider>(context, listen: true);
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      // backgroundColor: Colors.black,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(120.h),
        child: GlassDrop(
            width: MediaQuery.of(context).size.width,
            height: 120.h,
            blur: 20.0,
            opacity: 0.1,
            child: AppBar(
              backgroundColor: Colors.blue.shade100,
              actions: [
                CupertinoButton(
                    // ! changed
                    child: Icon(
                      Icons.group,
                      color: Colors.black.withOpacity(0.7),
                    ),
                    // Image.asset(
                    //   "assets/iconImages/group.png",
                    //   scale: 1,
                    // ),
                    onPressed: () {
                      // !   Logout here
                      Navigator.push(
                          context,
                          PageTransition(
                              duration: const Duration(milliseconds: 700),
                              type: PageTransitionType.fade,
                              child: PublicUsers(
                                  firebaseUser: widget.firebaseUser,
                                  userModel: widget.userModel),
                              isIos: true));
                      // FirebaseController().signout(context: context);
                    })
              ],

              leadingWidth: 70.w,
              elevation: 0,
              leading: drawerIcon(context),
              automaticallyImplyLeading: true,
              // backgroundColor: AppColors.backgroudColor,
              centerTitle: true,
              title: Text(
                "Chats",
                style: GoogleFonts.blackOpsOne(
                    textStyle: Theme.of(context).textTheme.bodyMedium,
                    decorationColor: Colors.black,
                    color: Colors.black.withOpacity(0.7),
                    fontSize: 30.sp),
              ),
            )),
      ),
      body: BlocConsumer<InternetCubit, InternetState>(
        listener: (context, state) {
          if (state == InternetState.Lost) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text("No Internet Connection"),
                  backgroundColor: Colors.red),
            );
          } else {
            tokenProvider.changeToken(value: widget.userModel.pushToken!);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text("Internet Connection Restored"),
                  backgroundColor: Colors.green),
            );
          }
        },
        builder: (context, state) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 15.h,
                  ),
                  SizedBox(
                    height: 35.h,
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 15,
                        ),
                        Expanded(
                          flex: 5,
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15)),
                            child: TextField(
                              controller: searchUserController,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15)),
                                  labelText: "Search User",
                                  labelStyle: TextStyle(fontSize: 13.sp)),
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
                                  child: Icon(
                                Icons.search,
                                color: Colors.black.withOpacity(0.7),
                              )
                                  // Image.asset(
                                  //   "assets/iconImages/searchIcon.png",
                                  //   fit: BoxFit.fill,
                                  // ),
                                  ),
                              onPressed: () {
                                searchUserController.clear();
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    duration: Duration(milliseconds: 700),
                                    content: Text(
                                        "To be implemented in the coming updates")));

                                // setState(() {
                                //   Navigator.push(
                                //       context,
                                //       MaterialPageRoute(
                                //           builder: (builder) => MyFirends(
                                //                 firebaseUser: widget.firebaseUser,
                                //                 currentUserModel: widget.userModel,
                                //               )));
                                //   // search(
                                //   //     context: context,
                                //   //     userEmail: searchUserController.text
                                //   //         .toLowerCase()
                                //   //         .toString(),
                                //   //     currentUserModel: widget.userModel);
                                // });
                              }),
                        )
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
                        if (snapshot.connectionState ==
                            ConnectionState.active) {
                          if (snapshot.hasData) {
                            // !   *************************
                            CollectionReference ref = FirebaseFirestore.instance
                                .collection('chatrooms');

                            // !   *************************

                            QuerySnapshot chatRoomSnapshot =
                                snapshot.data as QuerySnapshot;

                            return chatRoomSnapshot.docs.isNotEmpty
                                ? ListView.builder(
                                    itemCount: chatRoomSnapshot.docs.length,
                                    itemBuilder: ((context, index) {
                                      // ! we need a chatroom model in Order to show it on the HomePage

                                      ChatRoomModel chatRoomModel =
                                          ChatRoomModel.fromMap(chatRoomSnapshot
                                              .docs[index]
                                              .data() as Map<String, dynamic>);

                                      // ! we also need a target user model in Order to show the detail of the target user on the HomePage

                                      Map<String, dynamic> chatrooms =
                                          chatRoomModel.participants!;

                                      List<String> participantKey =
                                          chatrooms.keys.toList();

                                      participantKey
                                          .remove(widget.userModel.uid);
                                      // !                here we finally get the target user UID
                                      // !                No we can fetch target user Model

                                      return FutureBuilder(
                                          future:
                                              FirebaseHelper.getUserModelById(
                                                  participantKey[0]),
                                          builder: (context, userData) {
                                            if (userData.connectionState ==
                                                ConnectionState.done) {
                                              UserModel userModel =
                                                  userData.data as UserModel;

                                              // !   This Container will be shown on the Homepage as a chatroom

                                              return GestureDetector(
                                                onLongPress: () {
                                                  dialogBox(
                                                      chatRoomModel:
                                                          chatRoomModel,
                                                      ref: ref,
                                                      context: context,
                                                      onPressed: () {
                                                        ref
                                                            .doc(chatRoomModel
                                                                .chatroomid)
                                                            .delete();
                                                        Navigator.of(context,
                                                                rootNavigator:
                                                                    true)
                                                            .pop();
                                                        log("deleted");
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(SnackBar(
                                                                content: Text(
                                                                    "Deleted Succussfully")));
                                                      });
                                                  // ! **********************
                                                  // !    Delete
                                                  // !  *********************
                                                },
                                                onTap: () {
                                                  // if (widget
                                                  //     .userModel.isVarified!) {
                                                  chatRoomModel.fromUser
                                                              .toString() !=
                                                          FirebaseAuth.instance
                                                              .currentUser!.uid
                                                      ? chatRoomModel
                                                              .readMessage =
                                                          Timestamp.now()
                                                      : chatRoomModel
                                                          .readMessage = null;

                                                  FirebaseFirestore.instance
                                                      .collection("chatrooms")
                                                      .doc(chatRoomModel
                                                          .chatroomid)
                                                      .set(chatRoomModel
                                                          .toMap());

                                                  log("chatRoom updated");

                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (builder) =>
                                                              ChatRoom(
                                                                modeProvider:
                                                                    modeProvider,
                                                                size: size,
                                                                spaceControlProvider:
                                                                    widget
                                                                        .spaceControlProvider,
                                                                chatRoomModel:
                                                                    chatRoomModel,
                                                                enduser:
                                                                    userModel,
                                                                firebaseUser: widget
                                                                    .firebaseUser,
                                                                currentUserModel:
                                                                    widget
                                                                        .userModel,
                                                              )));
                                                  // } else {
                                                  //   utils.showSnackbar(
                                                  //       context: context,
                                                  //       color: Colors.redAccent,
                                                  //       content:
                                                  //           "to Perform the Action, You must varify your acoount",
                                                  //       seconds: 2);
                                                  // }
                                                },
                                                child: GlassMorphism(
                                                  height: 70.h,
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  blur: 80,
                                                  borderRadius: 20,
                                                  child: Column(
                                                    children: [
                                                      Container(
                                                          margin: EdgeInsets
                                                              .symmetric(
                                                                  vertical: 5.h,
                                                                  horizontal: 10
                                                                      .w),
                                                          height: 60.h,
                                                          width: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width,
                                                          // decoration: BoxDecoration(
                                                          //   boxShadow: [
                                                          //     AppColors.containerShadow
                                                          //   ],
                                                          //   color: Colors.white,
                                                          //   borderRadius:
                                                          //       BorderRadius.circular(
                                                          //           10.r),
                                                          // ),
                                                          child: Center(
                                                              child: ListTile(
                                                                  minVerticalPadding:
                                                                      -30,
                                                                  // dense: true,
                                                                  contentPadding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          bottom:
                                                                              0,
                                                                          right:
                                                                              10,
                                                                          left:
                                                                              0),
                                                                  leading:
                                                                      Stack(
                                                                    children: [
                                                                      CircleAvatar(
                                                                        radius:
                                                                            30.r,
                                                                        backgroundColor: Colors
                                                                            .grey
                                                                            .shade500,
                                                                        backgroundImage:
                                                                            NetworkImage(userModel.profilePicture!),
                                                                      ),
                                                                      Visibility(
                                                                        visible:
                                                                            userModel.isVarified!,
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
                                                                    userModel
                                                                        .fullName!,
                                                                    style: TextStyle(
                                                                        fontFamily:
                                                                            "Aclonica",
                                                                        color: chatRoomModel.readMessage !=
                                                                                null
                                                                            ? Colors
                                                                                .grey.shade600
                                                                            : Colors
                                                                                .black,
                                                                        fontWeight: chatRoomModel.readMessage !=
                                                                                null
                                                                            ? FontWeight
                                                                                .normal
                                                                            : FontWeight
                                                                                .bold,
                                                                        fontSize:
                                                                            13.sp),
                                                                  ),
                                                                  subtitle:
                                                                      chatRoomModel.lastMessage !=
                                                                              ""
                                                                          ? Text(
                                                                              chatRoomModel.lastMessage!,
                                                                              overflow: TextOverflow.ellipsis,
                                                                              style: TextStyle(
                                                                                fontWeight: chatRoomModel.readMessage != null ? FontWeight.normal : FontWeight.bold,
                                                                                fontStyle: FontStyle.italic,
                                                                                color: chatRoomModel.readMessage != null ? Colors.grey : Colors.black,
                                                                                fontSize: 11.sp,
                                                                              ),
                                                                            )
                                                                          : Text(
                                                                              "Say Hi to Start a Conversation!",
                                                                              style: TextStyle(color: Colors.blue, fontSize: 11.sp, fontStyle: FontStyle.italic),
                                                                            ),

                                                                  // ! Option for Delete
                                                                  trailing: chatRoomModel
                                                                              .readMessage !=
                                                                          null
                                                                      ? Column(
                                                                          mainAxisSize:
                                                                              MainAxisSize.min,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.center,
                                                                          children: [
                                                                            Text(
                                                                              DateFormat(" dd MMM yyy").format(DateTime.fromMillisecondsSinceEpoch(chatRoomModel.updatedOn!.millisecondsSinceEpoch)),
                                                                              style: TextStyle(fontSize: 8.sp, fontStyle: FontStyle.italic, color: Colors.grey),
                                                                            ),
                                                                            Text(
                                                                              DateFormat(" hh:mm").format(DateTime.fromMillisecondsSinceEpoch(chatRoomModel.updatedOn!.millisecondsSinceEpoch)),
                                                                              style: TextStyle(fontSize: 8.sp, fontStyle: FontStyle.italic, color: Colors.grey),
                                                                            ),
                                                                          ],
                                                                        )
                                                                      : CircleAvatar(
                                                                          backgroundColor:
                                                                              Colors.blue,
                                                                          radius:
                                                                              7,
                                                                        )))),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            } else {
                                              return Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 5.h),
                                                child: Shimmer.fromColors(
                                                  baseColor:
                                                      Colors.grey.shade100,
                                                  highlightColor:
                                                      Colors.grey.shade500,
                                                  child: ListTile(
                                                    leading: CircleAvatar(
                                                      radius: 27.r,
                                                      backgroundColor:
                                                          Colors.white,
                                                    ),
                                                    title: Container(
                                                        height: 5,
                                                        color: Colors.white,
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.4),
                                                    subtitle: Container(
                                                        height: 3,
                                                        color: Colors.white,
                                                        width: 50),
                                                  ),
                                                ),
                                              );
                                            }
                                          });
                                    }))
                                : Center(
                                    child: Image.asset(
                                        "assets/noMessageTransparent.png"));
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                snapshot.error.toString(),
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14.sp),
                              ),
                            );
                          } else {
                            return Center(
                              child: Text(
                                "No Chats Yet",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14.sp),
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
              // Positioned(
              //     // left: 40.w,
              //     // top: 190.h,
              //     child: Visibility(
              //         visible: widget.userModel.isVarified!
              //             ? false
              //             : notifyProvider.isClose,
              //         child: NotifyForVarification(context: context)))
            ],
          );
        },
      ),
      floatingActionButton: InkWell(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CircleAvatar(
                  radius: 15.r,
                  backgroundColor: Colors.blue.shade100,
                  child: Icon(
                    Icons.person_search_outlined,
                    size: 20.r,
                    color: Colors.black.withOpacity(0.7),
                  )
                  // Image.asset("assets/iconImages/searchIcon.png"),
                  ),
              showConnection(context: context)
            ],
          ),
          onTap: () {
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

  dialogBox(
      {required BuildContext context,
      required VoidCallback onPressed,
      required CollectionReference ref,
      required ChatRoomModel chatRoomModel}) {
    return showDialog(
        context: context,
        builder: (builder) {
          return AlertDialog(
            title: const Text("Delete Confirmaton"),
            contentPadding: EdgeInsets.only(left: 22.w, top: 5),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Are you sure you want to delete this",
                    style: TextStyle(fontSize: 12.sp, color: Colors.black87),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    CupertinoButton(
                        onPressed: onPressed,
                        child: Text(
                          "Yes",
                          style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue),
                        )),
                    CupertinoButton(
                        onPressed: () =>
                            Navigator.of(context, rootNavigator: true).pop(),
                        child: Text(
                          "No",
                          style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue),
                        ))
                  ],
                )
              ],
            ),
          );
        });
  }
}
