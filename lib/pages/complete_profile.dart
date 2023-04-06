// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:simplechat/models/user_model.dart';
import 'package:simplechat/pages/zoom_drawer.dart';
import 'package:simplechat/provider/loading_provider.dart';
import 'package:simplechat/provider/user_model_provider.dart';
import 'package:simplechat/widgets/showLoading.dart';

import '../colors/colors.dart';
import '../models/models.dart';
import 'screens.dart';

class CompleteProfile extends StatefulWidget {
  // const CompleteProfile({super.key});

  final UserModel userModel;
  final User firebaseUser;

  const CompleteProfile(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  State<CompleteProfile> createState() => _CompleteProfileState();
}

class _CompleteProfileState extends State<CompleteProfile> {
  final TextEditingController searchUserController = TextEditingController();

  File? imageFile;
  TextEditingController fullNameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  static FirebaseMessaging messaging = FirebaseMessaging.instance;

  static String? token;

  var spinkit = const SpinKitSpinningLines(
    color: Colors.black,
    size: 40.0,
  );

  late LoadingProvider provider;

  @override
  void initState() {
    getToken();
    super.initState();
  }

  static Future<void> getToken() async {
    try {
      await messaging.requestPermission();

      await messaging.getToken().then((t) {
        if (t != null) {
          token = t;
          log("Push Token ----->   $t");
        }
      });
    } catch (e) {
      log("$e");
    }

    // log("Push Token ----->   $messaging.getToken()");
  }

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
    CroppedFile? croppedImage = await ImageCropper().cropImage(
        sourcePath: file.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 20);
    if (croppedImage != null) {
      // ! we need "a value of File Type" so here we are converting the from CropperdFile to File
      final File croppedFile = File(
        croppedImage.path,
      );
      setState(() {
        imageFile = croppedFile;
      });
    }
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
                    Navigator.of(context, rootNavigator: true).pop();
                    // Navigator.pop(context);
                  },
                  title: const Text("Select from Gallery"),
                  leading: const Icon(Icons.photo_album),
                ),
                ListTile(
                  onTap: () {
                    selectImage(ImageSource.camera);
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  title: const Text("Take a Photo"),
                  leading: const Icon(Icons.camera),
                ),
              ],
            ),
          );
        });
  }

// ! Check either the data is entered or not
  void checkValues(
      {required LoadingProvider provider,
      required UserModelProvider userModelProvider}) {
    String fullName = fullNameController.text.trim();
    if (fullName == "" ||
        imageFile == null ||
        bioController.text == "" ||
        token == "") {
      Loading.showAlertDialog(context, "Missing", "Entered all the data");
    } else {
      uploadData(provider: provider, userModelProvider: userModelProvider);
    }
  }

// ! Check either the data is entered or not
  void uploadData(
      {required LoadingProvider provider,
      required UserModelProvider userModelProvider}) async {
    // var provider = Provider.of<LoadingProvider>(context, listen: false);
    provider.changeLoading(value: true);

    UploadTask uploadTask = FirebaseStorage.instance
        .ref("profilePictures")
        .child(widget.userModel.uid.toString())
        .putFile(imageFile!);

    TaskSnapshot snapshot = await uploadTask;

    // ! we need imageUrl of the profile photo inOrder to Upload it on FirebaseFirestore
    String imageUrl = await snapshot.ref.getDownloadURL();

    String? fullName = fullNameController.text.trim();

    String? bio = bioController.text.trim();

    widget.userModel.fullName = fullName.toString();
    widget.userModel.bio = bio.toString();
    widget.userModel.profilePicture = imageUrl;
    widget.userModel.pushToken = token!;
    widget.userModel.accountType = dropdownvalue.toString();

    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userModel.uid!)
        .set(widget.userModel.toMap())
        .then((value) => ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Data Uploaded"))))
        // .then((value) => Navigator.popUntil(context, (route) => route.isFirst))
        .then((value) => provider.changeLoading(value: false))
        .then((value) => userModelProvider.updateUser(widget.userModel))
        .then((value) =>
            userModelProvider.updateFirebaseUser(widget.firebaseUser))
        .then((value) => Navigator.pushReplacement(
            context,
            PageTransition(
                duration: const Duration(milliseconds: 700),
                type: PageTransitionType.fade,
                child: MyHomePage(),
                isIos: true)));
  }

  // !    777&&&&&&&&&&&&&&&&&&&&&
  String dropdownvalue = 'Private';

  // List of items in our dropdown menu
  var items = [
    'Private',
    'Public',
  ];

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<LoadingProvider>(context, listen: true);
    var userModelProvider =
        Provider.of<UserModelProvider>(context, listen: true);

    return Scaffold(
      backgroundColor: AppColors.backgroudColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: AppBar(
            elevation: 0.1,
            automaticallyImplyLeading: false,
            leadingWidth: 90,
            centerTitle: true,
            backgroundColor: AppColors.backgroudColor,
            leading: SizedBox(
              height: 200,
              child: Image.asset("assets/logo.png"),
            ),
            title: const Text(
              "Complete Profile",
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            )),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 50.h,
              ),
              CupertinoButton(
                  onPressed: () {
                    // provider.changeLoading(value: false);

                    showPhotoOption();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [AppColors.containerShadow]),
                    child: CircleAvatar(
                      backgroundColor: AppColors.foregroundColor,
                      radius: 85.r,
                      backgroundImage:
                          (imageFile != null) ? FileImage(imageFile!) : null,
                      child: (imageFile == null)
                          ? Icon(
                              Icons.person,
                              color: Colors.grey.shade700,
                              size: 65.r,
                            )
                          : null,
                    ),
                  )),
              TextFormField(
                controller: fullNameController,
                style: const TextStyle(fontSize: 16, color: Colors.black),
                decoration: const InputDecoration(
                    labelText: "Full Name",
                    labelStyle: TextStyle(fontSize: 16, color: Colors.black)),
              ),
              TextFormField(
                controller: bioController,
                style: const TextStyle(fontSize: 16, color: Colors.black),
                decoration: const InputDecoration(
                    labelText: "Bio",
                    labelStyle: TextStyle(fontSize: 16, color: Colors.black)),
              ),
              Container(
                height: 70,
                // decoration: BoxDecoration(
                //     border: Border(bottom: BorderSide(color: Colors.black45))),
                child: Row(
                  children: [
                    Text(
                      "Account Type : ",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(
                      width: 30.w,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: DropdownButton(
                        isExpanded: true,
                        // Initial Value
                        value: dropdownvalue,
                        alignment: Alignment.center,

                        // Down Arrow Icon
                        icon: const Icon(Icons.keyboard_arrow_down),
                        underline: Container(
                          color: Colors.black45,
                          height: 0.5,
                        ),

                        // Array list of items
                        items: items.map((String items) {
                          return DropdownMenuItem(
                            value: items,
                            child: Text(items),
                          );
                        }).toList(),
                        // After selecting the desired option,it will
                        // change button value to selected value
                        onChanged: (String? newValue) {
                          setState(() {
                            dropdownvalue = newValue!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              GestureDetector(
                onTap: () {
                  checkValues(
                      provider: provider, userModelProvider: userModelProvider);
                },
                child: provider.loading
                    ? spinkit
                    : Container(
                        height: 70,
                        width: 100,
                        decoration: BoxDecoration(
                            color: AppColors.foregroundColor,
                            boxShadow: [AppColors.containerShadow],
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(50.r),
                                bottomRight: Radius.circular(50.r))),
                        child: Center(
                            child: Text(
                          "Submit",
                          style: kButtonTextStyle,
                        )),
                      ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
