// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
import 'package:simplechat/provider/loading_provider.dart';
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

  var spinkit = const SpinKitSpinningLines(
    color: Colors.white,
    size: 50.0,
  );

  late LoadingProvider provider;

  @override
  void initState() {
    gettingProvider();
    super.initState();
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
                    Navigator.pop(context);
                  },
                  title: const Text("Select from Gallery"),
                  leading: const Icon(Icons.photo_album),
                ),
                ListTile(
                  onTap: () {
                    selectImage(ImageSource.camera);

                    Navigator.pop(context);
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
  void checkValues() {
    provider.changeUploadDataLoading(value: true);
    String fullName = fullNameController.text.trim();
    if (fullName == "" || imageFile == null || bioController.text == "") {
      Loading.showAlertDialog(context, "Missing", "Entered all the data");
    } else {
      uploadData();
    }
  }

// ! Check either the data is entered or not
  void uploadData() async {
    Loading.showLoadingDialog(
        context, "Wait! while your data is being uploading");
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

    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userModel.uid!)
        .set(widget.userModel.toMap())
        .then((value) => ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Data Uploaded"))))
        .then((value) => provider.changeUploadDataLoading(value: false))
        .then((value) => Navigator.popUntil(context, (route) => route.isFirst))
        .then((value) => Navigator.pushReplacement(
            context,
            PageTransition(
                duration: const Duration(milliseconds: 700),
                type: PageTransitionType.fade,
                child: HomePage(
                  firebaseUser: widget.firebaseUser,
                  userModel: widget.userModel,
                ),
                isIos: true)));
  }

// ! Getting Provider Value
  gettingProvider() {
    provider = Provider.of<LoadingProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroudColor,
      appBar: AppBar(
          elevation: 0.1,
          automaticallyImplyLeading: false,
          centerTitle: true,
          backgroundColor: AppColors.backgroudColor,
          title: const Text(
            "Complete Profile",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          )),
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
              const SizedBox(
                height: 30,
              ),
              GestureDetector(
                onTap: () {
                  checkValues();
                },
                child: Container(
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
