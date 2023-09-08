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
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:simplechat/models/models.dart';
import 'package:simplechat/provider/user_model_provider.dart';
import 'package:simplechat/widgets/showLoading.dart';

import '../../colors/colors.dart';
import '../../provider/loading_provider.dart';
import '../../widgets/glass_morphism.dart';
import 'screens.dart';

class EditProfile extends StatefulWidget {
  final User firebaseUser;
  final UserModel userModel;

  const EditProfile(
      {super.key, required this.firebaseUser, required this.userModel});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  static FirebaseMessaging messaging = FirebaseMessaging.instance;

  TextEditingController bioController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  File? imageFile;

  @override
  void initState() {
    getoken();
    super.initState();
  }

  static Future<void> getoken() async {
    await messaging.requestPermission();

    await messaging.getToken().then((t) {
      if (t != null) {
        log("Push Token ----->   $t");
      }
    });

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
  void uploadData(
      {required LoadingProvider provider,
      required UserModelProvider userModelProvider}) async {
    // var provider = Provider.of<LoadingProvider>(context, listen: false);
    try {
      provider.changeLoading(value: true);
      String? imageUrl;
      if (imageFile != null) {
        UploadTask uploadTask = FirebaseStorage.instance
            .ref("profilePictures")
            .child(widget.userModel.uid.toString())
            .putFile(imageFile!);

        TaskSnapshot snapshot = await uploadTask;

        // ! we need imageUrl of the profile photo inOrder to Upload it on FirebaseFirestore
        imageUrl = await snapshot.ref.getDownloadURL();
      }

      String? fullName = nameController.text.trim();

      String? bio = bioController.text.trim();

      widget.userModel.fullName = fullName.toString();
      widget.userModel.bio = bio.toString();
      if (imageFile != null) {
        widget.userModel.profilePicture = imageUrl;
      }
      widget.userModel.bio = bioController.text.trim();

      userModelProvider.updateUser(widget.userModel);
      // widget.userModel.pushToken = token!;

      await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.userModel.uid!)
          .set(widget.userModel.toMap())
          .then((value) => ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("Data Uploaded"))))
          .then((value) => Navigator.pop(context))
          .then((value) => provider.changeLoading(value: false));
    } catch (e) {
      provider.changeLoading(value: false);
      Loading.showAlertDialog(context, "Error While Uploading", e.toString());
    }
  }

  var spinkit = const SpinKitSpinningLines(
    color: Colors.blue,
    size: 25.0,
  );
  final _formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LoadingProvider>(context);
    final userModelProvider = Provider.of<UserModelProvider>(context);
    return Scaffold(
        backgroundColor: AppColors.backgroudColor,
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(120.h),
            child: GlassDrop(
              width: MediaQuery.of(context).size.width,
              height: 120.h,
              blur: 20.0,
              opacity: 0.1,
              child: AppBar(
                actions: [
                  provider.loading
                      ? spinkit
                      : CupertinoButton(
                          child: CircleAvatar(
                            backgroundColor: Colors.black.withOpacity(0.7),
                            radius: 12.r,
                            child: Image.asset("assets/iconImages/done.png"),
                          ),
                          onPressed: () {
                            if (!_formkey.currentState!.validate()) {
                            } else {
                              uploadData(
                                  provider: provider,
                                  userModelProvider: userModelProvider);
                            }
                          })
                ],
                centerTitle: true,
                title: Text(
                  "Edit Profile",
                  style: GoogleFonts.blackOpsOne(
                      textStyle: Theme.of(context).textTheme.bodyMedium,
                      decorationColor: Colors.black,
                      color: Colors.black.withOpacity(0.7),
                      fontSize: 25.sp),
                ),
                elevation: 0,
                leading: CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.of(context).pop(),
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.black.withOpacity(0.7),
                    )
                    // Image.asset(
                    //   "assets/iconImages/back.png",
                    // ),
                    ),
                backgroundColor: Colors.blue.shade100,
              ),
            )),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("users")
              .where("email",
                  isEqualTo: FirebaseAuth.instance.currentUser!.email)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.hasData) {
                QuerySnapshot dataSnapshot = snapshot.data as QuerySnapshot;
                if (dataSnapshot.docs.isNotEmpty) {
                  Map<String, dynamic> userMap =
                      dataSnapshot.docs[0].data() as Map<String, dynamic>;
                  UserModel userModel = UserModel.fromMap(userMap);
                  nameController.text = userModel.fullName.toString();
                  bioController.text = userModel.bio.toString();
                  return Center(
                    child: Form(
                      key: _formkey,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 25.w, top: 40.h),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                        boxShadow: [avatarShadow],
                                        shape: BoxShape.circle),
                                    child: Stack(
                                      children: [
                                        (imageFile != null)
                                            ? CircleAvatar(
                                                radius: 60,
                                                backgroundImage:
                                                    FileImage(imageFile!),
                                              )
                                            : CircleAvatar(
                                                radius: 60,
                                                backgroundImage: NetworkImage(
                                                    userModel.profilePicture!),
                                              ),
                                        Visibility(
                                          visible: userModel.isVarified!,
                                          child: Positioned(
                                              bottom: 0,
                                              right: 0,
                                              child: CircleAvatar(
                                                  radius: 15.r,
                                                  child: Image.asset(
                                                    "assets/iconImages/blueTick.png",
                                                    color: Colors.blue,
                                                  ))),
                                        ),
                                        Positioned(
                                            top: 5,
                                            right: 5,
                                            child: CircleAvatar(
                                              radius: 12.r,
                                              backgroundColor: Colors.black,
                                              child: CupertinoButton(
                                                padding: EdgeInsets.zero,
                                                child: Image.asset(
                                                  "assets/iconImages/editPicture.png",
                                                  cacheHeight: 40,
                                                  scale: 3,
                                                  color: Colors.white,
                                                ),
                                                onPressed: () {
                                                  showPhotoOption();
                                                },
                                              ),
                                            ))
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 20.w,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 200.w,
                                        height: 40.h,
                                        child: TextFormField(
                                          style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w600),
                                          validator: (value) {
                                            if (!RegExp(r'^[a-z A-Z]+$')
                                                .hasMatch(value!)) {
                                              return "Enter Correct Name";
                                            } else {
                                              return null;
                                            }
                                          },
                                          scrollPadding: EdgeInsets.zero,
                                          controller: nameController,
                                          decoration: InputDecoration(
                                            errorBorder: OutlineInputBorder(
                                                gapPadding: 6.0),
                                            contentPadding: EdgeInsets.zero,
                                            hintStyle: TextStyle(
                                                color: Colors.black87,
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 7,
                                      ),
                                      Text(
                                        userModel.email!,
                                        style: TextStyle(
                                            color: Colors.black87,
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.w300),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                            option(context,
                                label: "Member Since",
                                value: DateFormat("EEE dd MMM   hh:mm").format(
                                    DateTime.fromMillisecondsSinceEpoch(
                                        userModel.memberSince!
                                            .millisecondsSinceEpoch))),
                            Edit(
                                context: context,
                                controller: bioController,
                                title: "Bio")
                          ]),
                    ),
                  );
                } else {
                  return const Text("NoOne Found");
                }
              } else {
                return const CircularProgressIndicator();
              }
            } else {
              return Center(
                  child: const SpinKitSpinningLines(
                color: Colors.black,
                size: 40.0,
              ));
            }
          },
        ));
  }
}

Widget Edit(
    {required BuildContext context,
    required TextEditingController controller,
    required String title}) {
  return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 15,
          ),
          Text(
            title,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
                color: Colors.blue),
          ),
          SizedBox(
            width: 75.w,
          ),
          Expanded(
            child: TextField(
              style: TextStyle(
                fontSize: 13.sp,
              ),
              controller: controller,
              decoration: InputDecoration(
                  border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade400))),
            ),
          ),
          SizedBox(
            width: 15.w,
          ),
        ],
      ));
}
