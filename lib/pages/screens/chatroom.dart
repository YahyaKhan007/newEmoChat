// ignore_for_file: unused_local_variable

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:simplechat/constants/emotions.dart';
import 'package:simplechat/main.dart';
import 'package:simplechat/notification/local_notification.dart';
import 'package:simplechat/pages/screens/screens.dart';
import 'package:simplechat/provider/loading_provider.dart';
import 'package:simplechat/provider/modeprovider.dart';
import 'package:simplechat/provider/randomNameGenerator.dart';
import 'package:simplechat/provider/spaceControllerProvider.dart';
import 'package:simplechat/provider/user_model_provider.dart';
import 'package:simplechat/widgets/glass_morphism.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

import '../../colors/colors.dart';
import '../../models/models.dart';
import '../../provider/tokenProvider.dart';
import '../../widgets/static.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class ChatRoom extends StatefulWidget {
  const ChatRoom(
      {super.key,
      required this.currentUserModel,
      required this.firebaseUser,
      required this.enduser,
      required this.chatRoomModel,
      required this.spaceControlProvider,
      required this.size,
      required this.modeProvider});
  final SpaceControlProvider spaceControlProvider;

  final Size size;
  final UserModel enduser;
  final User firebaseUser;
  final ChatRoomModel chatRoomModel;
  final UserModel currentUserModel;
  final ModeProvider modeProvider;

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  final KeyboardVisibilityController keyboardController =
      KeyboardVisibilityController();

  late int randomName;
  File? imageFile;
  final TextEditingController messageController = TextEditingController();
  final TextEditingController messageNextController = TextEditingController();
  late final UserModelProvider userModelProvider;

  // * INIT STATE
  @override
  void initState() {
    super.initState();
    userModelProvider = Provider.of<UserModelProvider>(context, listen: false);
    print(userModelProvider);

    // ! for keyboard hides
    keyboardController.onChange.listen((bool isVisible) {
      if (!isVisible) {
        _focusNode.unfocus();
      }
    });
// ! ------------------------------------
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        widget.spaceControlProvider.changeHeight(hyte: widget.size.height / 3);
        _startCapturing();
      } else {
        widget.spaceControlProvider.changeHeight(hyte: 0.h);
        _stopCapturing();
      }
    });
    _initializeCamera();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      String? title = message.notification!.title;
      String? body = message.notification!.body;
      AwesomeNotifications().createNotification(
          content: NotificationContent(
              id: 123,
              channelKey: 'call_channel',
              title: title,
              body: body,
              category: NotificationCategory.Call,
              wakeUpScreen: true,
              fullScreenIntent: true,
              autoDismissible: true,
              backgroundColor: Colors.orange),
          actionButtons: [
            NotificationActionButton(
              key: 'ACCEPT',
              color: Colors.green,
              label: 'Accept Call',
              autoDismissible: true,
            ),
            NotificationActionButton(
              key: 'REJECT',
              label: 'Reject Call',
              color: Colors.red,
              autoDismissible: true,
            ),
          ]);

      AwesomeNotifications().actionStream.listen((event) {
        if (event.buttonKeyPressed == "REJECT") {
          /// 1.2.2. de-initialization ZegoUIKitPrebuiltCallInvitationService
          /// when app's user is logged out
          ZegoUIKitPrebuiltCallInvitationService().uninitCallkitService();
          print("Call Rejected");
        } else if (event.buttonKeyPressed == 'ACCEPT') {
          print("Call Accepted");
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (builder) => CallPage(
                      currentUserModel: widget.currentUserModel,
                      endUserModel: widget.enduser,
                      callId: widget.enduser.pushToken!)));
        }
      });
    });
  }

  // *  Screen Height Keyboard
  double estimateKeyboardHeight(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    double screenHeight = mediaQuery.size.height;
    double viewInsetsBottom = mediaQuery.viewInsets.bottom;

    // Subtract the remaining screen height from the total height to get the keyboard height
    double keyboardHeight = screenHeight - viewInsetsBottom;

    return keyboardHeight;
  }

// ****************

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
    // try {
    //   // final body = {
    //   //   "to": chatUser.pushToken,
    //   //   "notification": {
    //   //     "title": chatUser.fullName,
    //   //     "body": msg,
    //   //     "android_channel_id": "chats"
    //   //   },
    //   };

    // var res = await post(Uri.parse("https://fcm.googleapis.com/fcm/send"),
    // headers: {
    //   HttpHeaders.contentTypeHeader: 'application/json',
    //   HttpHeaders.authorizationHeader:
    //       'key=AAAAXk1Z2Yw:APA91bEJJT8NzzNAbx-pNe3_h6uB5x84hga6FtIatZmRSXk40p6FzF9H7iVoQ9jmVa_rDM79hfuQxSjssxJQMuXMCCfn_X3q_4dvZXl7z-MxPCxMG5-hyfPYlxI5A0DQlIxq5ib0SqCV',
    // },
    // body: jsonEncode(body));
    // log("Response status : ${res.statusCode}");
    // log("Response body : ${res.body}");
    // } catch (e) {
    //   // log("Send Notification  E --->      $e");
    // }
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
                                        emotion: widget.modeProvider.mode,
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
                    Navigator.of(context).pop(true);
                  },
                  title: const Text("Select from Gallery"),
                  leading: const Icon(Icons.photo_album),
                ),
                ListTile(
                  onTap: () {
                    selectImage(ImageSource.camera);
                    Navigator.of(context).pop(true);
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
  void sendMessage({required String? msg, required String? emotion}) async {
    MessageModel? messageModel;
    // String? msg = messageController.text.trim();
    messageController.clear();

// ! for simple message
    if (msg != "" && imageFile == null) {
      messageModel = MessageModel(
          emotion: emotion,
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
  }

  var spinkit = const SpinKitCircle(
    color: Colors.blue,
    size: 25.0,
  );

  // !  provider

// ? *****************************************************
// ? *****************************************************
// ? *****************************************************
// ? *****************************************************

  // ! *************************
  // ! *************************
  // ! *************************

  // * Capturing Picture

  String? mostFrequent = null;
  String? secondFrequent = null;
  final dio = Dio();
  List<String> emotions = [];
  late CameraController _controller;
  Timer? _timer;
  File? capturedImage;

  final FocusNode _focusNode = FocusNode();

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front);
    _controller = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    await _controller.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startCapturing() {
    if (!_controller.value.isInitialized) {
      _initializeCamera();
    }
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (_controller.value.isInitialized) {
        _captureImage();
      }
    });
  }

  void _stopCapturing() {
    _timer?.cancel();
    // print("{$emotions}");
    _focusNode.unfocus();
    setState(() {
      capturedImage = null;
    });
    // _controller.dispose();
  }

  Future<void> _captureImage() async {
    try {
      final XFile file = await _controller.takePicture();

      Uint8List? imageBytes = await File(file.path).readAsBytes();
      String capturedImageBase64 = base64.encode(imageBytes);
      fetchData(base64String: capturedImageBase64);
      log("Picture hase been taken");
      // log(capturedImageBase64);
    } catch (e) {
      print('Error capturing image: $e');
    }
  }

  // !     REQUEST THE SERVER

  void fetchData({required String base64String}) async {
    try {
      print("it came here");
      final response = await dio.get("http://146.190.212.199:5005/detect",
          data: {'image': '${base64String}'});

      if (response.statusCode == 200) {
        print("aslo came ....................");
        Map<String, dynamic>? responseData = null;
        responseData = response.data;
        if (responseData != null) {
          log("\n\n\n\n============>\n\n\n\n  Emotion has been added  \n\n\n\n\n============>\n\n\n\n");
          widget.modeProvider.updateEmotionList(responseData['emotion']);

          log("${widget.modeProvider.emotionList}");
        }

        // HTTP status code 200 indicates success
        log("API Success");
        print("Request successful");
        print("Response data: ${responseData}");
      } else {
        log("API Not Hit");

        // Handle different HTTP status codes here
        print("Request failed with status code ${response.statusCode}");
        print("Response data: ${response.data}");
      }
    } catch (e) {
      // Handle exceptions, such as network errors or timeouts
      print("Problem occurred: $e");
    }
  }

// * Finding modes
  String? findMode({required modes}) {
    log("Came to mode Finder dunction");
    log("List of Modes --> ${widget.modeProvider.emotionList}");
    Map<String, int> frequencyMap = {};

    for (String str in modes) {
      if (frequencyMap.containsKey(str)) {
        frequencyMap[str] =
            frequencyMap[str]! + 1; // Ensure the entry exists and increment it.
      } else {
        frequencyMap[str] = 1;
      }
    }

    var sortedEntries = frequencyMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    mostFrequent = sortedEntries.isNotEmpty ? sortedEntries.first.key : "";
    secondFrequent = sortedEntries.length > 1 ? sortedEntries[1].key : "";

    print("mostFrequent -------> $mostFrequent");
    print("secondFrequent ------> $secondFrequent");
    if (mostFrequent == "neutral" &&
        secondFrequent != "" &&
        secondFrequent != 'neutral') {
      return secondFrequent;
    } else if (mostFrequent == "neutral" && secondFrequent == "") {
      return mostFrequent;
    } else if (mostFrequent != "neutral") {
      return mostFrequent;
    } else {
      return 'neutral';
    }
  }
// * End Capturing
  // ! ************************************************
  // ! ************************************************
  // ! ************************************************
  // ! ************************************************

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RandomName>(context);

    final secondProvider = Provider.of<LoadingProvider>(context);
    return GestureDetector(
      onTap: () {
        _focusNode.unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(120),
          child: GlassDrop(
            width: MediaQuery.of(context).size.width,
            height: 110.h,
            blur: 0.0,
            opacity: 0.4,
            child: AppBar(
              backgroundColor: Colors.blue.shade100,
              // backgroundColor: Colors.transparent,
              leadingWidth: 50,
              elevation: 0.3,
              leading: InkWell(
                onTap: () {
                  Navigator.of(context, rootNavigator: true).pop();
                },
                child: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.black.withOpacity(0.7),
                ),
              ),
              //  Image.asset("assets/iconImages/back.png"),

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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                            radius: 23.r,
                            backgroundImage: NetworkImage(
                              widget.enduser.profilePicture!,
                            )),
                        Visibility(
                          visible: widget.enduser.isVarified!,
                          child: Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircleAvatar(
                                  radius: 8.r,
                                  child: Image.asset(
                                    "assets/iconImages/blueTick.png",
                                    color: Colors.blue,
                                  ))),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 15.sp,
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.enduser.fullName!,
                          style: TextStyle(
                              color: Colors.black.withOpacity(0.7),
                              fontWeight: FontWeight.bold,
                              fontSize: 15.sp,
                              overflow: TextOverflow.ellipsis),
                        ),
                        Text(
                          widget.enduser.email!,
                          style: TextStyle(
                              color: Colors.black.withOpacity(0.7),
                              fontWeight: FontWeight.bold,
                              fontSize: 10.sp,
                              fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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
                      QuerySnapshot dataSnapshot =
                          snapshot.data as QuerySnapshot;

                      return dataSnapshot.docs.length != 0
                          ? ListView.builder(
                              reverse: true,
                              itemCount: dataSnapshot.docs.length,
                              itemBuilder: (context, index) {
                                // ! converting to message model
                                MessageModel currentMessage =
                                    MessageModel.fromMap(
                                        dataSnapshot.docs[index].data()
                                            as Map<String, dynamic>);
                                int emotion;
                                if (currentMessage.emotion != null) {
                                  emotion = Emotions.findStringIndex(
                                      currentMessage.emotion!);
                                  print(emotion);
                                }

                                String messgaeDate =
                                    DateFormat("EEE,dd MMM   hh:mm a").format(
                                        DateTime.fromMillisecondsSinceEpoch(
                                            currentMessage.createdOn!
                                                .millisecondsSinceEpoch));

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
                                            onTap: () {
                                              _focusNode.unfocus();
                                            },
                                            child: messageContainer(
                                                emotion: currentMessage.emotion,
                                                context: context,
                                                image: currentMessage.image !=
                                                        ""
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
            decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20))),
            // color: Colors.blue,
            child: Row(
              children: [
                CupertinoButton(
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                    child: CircleAvatar(
                        backgroundColor: AppColors.foregroundColor,
                        radius: 15.r,
                        child: Icon(Icons.camera_alt)),
                    onPressed: () {
                      // sendMessage();

                      provider.randomNameChanger(
                          value: provider.randomName + 1);
                      randomName = provider.randomName;
                      setState(() {});
                      showPhotoOption();
                    }),
                Flexible(
                    child: TextFormField(
                  // textAlignVertical: TextAlignVertical.top,
                  // textAlign: TextAlign.center,
                  controller: messageController,
                  focusNode: _focusNode,
                  // enabled: false,
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
                    child: CircleAvatar(
                        backgroundColor: AppColors.foregroundColor,
                        radius: 20.r,
                        child: Image.asset("assets/iconImages/send.png")),
                    onPressed: () {
                      // * Dummy Emotion
                      // * as their is soe issue in model server
                      // _stopCapturing();
                      var mode =
                          findMode(modes: widget.modeProvider.emotionList);
                      //*
                      //!
                      //~
                      //^
                      //?
                      widget.modeProvider.updateMode(mode!);
                      //*
                      //!
                      //~
                      //^
                      //?
                      // modeProvider.changeMode(currentEmotion!);
                      print("The FInal mode is ${widget.modeProvider.mode}");

                      log('=====>  ${widget.modeProvider.emotionList}');

                      sendMessage(
                          msg: messageController.text.trim(),
                          emotion: widget.currentUserModel.sendEmotion!
                              ? widget.modeProvider.mode
                              : null);
                      widget.modeProvider.emotionList.clear();
                    })
              ],
            ),
          ),
          SizedBox(
            height: widget.spaceControlProvider.height,
          )
        ]),
      ),
    );
  }
// !  This is Widget in which we will show messages to the user

  Widget messageContainer(
      {required String? emotion,
      required BuildContext context,
      required String? messageText,
      required String? image,
      required String time,
      required bool sender}) {
    return Padding(
      padding: EdgeInsets.only(
          top: 3.h,
          bottom: 3.h,
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
                    radius: 13.sp,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: emotion != null
                        ? Emotions.findStringIndex(emotion) != -1
                            ? AssetImage(Emotions
                                .emotions[(Emotions.findStringIndex(emotion))])
                            : AssetImage("assets/iconImages/NoEmotion.jpg")
                        : AssetImage("assets/iconImages/NoEmotion.jpg")),
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
                    color: sender ? Colors.blueGrey.shade500 : Colors.blue),
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
                                  if (_focusNode.hasFocus) {
                                    _focusNode.unfocus();
                                  } else {
                                    showModalBottomSheet(
                                        backgroundColor: Colors.transparent,
                                        constraints: BoxConstraints.expand(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
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
                                  }
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
                                    horizontal: 10.w, vertical: 5.h),
                                child: Text(
                                  messageText,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 11.sp),
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
                    radius: 13.sp,
                    backgroundColor: Colors.green.shade300,
                    backgroundImage: emotion != null
                        ? Emotions.findStringIndex(emotion) != -1
                            ? AssetImage(Emotions
                                .emotions[(Emotions.findStringIndex(emotion))])
                            : AssetImage("assets/iconImages/NoEmotion.jpg")
                        : AssetImage("assets/iconImages/NoEmotion.jpg")),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> sendPushNotification() async {
    try {
      print(
          "====================================================================\n============================================ CAME HEREEEEEEEEEEEEEEEEEEEEEE\n========================================================\n================================");
      String url = 'https://fcm.googleapis.com/fcm/send';

      http.Response response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization':
              'key=AAAAXk1Z2Yw:APA91bEJJT8NzzNAbx-pNe3_h6uB5x84hga6FtIatZmRSXk40p6FzF9H7iVoQ9jmVa_rDM79hfuQxSjssxJQMuXMCCfn_X3q_4dvZXl7z-MxPCxMG5-hyfPYlxI5A0DQlIxq5ib0SqCV',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'body': widget.currentUserModel.fullName,
              'title': 'Incoming Call',
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'EmoChat Incoming Call',
              'id': '1',
              'status': 'done'
            },
            'to': widget.enduser.pushToken,
          },
        ),
      );
      response;
    } catch (e) {
      e;
    }
  }
}

class TextFieldCustom extends StatelessWidget {
  const TextFieldCustom({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: TextFormField(
      decoration: InputDecoration(border: OutlineInputBorder()),
    ));
  }
}

class CallPage extends StatelessWidget {
  final UserModel endUserModel;
  final UserModel currentUserModel;
  final String callId;
  const CallPage(
      {super.key,
      required this.endUserModel,
      required this.currentUserModel,
      required this.callId});

  @override
  Widget build(BuildContext context) {
    TokenProvider tokenProvider =
        Provider.of<TokenProvider>(context, listen: false);
    return SafeArea(
        child: Scaffold(
            body: ZegoUIKitPrebuiltCall(
                appID: Statics.appID,
                appSign: Statics.appSign,
                callID: "123",
                userID: currentUserModel.pushToken!,
                userName: currentUserModel.fullName!,
                // userName: 'userName _1234',
                config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
                  ..onOnlySelfInRoom = (context) {
                    Navigator.of(context).pop();
                  })));
  }
}
