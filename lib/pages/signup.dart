import 'dart:developer';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:simplechat/firebase/auth_credential.dart';
import 'package:simplechat/widgets/showLoading.dart';

import '../provider/loading_provider.dart';
import 'screens.dart';

// ignore: must_be_immutable
class Signup extends StatelessWidget {
  Signup({super.key});
  var spinkit = const SpinKitSpinningLines(
    color: Colors.black,
    size: 50.0,
  );

  bool show = true;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  void signup({required BuildContext context}) {
    FirebaseController authController = FirebaseController();
    authController.signup(
        context: context,
        email: emailController.text.toLowerCase().toString(),
        password: passwordController.text.toLowerCase().toString());
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LoadingProvider>(context, listen: true);

    return Scaffold(
      backgroundColor: Colors.deepPurpleAccent.shade200,
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Already have an Account?",
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
          CupertinoButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              "Login here",
              style: TextStyle(color: Colors.amber.shade200),
            ),
          ),
        ],
      ),
      body: Center(
          child: SingleChildScrollView(
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(seconds: 2),
              curve: Curves.fastOutSlowIn,
              height: 200.h,
              child: AnimatedTextKit(
                  displayFullTextOnTap: true,
                  repeatForever: true,
                  isRepeatingAnimation: true,
                  stopPauseOnTap: true,
                  animatedTexts: [
                    RotateAnimatedText("Signup",
                        textStyle: TextStyle(
                          fontSize: 32.sp,
                          // fontFamily: ,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          color: Colors.amber,
                        ))
                  ]),
            ),
            Container(
              height: 300.h,
              decoration: BoxDecoration(
                  color: Colors.amber.shade200.withOpacity(0.8),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(100.r),
                      bottomRight: Radius.circular(100.r))),
              child: Column(
                children: [
                  SizedBox(
                    height: 50.h,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25.h),
                    child: Container(
                        margin: EdgeInsets.symmetric(vertical: 12.h),
                        decoration: const BoxDecoration(
                            // borderRadius: BorderRadius.circular(15),
                            ),
                        child: TextField(
                          controller: emailController,
                          cursorColor: Colors.black,
                          cursorHeight: 20.sp,
                          // controller: ,
                          style: kTextFieldInputStyle,
                          decoration: InputDecoration(
                              hintText: 'someOne@something.com',
                              hintStyle: TextStyle(
                                  fontSize: 12.sp, fontStyle: FontStyle.italic),
                              // label: Text(
                              //   'Email',
                              //   style: TextStyle(
                              //       color: Colors.black, fontSize: 13.sp),
                              // ),
                              border: kTextFieldBorder,
                              enabledBorder: kTextFieldBorder,
                              focusedBorder: kTextFieldBorder),
                        )),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25.h),
                    child: Container(
                        margin: EdgeInsets.symmetric(vertical: 12.h),
                        decoration: const BoxDecoration(
                            // borderRadius: BorderRadius.circular(15),
                            ),
                        child: TextFormField(
                          cursorColor: Colors.black,
                          cursorHeight: 20.sp,
                          controller: passwordController,
                          style: kTextFieldInputStyle,
                          obscureText: true,
                          decoration: InputDecoration(
                              hintText: 'Enter a secure password',
                              hintStyle: TextStyle(
                                  fontSize: 12.sp, fontStyle: FontStyle.italic),
                              border: kTextFieldBorder,
                              enabledBorder: kTextFieldBorder,
                              focusedBorder: kTextFieldBorder),
                        )),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25.h),
                    child: Container(
                        margin: EdgeInsets.symmetric(vertical: 12.h),
                        decoration: const BoxDecoration(
                            // borderRadius: BorderRadius.circular(15),
                            ),
                        child: TextField(
                          cursorColor: Colors.black,
                          cursorHeight: 20.sp,
                          controller: confirmPasswordController,
                          style: kTextFieldInputStyle,
                          obscureText: true,
                          decoration: InputDecoration(
                              hintText: 'Enter password again',
                              hintStyle: TextStyle(
                                  fontSize: 12.sp, fontStyle: FontStyle.italic),
                              border: kTextFieldBorder,
                              enabledBorder: kTextFieldBorder,
                              focusedBorder: kTextFieldBorder),
                        )),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 35.h,
            ),
            provider.loginLoading
                ? spinkit
                : GestureDetector(
                    onTap: () {
                      log("check");
                      // signup(context: context);
                      if (passwordController.text.toString() ==
                          confirmPasswordController.text.toString()) {
                        FirebaseController().signup(
                            context: context,
                            email: emailController.text.toLowerCase(),
                            password: passwordController.text.toLowerCase());
                      } else {
                        Loading.showAlertDialog(
                            context,
                            "Password miss matched",
                            "Both the passwords do not match");
                      }

                      // Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (builder) => const CompleteProfile()));
                    },
                    child: Container(
                      height: 70,
                      width: 100,
                      decoration: BoxDecoration(
                          color: Colors.amber.shade200.withOpacity(0.8),
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(50.r),
                              bottomRight: Radius.circular(50.r))),
                      child: Center(
                          child: Text(
                        "Signup",
                        style: kButtonTextStyle,
                      )),
                    ),
                  ),
            SizedBox(
              height: 30.h,
            )
          ],
        ),
      )),
    );
  }
}
