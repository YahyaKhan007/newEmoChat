import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:simplechat/firebase/auth_credential.dart';
import 'package:simplechat/widgets/showLoading.dart';

import '../colors/colors.dart';
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
    final provider = Provider.of<LoadingProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.backgroudColor,
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Already have an Account?",
            style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
          ),
          CupertinoButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              "Login here",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
      body: Center(
          child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 200.h, child: Image.asset("assets/logo.png")),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 10.w),
              height: 320.h,
              decoration: BoxDecoration(
                  boxShadow: [AppColors.containerShadow],
                  color: AppColors.foregroundColor,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(100.r),
                      bottomRight: Radius.circular(100.r))),
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(seconds: 2),
                    curve: Curves.fastOutSlowIn,
                    height: 70.h,
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
                                color: Colors.black,
                              ))
                        ]),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25.h),
                    child: Container(
                        margin: EdgeInsets.symmetric(vertical: 12.h),
                        decoration: const BoxDecoration(
                            // boxShadow: [AppColors.containerShadow],
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
                            // boxShadow: [AppColors.containerShadow],
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
                            // boxShadow: [AppColors.containerShadow],
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
              height: 25.h,
            ),
            provider.signUpLoading
                ? SpinKitSpinningLines(
                    color: Colors.black,
                    size: 30.0,
                  )
                : CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      // signup(context: context);
                      // provider.changeSigupLoading(value: true);

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
                        height: 50.h,
                        width: 70.w,
                        padding:
                            EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                        decoration: BoxDecoration(
                            boxShadow: [AppColors.containerShadow],
                            color: AppColors.foregroundColor,
                            gradient: LinearGradient(
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                              colors: [
                                Color(0xff06beb6),
                                Color.fromARGB(255, 69, 123, 130)
                              ],
                            ),
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30.r),
                                bottomRight: Radius.circular(30.r))),
                        child: Image.asset(
                          "assets/iconImages/signup.png",
                          color: Colors.white,
                          fit: BoxFit.fill,
                        )),
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
