import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:simplechat/provider/modeprovider.dart';

import '../../../widgets/drawer_icon.dart';
import '../../../widgets/glass_morphism.dart';
import 'newpage.dart';

class PictureEmotion extends StatefulWidget {
  PictureEmotion({super.key});

  @override
  State<PictureEmotion> createState() => _PictureEmotionState();
}

class _PictureEmotionState extends State<PictureEmotion> {
  late ModeProvider modeProvider;
  @override
  void initState() {
    modeProvider = Provider.of<ModeProvider>(context, listen: false);
    super.initState();
  }

  final dio = Dio();

  bool show = false;

  // get dio => null;

// ! Selecting the Image
  void selectImage(ImageSource source) async {
    XFile? pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Done taking picture"),
        duration: Duration(seconds: 3),
      ));

      log("DOne with taking pix");
      // ! we are cropping the image now
      // cropImage(pickedFile);
      modeProvider.updateImage(File(pickedFile.path));
    }
  }

  void convertToBase64() async {
    Uint8List? _bytes = await modeProvider.imageFile!.readAsBytes();

    modeProvider.updateBase64Image(base64.encode(_bytes));

    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //   content: Text("Updated"),
    //   duration: Duration(seconds: 3),
    // ));
  }

// ! Cropping the Image
  // void cropImage(XFile file) async {
  //   CroppedFile? croppedImage = await ImageCropper().cropImage(
  //       sourcePath: file.path,
  //       aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
  //       compressQuality: 20);
  //   if (croppedImage != null) {
  //     // ! we need "a value of File Type" so here we are converting the from CropperdFile to File
  //     final File croppedFile = File(
  //       croppedImage.path,
  //     );

  //   }
  // }

  // ! Options for picking a photo
  void showPhotoOption() {
    showDialog(
        context: context,
        builder: (builder) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Text(
              "Upload profile photo",
              style: TextStyle(
                  color: Colors.blue,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  onTap: () {
                    selectImage(ImageSource.gallery);
                    Navigator.of(context, rootNavigator: true).pop();
                    // Navigator.pop(context);
                  },
                  title: const Text(
                    "Select from Gallery",
                    style: TextStyle(
                      color: Colors.blue,
                    ),
                  ),
                  leading: const Icon(
                    Icons.photo_album,
                    color: Colors.blue,
                  ),
                ),
                ListTile(
                  onTap: () {
                    selectImage(
                      ImageSource.camera,
                    );
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  title: const Text(
                    "Take a Photo",
                    style: TextStyle(
                      color: Colors.blue,
                    ),
                  ),
                  leading: const Icon(
                    Icons.camera,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          );
        });
  }

// !     REQUEST THE SERVER

  void fetchData() async {
    try {
      log(modeProvider.base64Image.toString());

      final response = await dio.get("http://146.190.212.199:5005/detect",
          data: {'image': '${modeProvider.base64Image}'});

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = response.data;

        // ^ Update Mode/Emotion
        modeProvider.updateMode(responseData["emotion"]);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(120.h),
          child: GlassDrop(
            width: MediaQuery.of(context).size.width,
            height: 120.h,
            blur: 20.0,
            opacity: 0.1,
            child: AppBar(
              backgroundColor: Colors.blue.shade100,
              leadingWidth: 70.w,
              centerTitle: true,
              title: Text(
                "Detect Emotion",
                style: GoogleFonts.blackOpsOne(
                    textStyle: Theme.of(context).textTheme.bodyMedium,
                    decorationColor: Colors.black,
                    color: Colors.black.withOpacity(0.7),
                    fontSize: 25.sp),
              ),
              elevation: 0,
              leading: drawerIcon(context),
            ),
          )),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Emotion is --> ${modeProvider.mode}",
              style: GoogleFonts.blackOpsOne(
                  textStyle: Theme.of(context).textTheme.bodyMedium,
                  decorationColor: Colors.black,
                  color: Colors.black.withOpacity(0.7),
                  fontSize: 18.sp),
            ),
            Row(
              children: [
                Visibility(
                  visible: show,
                  child: Container(
                    width: 200.w,
                    height: 100.h,
                    child: Text(
                      "base64 --> ${modeProvider.base64Image == '' ? "nothing yet" : modeProvider.base64Image}",
                      style: TextStyle(fontSize: 11.sp),
                    ),
                  ),
                ),
                TextButton(
                    onPressed: () {
                      setState(() {
                        show = !show;
                      });
                    },
                    child: Text(
                      show ? "Hide base64 address" : "Show base64 address",
                      style: TextStyle(fontSize: 11),
                    ))
              ],
            ),
            SizedBox(
              height: 30.w,
            ),
            Center(
              child: Container(
                height: 300.h,
                width: 300.w,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.r),
                    color: Colors.grey.shade500),
                child:
                    //  Image.asset("assets/modelPix/3.jpeg")

                    (modeProvider.imageFile == null)
                        ? Icon(
                            Icons.person,
                            color: Colors.blue,
                            size: 65.r,
                          )
                        : Image.file(
                            modeProvider.imageFile!,
                            fit: BoxFit.cover,
                          ),
              ),
            ),
            SizedBox(
              height: 20.h,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all(
                          EdgeInsets.symmetric(horizontal: 20.w)),
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                      backgroundColor: MaterialStateProperty.all(Colors.blue),
                    ),
                    onPressed: () {
                      modeProvider.updateBase64Image("");
                      modeProvider.updateMode("");

                      showPhotoOption();
                    },
                    child: Text("select picture")),
                ElevatedButton(
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all(
                          EdgeInsets.symmetric(horizontal: 20.w)),
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                      backgroundColor: MaterialStateProperty.all(Colors.blue),
                    ),
                    onPressed: () async {
                      convertToBase64();
                      fetchData();

                      setState(() {
                        // _emotion = emotion.toString();
                      });

                      print(modeProvider.base64Image);
                    },
                    child: Text("Detect Emotion"))
              ],
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (builder) =>
                              NewPage(text: modeProvider.base64Image)));
                },
                child: Text("New Page"))
          ],
        ),
      ),
    );
  }
}

class DummyPage3 extends StatefulWidget {
  const DummyPage3({super.key, required this.modeProvider});

  final ModeProvider modeProvider;

  @override
  State<DummyPage3> createState() => _DummyPage3State();
}

class _DummyPage3State extends State<DummyPage3> {
  final dio = Dio();

  bool show = false;

  // get dio => null;

// ! Selecting the Image
  Future<void> selectImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: source);

      if (pickedFile == null) {
        // User canceled image selection
        return;
      }

      final file = File(pickedFile.path);

      widget.modeProvider.updateImage(file);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Done taking picture"),
        duration: Duration(seconds: 3),
      ));

      log("Done with taking picture");

      await convertToBase64(file);
    } catch (e) {
      print('Error selecting or processing image: $e');
      // Handle the error gracefully, e.g., show an error message to the user.
    }
  }

  Future<void> convertToBase64(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      widget.modeProvider.updateBase64Image(base64Image);
    } catch (e) {
      print('Error converting image to base64: $e');
      // Handle the error gracefully, e.g., show an error message to the user.
    }
  }

  // ! Options for picking a photo
  void showPhotoOption() {
    showDialog(
        context: context,
        builder: (builder) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Text(
              "Upload profile photo",
              style: TextStyle(
                  color: Colors.blue,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  onTap: () {
                    selectImage(ImageSource.gallery);
                    Navigator.of(context, rootNavigator: true).pop();
                    // Navigator.pop(context);
                  },
                  title: const Text(
                    "Select from Gallery",
                    style: TextStyle(
                      color: Colors.blue,
                    ),
                  ),
                  leading: const Icon(
                    Icons.photo_album,
                    color: Colors.blue,
                  ),
                ),
                ListTile(
                  onTap: () {
                    selectImage(
                      ImageSource.camera,
                    );
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  title: const Text(
                    "Take a Photo",
                    style: TextStyle(
                      color: Colors.blue,
                    ),
                  ),
                  leading: const Icon(
                    Icons.camera,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          );
        });
  }

// !     REQUEST THE SERVER

  void fetchData() async {
    try {
      widget.modeProvider.updateLoading(true);
      log(widget.modeProvider.base64Image.toString());

      final response = await dio.get("http://146.190.212.199:5005/detect",
          data: {'image': '${widget.modeProvider.base64Image}'});

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = response.data;

        // ^ Update Mode/Emotion
        widget.modeProvider.updateMode(responseData["emotion"]);

        // HTTP status code 200 indicates success
        log("API Success");
        print("Request successful");
        print("Response data: ${responseData}");
        widget.modeProvider.updateLoading(false);
      } else {
        log("API Not Hit");
        widget.modeProvider.updateLoading(false);

        // Handle different HTTP status codes here
        print("Request failed with status code ${response.statusCode}");
        print("Response data: ${response.data}");
      }
    } catch (e) {
      widget.modeProvider.updateLoading(false);

      // Handle exceptions, such as network errors or timeouts
      print("Problem occurred: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(120.h),
          child: GlassDrop(
            width: MediaQuery.of(context).size.width,
            height: 120.h,
            blur: 20.0,
            opacity: 0.1,
            child: AppBar(
              backgroundColor: Colors.blue.shade100,
              leadingWidth: 70.w,
              centerTitle: true,
              title: Text(
                "Detect Emotion",
                style: GoogleFonts.blackOpsOne(
                    textStyle: Theme.of(context).textTheme.bodyMedium,
                    decorationColor: Colors.black,
                    color: Colors.black.withOpacity(0.7),
                    fontSize: 25.sp),
              ),
              elevation: 0,
              leading: drawerIcon(context),
            ),
          )),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Emotion is --> ${widget.modeProvider.mode}",
              style: GoogleFonts.blackOpsOne(
                  textStyle: Theme.of(context).textTheme.bodyMedium,
                  decorationColor: Colors.black,
                  color: Colors.black.withOpacity(0.7),
                  fontSize: 18.sp),
            ),
            Row(
              children: [
                Visibility(
                  visible: true,
                  child: Container(
                    width: 250.w,
                    height: 60.h,
                    child: Text(
                      "base64 --> ${widget.modeProvider.base64Image == '' ? "nothing yet" : widget.modeProvider.base64Image}",
                      style: TextStyle(fontSize: 11.sp),
                    ),
                  ),
                ),
                TextButton(
                    onPressed: () {
                      setState(() {
                        show = !show;
                      });
                    },
                    child: Text(
                      "",
                      // show ? "Hide base64 address" : "Show base64 address",
                      style: TextStyle(fontSize: 11),
                    )),
              ],
            ),
            SizedBox(
              height: 30.w,
            ),
            Center(
              child: Container(
                height: 300.h,
                width: 300.w,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.r),
                    color: Colors.grey.shade500),
                child:
                    //  Image.asset("assets/modelPix/3.jpeg")

                    (widget.modeProvider.imageFile == null)
                        ? Icon(
                            Icons.person,
                            color: Colors.blue,
                            size: 65.r,
                          )
                        : Image.file(
                            widget.modeProvider.imageFile!,
                            fit: BoxFit.cover,
                          ),
              ),
            ),
            SizedBox(
              height: 20.h,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all(
                          EdgeInsets.symmetric(horizontal: 20.w)),
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                      backgroundColor: MaterialStateProperty.all(Colors.blue),
                    ),
                    onPressed: () {
                      widget.modeProvider.updateBase64Image("");
                      widget.modeProvider.updateMode("");
                      widget.modeProvider.updateImage(null);

                      showPhotoOption();
                    },
                    child: Text("select picture")),
                ElevatedButton(
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all(
                          EdgeInsets.symmetric(horizontal: 20.w)),
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                      backgroundColor: MaterialStateProperty.all(Colors.blue),
                    ),
                    onPressed: () async {
                      // convertToBase64();
                      fetchData();

                      // setState(() {
                      //   // _emotion = emotion.toString();
                      // });

                      print(widget.modeProvider.base64Image);
                    },
                    child: widget.modeProvider.showloading
                        ? CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : Text("Detect Emotion")),
              ],
            ),
            TextButton.icon(
                label: Text("Clear vars"),
                onPressed: () {
                  widget.modeProvider.updateLoading(false);
                  print(widget.modeProvider.showloading);
                },
                icon: Icon(Icons.clean_hands)),
            ElevatedButton(
                onPressed: () {
                  if (widget.modeProvider.imageFile != null)
                    convertToBase64(widget.modeProvider.imageFile!);
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (builder) =>
                  //             NewPage(text: modeProvider.base64Image)));
                },
                child: Text("Base 64"))
          ],
        ),
      ),
    );
  }
}
