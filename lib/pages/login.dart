import 'dart:developer';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:simplechat/firebase/auth_credential.dart';
import '../colors/colors.dart';
import '../provider/loading_provider.dart';
import 'screens.dart';

// ignore: must_be_immutable
class Login extends StatelessWidget {
  Login({super.key});

  var spinkit = const SpinKitSpinningLines(
    color: Colors.black,
    size: 50.0,
  );

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LoadingProvider>(context, listen: true);

    return Scaffold(
      backgroundColor: AppColors.backgroudColor,
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Don't have an Account?",
            style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
          ),
          CupertinoButton(
            onPressed: () {
              Navigator.push(
                  context,
                  PageTransition(
                      duration: const Duration(milliseconds: 700),
                      type: PageTransitionType.fade,
                      child: Signup(),
                      isIos: true));
            },
            child: const Text(
              "Signup here",
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: AnimatedContainer(
                duration: const Duration(seconds: 2),
                curve: Curves.fastOutSlowIn,
                height: 200.h,
                child: AnimatedTextKit(
                    displayFullTextOnTap: true,
                    repeatForever: true,
                    isRepeatingAnimation: true,
                    stopPauseOnTap: true,
                    animatedTexts: [
                      RotateAnimatedText("Login",
                          textStyle: TextStyle(
                            fontSize: 32.sp,
                            // fontFamily: ,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            color: Colors.black,
                          ))
                    ]),
              ),
            ),
            Container(
              height: 250.h,
              decoration: BoxDecoration(
                  boxShadow: [
                    AppColors.containerShadow,
                  ],
                  color: AppColors.foregroundColor,
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
                        decoration: const BoxDecoration(boxShadow: [
                          // AppColors.containerShadow,
                        ]
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
                        decoration: const BoxDecoration(boxShadow: [
                          // AppColors.containerShadow,
                        ]
                            // borderRadius: BorderRadius.circular(15),
                            ),
                        child: TextField(
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
                ],
              ),
            ),
            SizedBox(
              height: 25.h,
            ),
            provider.loginLoading
                ? spinkit
                : GestureDetector(
                    onTap: () async {
                      Future<bool> res = FirebaseController().login(
                          context: context,
                          email: emailController.text.toLowerCase(),
                          password: passwordController.text.toLowerCase());

                      log("$res");
                    },
                    child: Container(
                      height: 70,
                      width: 100,
                      decoration: BoxDecoration(
                          boxShadow: [AppColors.containerShadow],
                          color: AppColors.foregroundColor,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(50.r),
                              bottomRight: Radius.circular(50.r))),
                      child: Center(
                          child: Text(
                        "Login",
                        style: kButtonTextStyle,
                      )),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

final kTextFieldBorder = OutlineInputBorder(
    borderRadius: BorderRadius.only(
        topLeft: Radius.circular(30.r), bottomRight: Radius.circular(30.r)),
    borderSide: const BorderSide(
      color: Colors.black,
    ));

final kButtonTextStyle = TextStyle(
    fontSize: 15.sp,
    // fontFamily: '',
    fontWeight: FontWeight.bold,
    color: Colors.black);

final kTextFieldInputStyle = TextStyle(
  fontSize: 13.sp, color: Colors.black,
  // fontFamily: ''
);
