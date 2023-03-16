import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:simplechat/colors/colors.dart';
import 'package:simplechat/constants/emotions.dart';
import 'package:simplechat/main.dart';
import 'package:simplechat/notification/local_notification.dart';
import 'package:simplechat/pages/screens.dart';
import 'package:simplechat/provider/loading_provider.dart';
import 'package:simplechat/provider/randomNameGenerator.dart';

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
  late int randomName;
  File? imageFile;
  final TextEditingController messageController = TextEditingController();
  final TextEditingController messageNextController = TextEditingController();

// ! Selecting the Image
  void selectImage(ImageSource source) async {
    XFile? pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      // ! we are cropping the image now
      cropImage(pickedFile);
    }
  }

// ! Cropping the Image
  void cropImage(XFile file) async {
    CroppedFile? croppedImage = await ImageCropper()
        .cropImage(sourcePath: file.path, compressQuality: 50);
    if (croppedImage != null) {
      // ! we need "a value of File Type" so here we are converting the from CropperdFile to File
      final File croppedFile = File(
        croppedImage.path,
      );
      setState(() {
        // log("storing the image");
        imageFile = croppedFile;
        if (imageFile != null) {
          // log("photo is stored");

          // !   ************
          sendPhoto(context);
        }
      });
    }
  }

  // ! Send Push Notification
  static Future<void> sendPushNotificatio(
      UserModel chatUser, String msg) async {
    try {
      final body = {
        "to": chatUser.pushToken,
        "notification": {
          "title": chatUser.fullName,
          "body": msg,
          "android_channel_id": "chats"
        },
      };

      var res = await post(Uri.parse("https://fcm.googleapis.com/fcm/send"),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'key=AAAAXk1Z2Yw:APA91bEJJT8NzzNAbx-pNe3_h6uB5x84hga6FtIatZmRSXk40p6FzF9H7iVoQ9jmVa_rDM79hfuQxSjssxJQMuXMCCfn_X3q_4dvZXl7z-MxPCxMG5-hyfPYlxI5A0DQlIxq5ib0SqCV',
          },
          body: jsonEncode(body));
      // log("Response status : ${res.statusCode}");
      // log("Response body : ${res.body}");
    } catch (e) {
      // log("Send Notification  E --->      $e");
    }
  }

  // ! sending photo
  sendPhoto(BuildContext context) {
    final provider = Provider.of<LoadingProvider>(context, listen: false);
    return showDialog(
        context: context,
        builder: (context) {
          return Scaffold(
            backgroundColor: Colors.black,
            resizeToAvoidBottomInset: true,
            body: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.15,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: Stack(
                      // alignment: Alignment.topRight,
                      children: [
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.65,
                            width: MediaQuery.of(context).size.width,
                            child: Image.file(
                              imageFile!,
                              fit: BoxFit.contain,
                            )),
                        Positioned(
                          top: 20,
                          child: CupertinoButton(
                              child: const CircleAvatar(
                                backgroundColor: Colors.grey,
                                child: Icon(
                                  Icons.close,
                                  color: Colors.white,
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                setState(() {
                                  messageController.clear();
                                  imageFile = null;
                                });
                              }),
                        ),
                        Positioned(
                          bottom: 95,
                          right: 25,
                          left: 25,
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  50,
                                ),
                                border: Border.all(color: Colors.white54),
                                color: Colors.black),
                            child: Padding(
                              padding: EdgeInsets.only(left: 20.w, right: 20.w),
                              child: TextField(
                                maxLines: null,
                                controller: messageNextController,
                                style: TextStyle(
                                    fontSize: 11.sp, color: Colors.white),
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Add a Caption...",
                                    hintStyle: TextStyle(
                                        fontSize: 11.sp,
                                        color: Colors.white,
                                        fontStyle: FontStyle.italic)),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 20,
                          right: 20, bottom: 20,
                          // height: ,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10.w, vertical: 6.h),
                                decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Center(
                                  child: Text(
                                    widget.enduser.fullName!,
                                    style: TextStyle(fontSize: 12.sp),
                                  ),
                                ),
                              ),
                              CupertinoButton(
                                  child: const CircleAvatar(
                                    backgroundColor: Colors.blue,
                                    child: Icon(Icons.send),
                                  ),
                                  onPressed: () {
                                    // ! ********************
                                    if (imageFile != null) {
                                      provider.sendPhotoCmplete(value: false);
                                    }
                                    sendMessage(
                                        msg: messageNextController.text.trim());
                                    Navigator.pop(context);
                                  })
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  // ! Options for picking a photo
  void showPhotoOption() {
    showDialog(
        context: context,
        builder: (builder) {
          return AlertDialog(
            title: const Text("Upload Profile Photo"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  onTap: () {
                    selectImage(ImageSource.gallery);
                    // Navigator.pop(context);
                  },
                  title: const Text("Select from Gallery"),
                  leading: const Icon(Icons.photo_album),
                ),
                ListTile(
                  onTap: () {
                    selectImage(ImageSource.camera);

                    // Navigator.pop(context);
                  },
                  title: const Text("Take a Photo"),
                  leading: const Icon(Icons.camera),
                ),
              ],
            ),
          );
        });
  }

// !****************************************************
// ! ****************************************************
// !****************************************************

  Future<void> readMessageStatus({required MessageModel message}) async {
    final status = await FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(widget.chatRoomModel.chatroomid)
        .collection("messages")
        .doc(message.messageId)
        .get();

    if (status.data() != null) {
      ChatRoomModel chatModel =
          ChatRoomModel.fromMap(status.data() as Map<String, dynamic>);

      // log("$chatModel.lastMessage");
    }
  }

// !  **********************************************
  void sendMessage({required String? msg}) async {
    MessageModel? messageModel;
    // String? msg = messageController.text.trim();
    messageController.clear();

// ! for simple message
    if (msg != "" && imageFile == null) {
      messageModel = MessageModel(
          createdOn: Timestamp.now(),
          image: "",
          messageId: uuid.v1(),
          seen: false,
          sender: widget.currentUserModel.uid,
          reciever: widget.enduser.uid,
          text: msg);

      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatRoomModel.chatroomid)
          .collection("messages")
          .doc(messageModel.messageId)
          .set(messageModel.toMap())
          .then((value) => sendPushNotificatio(widget.enduser, msg!));

// !****************************************************
//  ? ****************************************************
      widget.chatRoomModel.updatedOn = Timestamp.now();
      widget.chatRoomModel.readMessage = null;
      widget.chatRoomModel.fromUser = widget.currentUserModel.uid;
      widget.chatRoomModel.lastMessage = msg;

      // !****************************************************
//  ? ****************************************************

      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatRoomModel.chatroomid)
          .set(widget.chatRoomModel.toMap())
          .then((value) => LocalNotificationServic.sendPushNotificatio(
              widget.enduser, msg!));

      // log("Message has been send");
    }

    // ! for message with picture
    else if (imageFile != null && msg != "") {
      UploadTask uploadTask = FirebaseStorage.instance
          .ref(
              "PicturesBetween${widget.currentUserModel.fullName} and ${widget.enduser.fullName}")
          .child(randomName.toString())
          .putFile(imageFile!);

      TaskSnapshot snapshot = await uploadTask;

      // ! we need imageUrl of the profile photo inOrder to Upload it on FirebaseFirestore
      String imageUrl = await snapshot.ref.getDownloadURL();
      messageModel = MessageModel(
          createdOn: Timestamp.now(),
          image: imageUrl,
          messageId: uuid.v1(),
          seen: false,
          sender: widget.currentUserModel.uid,
          reciever: widget.enduser.uid,
          text: msg);

      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatRoomModel.chatroomid)
          .collection("messages")
          .doc(messageModel.messageId)
          .set(messageModel.toMap());

      widget.chatRoomModel.updatedOn = Timestamp.now();
      widget.chatRoomModel.readMessage = null;
      widget.chatRoomModel.fromUser = widget.currentUserModel.uid;
      widget.chatRoomModel.lastMessage = msg;

      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatRoomModel.chatroomid)
          .set(widget.chatRoomModel.toMap())
          .then((value) => LocalNotificationServic.sendPushNotificatio(
              widget.enduser, msg!));
      final provider = Provider.of<LoadingProvider>(context, listen: false);
      provider.sendPhotoCmplete(value: true);

      // log("Message has been send");
    }

    // ! for just picture

    else if (msg == "" && imageFile != null) {
      UploadTask uploadTask = FirebaseStorage.instance
          .ref(
              "Pictures from ${widget.currentUserModel.fullName} to ${widget.enduser.fullName}")
          .child(randomName.toString())
          .putFile(imageFile!);

      TaskSnapshot snapshot = await uploadTask;

      // ! we need imageUrl of the profile photo inOrder to Upload it on FirebaseFirestore
      String imageUrl = await snapshot.ref.getDownloadURL();
      messageModel = MessageModel(
          createdOn: Timestamp.now(),
          image: imageUrl,
          messageId: uuid.v1(),
          seen: false,
          sender: widget.currentUserModel.uid,
          reciever: widget.enduser.uid,
          text: "");

      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatRoomModel.chatroomid)
          .collection("messages")
          .doc(messageModel.messageId)
          .set(messageModel.toMap())
          .then((value) => LocalNotificationServic.sendPushNotificatio(
              widget.enduser, "Photo"));

      widget.chatRoomModel.updatedOn = Timestamp.now();
      widget.chatRoomModel.readMessage = null;
      widget.chatRoomModel.fromUser = widget.currentUserModel.uid;
      widget.chatRoomModel.lastMessage = "photo";

      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatRoomModel.chatroomid)
          .set(widget.chatRoomModel.toMap());

      // log("Message has been send");

      final provider = Provider.of<LoadingProvider>(context, listen: false);
      provider.sendPhotoCmplete(value: true);
    }

    setState(() {
      imageFile = null;
    });
  }

  var spinkit = const SpinKitSpinningLines(
    color: Colors.black,
    size: 50.0,
  );

  // !  provider

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RandomName>(context);
    final secondProvider = Provider.of<LoadingProvider>(context);
    return Scaffold(
      backgroundColor: AppColors.backgroudColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroudColor,
        leadingWidth: 40,
        elevation: 0.5,
        leading: IconButton(
            icon: const Icon(
              CupertinoIcons.back,
              color: Colors.black87,
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
                  color: Colors.black87,
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
                    // log(dataSnapshot.docs.length.toString());

                    return dataSnapshot.docs.length != 0
                        ? ListView.builder(
                            reverse: true,
                            itemCount: dataSnapshot.docs.length,
                            itemBuilder: (context, index) {
                              // ! converting to message model
                              MessageModel currentMessage =
                                  MessageModel.fromMap(dataSnapshot.docs[index]
                                      .data() as Map<String, dynamic>);

                              String messgaeDate =
                                  DateFormat("EEE,dd MMM   hh:mm a").format(
                                      DateTime.fromMillisecondsSinceEpoch(
                                          currentMessage.createdOn!
                                              .millisecondsSinceEpoch));

                              var rand = Random();

                              return currentMessage.sender ==
                                          widget.currentUserModel.uid
                                              .toString() &&
                                      provider.disbale
                                  ? spinkit
                                  : Column(
                                      crossAxisAlignment:
                                          currentMessage.sender ==
                                                  widget.currentUserModel.uid
                                                      .toString()
                                              ? CrossAxisAlignment.end
                                              : CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          currentMessage.sender ==
                                                  widget.currentUserModel.uid
                                                      .toString()
                                              ? MainAxisAlignment.end
                                              : MainAxisAlignment.start,
                                      children: [
                                        InkWell(
                                          onTap: () {},
                                          child: messageContainer(
                                              emotion: rand.nextInt(4),
                                              context: context,
                                              image: currentMessage.image != ""
                                                  ? currentMessage.image
                                                  : null,
                                              messageText:
                                                  currentMessage.text == ""
                                                      ? null
                                                      : currentMessage.text
                                                          .toString(),
                                              sender: currentMessage.sender ==
                                                  widget.currentUserModel.uid
                                                      .toString(),
                                              time: messgaeDate),
                                        ),
                                        Visibility(
                                          visible: index == 0 &&
                                              secondProvider.send == false,
                                          // visible: provider.send && canShowNow,
                                          child: Container(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.4,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.7,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                color: Colors.grey.shade300
                                                //     image: DecorationImage(
                                                //   image: FileImage(imageFile!),
                                                // )
                                                ),
                                            child: Center(child: spinkit),
                                          ),
                                        )
                                      ],
                                    );
                            })
                        : Center(child: Image.asset("assets/noMessage.png"));
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
          color: AppColors.backgroudColor,
          child: Row(
            children: [
              CupertinoButton(
                  child: const Icon(
                    Icons.photo_camera,
                    color: Colors.black87,
                  ),
                  onPressed: () {
                    // sendMessage();

                    provider.randomNameChanger(value: provider.randomName + 1);
                    randomName = provider.randomName;
                    setState(() {});
                    showPhotoOption();
                  }),
              Flexible(
                  child: TextFormField(
                // textAlignVertical: TextAlignVertical.top,
                // textAlign: TextAlign.center,
                controller: messageController,
                style: TextStyle(fontSize: 14.sp, color: Colors.black87),
                cursorColor: Colors.black87,
                maxLines: null,
                // enabled: imageFile != null ? false : true,
                decoration: const InputDecoration(
                    contentPadding: EdgeInsets.only(
                      left: 15,
                    ),
                    hintText: "Type a messgae ...",
                    hintStyle: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.black87,
                      fontSize: 14,
                    ),
                    border: InputBorder.none),
              )),
              CupertinoButton(
                  child: const Icon(
                    Icons.send,
                    color: Colors.black87,
                  ),
                  onPressed: () {
                    sendMessage(msg: messageController.text.trim());
                    setState(() {
                      imageFile = null;
                    });
                  })
            ],
          ),
        )
      ]),
    );
  }
// !  This is Widget in which we will show messages to the user

  Widget messageContainer(
      {required int emotion,
      required BuildContext context,
      required String? messageText,
      required String? image,
      required String time,
      required bool sender}) {
    return Padding(
      padding: EdgeInsets.only(
          top: 7.h,
          bottom: 7.h,
          left: sender ? 40.w : 7.w,
          right: sender ? 7.w : 40.w),
      child: Row(
        crossAxisAlignment:
            sender ? CrossAxisAlignment.center : CrossAxisAlignment.center,
        mainAxisAlignment:
            sender ? MainAxisAlignment.end : MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Visibility(
            visible: sender == false,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: AssetImage(Emotions.emotions[emotion]),
                ),
                SizedBox(
                  width: 7,
                )
              ],
            ),
          ),
          Column(
            crossAxisAlignment:
                sender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            mainAxisAlignment:
                sender ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: sender
                          ? Radius.circular(15.r)
                          : Radius.circular(15.r),
                      topRight: sender
                          ? Radius.circular(15.r)
                          : Radius.circular(15.r),
                      bottomLeft:
                          sender ? Radius.circular(15.r) : Radius.circular(0.r),
                      bottomRight:
                          sender ? Radius.circular(0.r) : Radius.circular(15.r),
                    ),
                    color: sender
                        ? Colors.green.shade300
                        : Colors.blueGrey.shade300),
                child: ConstrainedBox(
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.7),
                    child: Column(
                      crossAxisAlignment: sender
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      mainAxisAlignment: sender
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: [
                        image != null
                            ? GestureDetector(
                                onTap: () {
                                  showModalBottomSheet(
                                      backgroundColor: Colors.transparent,
                                      constraints: BoxConstraints.expand(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: MediaQuery.of(context)
                                              .size
                                              .height),
                                      context: context,
                                      builder: (builder) {
                                        return Material(
                                          type: MaterialType.transparency,
                                          elevation: 0,
                                          child: Container(
                                            color: Colors.black,
                                            height: MediaQuery.of(context)
                                                .size
                                                .height,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Expanded(
                                                  child: Image.network(image,
                                                      fit: BoxFit.cover),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      });
                                },
                                child: Container(
                                  // color: AppColors.backgroudColor,
                                  // height: MediaQuery.of(context).size.height * 0.35,
                                  // width: MediaQuery.of(context).size.height * 0.35,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Image.network(
                                      image,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox(),
                        messageText != null
                            ? Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12.w, vertical: 8.h),
                                child: Text(
                                  messageText,
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 14.sp),
                                ),
                              )
                            : const SizedBox(),
                      ],
                    )),
              ),
              SizedBox(
                height: 3.h,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Text(
                  time,
                  style: TextStyle(fontSize: 9.sp, color: Colors.black87),
                ),
              ),
            ],
          ),
          Visibility(
            visible: sender,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 7,
                ),
                CircleAvatar(
                  backgroundColor: Colors.green.shade300,
                  backgroundImage: AssetImage(Emotions.emotions[emotion]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
