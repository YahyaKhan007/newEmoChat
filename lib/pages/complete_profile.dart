import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:simplechat/models/user_model.dart';
import 'package:simplechat/provider/loading_provider.dart';
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
  File? imageFile;
  TextEditingController fullNameController = TextEditingController();

  var spinkit = const SpinKitSpinningLines(
    color: Colors.black,
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
                    Navigator.of(context).pop;
                  },
                  title: const Text("Select from Gallery"),
                  leading: const Icon(Icons.photo_album),
                ),
                ListTile(
                  onTap: () {
                    selectImage(ImageSource.camera);
                    Navigator.of(context).pop;
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
    if (fullName == "" || imageFile == null) {
      log("Enterd all the fields");
      provider.changeUploadDataLoading(value: false);
    } else {
      uploadData();
    }
  }

// ! Check either the data is entered or not
  void uploadData() async {
    UploadTask uploadTask = FirebaseStorage.instance
        .ref("profilePictures")
        .child(widget.userModel.uid.toString())
        .putFile(imageFile!);

    TaskSnapshot snapshot = await uploadTask;

    // ! we need imageUrl of the profile photo inOrder to Upload it on FirebaseFirestore
    String imageUrl = await snapshot.ref.getDownloadURL();

    String? fullName = fullNameController.text.trim();

    widget.userModel.fullName = fullName.toString();
    widget.userModel.profilePicture = imageUrl;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userModel.uid!)
        .set(widget.userModel.toMap())
        .then((value) => ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Data Uploaded"))))
        .then((value) => provider.changeUploadDataLoading(value: false))
        .then((value) => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (builder) => HomePage(
                      firebaseUser: widget.firebaseUser,
                      userModel: widget.userModel,
                    ))));
  }

// ! Getting Provider Value
  gettingProvider() {
    provider = Provider.of<LoadingProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).colorScheme.background,
          title: const Text(
            "Complete Profile",
            style: TextStyle(),
          )),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CupertinoButton(
                  onPressed: () {
                    showPhotoOption();
                  },
                  child: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.background,
                    radius: 65,
                    backgroundImage:
                        (imageFile != null) ? FileImage(imageFile!) : null,
                    child: (imageFile == null)
                        ? const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 55,
                          )
                        : null,
                  )),
              TextFormField(
                controller: fullNameController,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade800),
                decoration: const InputDecoration(
                    labelText: "Full Name",
                    labelStyle: TextStyle(fontSize: 16)),
              ),
              const SizedBox(
                height: 30,
              ),
              GestureDetector(
                onTap: () {
                  checkValues();
                },
                child: provider.uploadDataLoading
                    ? spinkit
                    : Container(
                        height: 60,
                        width: 120,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Theme.of(context).colorScheme.background),
                        child: Center(
                            child: Text(
                          "Submit",
                          style: TextStyle(
                              color: Theme.of(context).canvasColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w700),
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
