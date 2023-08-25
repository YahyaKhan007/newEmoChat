import 'package:email_auth/email_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:simplechat/firebase/auth_credential.dart';
import 'package:simplechat/pages/signup_login/login.dart';
import 'package:simplechat/widgets/showLoading.dart';

import '../../colors/colors.dart';
import '../../provider/loading_provider.dart';

// ignore: must_be_immutable
class Signup extends StatefulWidget {
  Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  var spinkit = const SpinKitSpinningLines(
    color: Colors.black,
    size: 20.0,
  );

  bool show = true;

  TextEditingController emailController = TextEditingController();

  TextEditingController passwordController = TextEditingController();

  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController _otpController = TextEditingController();

  // late EmailAuth emailAuth;

  // @override
  // void initState() {
  //   super.initState();
  //   emailAuth = new EmailAuth(
  //     sessionName: "Sample session",
  //   );

  //   /// Configuring the remote server
  //   emailAuth.config(remoteServerConfiguration);
  // }

  void verifyOTP() {
    EmailAuth emailAuth = new EmailAuth(sessionName: "OTP FOR SIGNUP");
    var res = emailAuth.validateOtp(
        recipientMail: emailController.value.text,
        userOtp: _otpController.value.text);
    if (res) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: Duration(seconds: 2),
        content: Text(
          "OTP has been sent to ${emailController.text}",
          style: TextStyle(fontSize: 14.sp, color: Colors.black),
        ),
        backgroundColor: Colors.green.shade300,
      ));
    } else {
      print("Invalid Verification Code");
    }
  }

// ! SEND OTP
  void sendOTP() async {
    EmailAuth emailAuth = new EmailAuth(sessionName: "Test Session");
    var res = await emailAuth.sendOtp(
        recipientMail: emailController.value.text, otpLength: 6);
    if (res) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: Duration(seconds: 2),
        content: Text(
          "OTP has been sent to ${emailController.text}",
          style: TextStyle(fontSize: 14.sp, color: Colors.black),
        ),
        backgroundColor: Colors.green.shade300,
      ));
    } else {
      print("Failed to send the verification code");
    }
  }
  // void sendOtp() async {
  //   // EmailAuth(sessionName: "OTP For Signup Profile of EMoChat");

  //   bool result =
  //       await EmailAuth(sessionName: "OTP For Signup Profile of EmoChat")
  //           .sendOtp(recipientMail: emailController.text, otpLength: 5);
  //   if (result) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         duration: Duration(seconds: 2),
  //         content: Text(
  //           "OTP has been sent to ${emailController.text}",
  //           style: TextStyle(fontSize: 14.sp, color: Colors.black),
  //         ),
  //         backgroundColor: Colors.green.shade300,
  //       ),
  //     );
  //   } else {
  //     print("Issue while sending OTP");
  //   }
  // }

  // ! Validate OTP
  bool validateOTP() {
    var result = EmailAuth(sessionName: "OTP For Signup Profile of EmoChat")
        .validateOtp(
            recipientMail: emailController.text, userOtp: _otpController.text);
    if (result) {
      return true;
    } else {
      return false;
    }
  }

  void signup({required BuildContext context}) {
    FirebaseController authController = FirebaseController();
    authController.signup(
        context: context,
        email: emailController.text.toLowerCase().toString(),
        password: passwordController.text.toLowerCase().toString());
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  final _formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LoadingProvider>(context);

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
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
              style: TextStyle(
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
            child: SingleChildScrollView(
          child: AnimatedContainer(
            duration: Duration(seconds: 2),
            child: Form(
              key: _formkey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 20.h,
                  ),
                  SizedBox(
                      // height: 130.h,
                      width: MediaQuery.of(context).size.width,
                      child: Image.asset("assets/logo.png")),
                  Text(
                    "Welcome Back!",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  Text(
                    "Create your account",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  Container(
                    height: 90.h,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 300.w,
                          height: 50.h,
                          decoration: BoxDecoration(
                            boxShadow: [shadow],
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(left: 100),
                            child: TextFormField(
                              controller: emailController,
                              cursorColor: Colors.black,
                              cursorHeight: 17.sp,
                              // controller: ,
                              style: kTextFieldInputStyle,
                              validator: (value) {
                                if (!RegExp(
                                        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$")
                                    .hasMatch(value!)) {
                                  return "Enter Correct Email";
                                } else {
                                  return null;
                                }
                              },
                              onChanged: (v) {
                                if (emailController.text.isEmpty) {
                                  provider.changShowOtpButton(value: false);
                                } else {
                                  provider.changShowOtpButton(value: true);
                                }
                              },

                              decoration: InputDecoration(
                                hintText: 'someOne@something.com',

                                hintStyle: TextStyle(
                                    fontSize: 12.sp,
                                    fontStyle: FontStyle.italic),
                                // label: Text(
                                //   'Email',
                                //   style: TextStyle(
                                //       color: Colors.black, fontSize: 13.sp),
                                // ),
                                border: InputBorder.none,
                                // enabledBorder: kTextFieldBorder,
                                // focusedBorder: kTextFieldBorder
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 0.w,
                          child: AnimatedContainer(
                            duration: Duration(microseconds: 500),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [avatarShadow],
                              ),
                              child: CircleAvatar(
                                backgroundColor: Colors.white,
                                radius: 35,
                                child: Center(
                                    child: Icon(
                                  Icons.person_2_outlined,
                                  color: Colors.blue,
                                  size: provider.signupText ? 20 : 25,
                                )),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Visibility(
                    visible: provider.showOtpButton,
                    child: Padding(
                      padding: EdgeInsets.only(right: 30.w),
                      child: Align(
                          alignment: Alignment.centerRight,
                          child: InkWell(
                            onTap: () {
                              provider.changeOtpVisibility(value: true);
                              provider.changShowOtpButton(value: false);
                              sendOTP();
                            },
                            child: Text(
                              "Send OTP",
                              style: TextStyle(
                                  fontSize: 13.sp,
                                  color: Colors.green,
                                  fontStyle: FontStyle.italic),
                            ),
                          )),
                    ),
                  ),
                  Visibility(
                    visible: provider.otpVisibility,
                    child: Container(
                      height: 90.h,
                      padding: EdgeInsets.symmetric(horizontal: 50),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 300.w,
                            height: 50.h,
                            decoration: BoxDecoration(
                              boxShadow: [shadow],
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Padding(
                              padding: EdgeInsets.only(left: 70),
                              child: TextFormField(
                                controller: _otpController,
                                cursorColor: Colors.black,
                                cursorHeight: 17.sp,
                                // controller: ,
                                style: kTextFieldInputStyle,
                                onChanged: (value) {
                                  if (true) {}
                                },

                                decoration: InputDecoration(
                                  suffix: Visibility(
                                      visible: true,
                                      child: CircleAvatar(
                                        radius: 15,
                                        backgroundColor: Colors.green,
                                        child: Icon(
                                          Icons.check,
                                          color: Colors.white,
                                        ),
                                      )),

                                  hintText: 'Enter OTP',
                                  hintStyle: TextStyle(
                                      fontSize: 13.sp,
                                      fontStyle: FontStyle.italic),
                                  // label: Text(
                                  //   'Email',
                                  //   style: TextStyle(
                                  //       color: Colors.black, fontSize: 13.sp),
                                  // ),
                                  border: InputBorder.none,
                                  // enabledBorder: kTextFieldBorder,
                                  // focusedBorder: kTextFieldBorder
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 0.w,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [avatarShadow],
                              ),
                              child: CircleAvatar(
                                backgroundColor: Colors.white,
                                radius: 25,
                                child: Center(
                                    child: Text(
                                  "OTP",
                                  style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.blue,
                                      fontStyle: FontStyle.italic),
                                )),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: 90.h,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 300.w,
                          height: 50.h,
                          decoration: BoxDecoration(
                            boxShadow: [shadow],
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Padding(
                              padding: EdgeInsets.only(left: 100),
                              child: TextField(
                                cursorColor: Colors.black,
                                cursorHeight: 20.sp,
                                controller: passwordController,
                                style: kTextFieldInputStyle,
                                obscureText: provider.show,
                                decoration: InputDecoration(
                                  suffixIcon: InkWell(
                                    onTap: () {
                                      provider.changeShow(
                                          value: !provider.show);
                                      print(provider.show);
                                    },
                                    child: Icon(
                                      Icons.remove_red_eye_outlined,
                                      color: Colors.blue,
                                      size: 20.sp,
                                    ),
                                  ),
                                  hintText: 'Enter a secure password',
                                  hintStyle: TextStyle(
                                      fontSize: 12.sp,
                                      fontStyle: FontStyle.italic),
                                  border: InputBorder.none,
                                  // enabledBorder: kTextFieldBorder,
                                  // focusedBorder: kTextFieldBorder,
                                ),
                              )),
                        ),
                        Positioned(
                          left: 0.w,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [avatarShadow],
                            ),
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 35.r,
                              child: Center(
                                  child: Icon(
                                Icons.lock_open,
                                color: Colors.blue,
                              )),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    height: 90.h,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 300.w,
                          height: 50.h,
                          decoration: BoxDecoration(
                            boxShadow: [shadow],
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Padding(
                              padding: EdgeInsets.only(left: 100),
                              child: TextField(
                                cursorColor: Colors.black,
                                cursorHeight: 20.sp,
                                controller: confirmPasswordController,
                                style: kTextFieldInputStyle,
                                obscureText: provider.show,
                                decoration: InputDecoration(
                                  suffixIcon: InkWell(
                                    onTap: () {
                                      provider.changeShow(
                                          value: !provider.show);
                                    },
                                    child: Icon(
                                      Icons.remove_red_eye_outlined,
                                      color: Colors.blue,
                                      size: 20.sp,
                                    ),
                                  ),
                                  hintText: 'Confirm password',
                                  hintStyle: TextStyle(
                                      fontSize: 12.sp,
                                      fontStyle: FontStyle.italic),
                                  border: InputBorder.none,
                                  // enabledBorder: kTextFieldBorder,
                                  // focusedBorder: kTextFieldBorder,
                                ),
                              )),
                        ),
                        Positioned(
                          left: 0.w,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [avatarShadow],
                            ),
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 35.r,
                              child: Center(
                                  child: Icon(
                                Icons.lock_open,
                                color: Colors.blue,
                              )),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  // Container(
                  //   margin: EdgeInsets.symmetric(horizontal: 10.w),
                  //   height: 320.h,
                  //   decoration: BoxDecoration(
                  //       boxShadow: [AppColors.containerShadow],
                  //       color: AppColors.foregroundColor,
                  //       borderRadius: BorderRadius.only(
                  //           topLeft: Radius.circular(100.r),
                  //           bottomRight: Radius.circular(100.r))),
                  //   child: Column(
                  //     children: [
                  //       AnimatedContainer(
                  //         duration: const Duration(seconds: 2),
                  //         curve: Curves.fastOutSlowIn,
                  //         height: 70.h,
                  //         child: AnimatedTextKit(
                  //             displayFullTextOnTap: true,
                  //             repeatForever: true,
                  //             isRepeatingAnimation: true,
                  //             stopPauseOnTap: true,
                  //             animatedTexts: [
                  //               RotateAnimatedText("Signup",
                  //                   textStyle: TextStyle(
                  //                     fontSize: 32.sp,
                  //                     // fontFamily: ,
                  //                     fontWeight: FontWeight.bold,
                  //                     fontStyle: FontStyle.italic,
                  //                     color: Colors.black,
                  //                   ))
                  //             ]),
                  //       ),
                  //       Padding(
                  //         padding: EdgeInsets.symmetric(horizontal: 25.h),
                  //         child: Container(
                  //             margin: EdgeInsets.symmetric(vertical: 12.h),
                  //             decoration: const BoxDecoration(
                  //                 // boxShadow: [AppColors.containerShadow],
                  //                 // borderRadius: BorderRadius.circular(15),
                  //                 ),
                  //             child: TextField(
                  //               controller: emailController,
                  //               cursorColor: Colors.black,
                  //               cursorHeight: 20.sp,
                  //               // controller: ,
                  //               style: kTextFieldInputStyle,
                  //               decoration: InputDecoration(
                  //                   hintText: 'someOne@something.com',
                  //                   hintStyle: TextStyle(
                  //                       fontSize: 12.sp, fontStyle: FontStyle.italic),
                  //                   // label: Text(
                  //                   //   'Email',
                  //                   //   style: TextStyle(
                  //                   //       color: Colors.black, fontSize: 13.sp),
                  //                   // ),
                  //                   border: kTextFieldBorder,
                  //                   enabledBorder: kTextFieldBorder,
                  //                   focusedBorder: kTextFieldBorder),
                  //             )),
                  //       ),
                  //       Padding(
                  //         padding: EdgeInsets.symmetric(horizontal: 25.h),
                  //         child: Container(
                  //             margin: EdgeInsets.symmetric(vertical: 12.h),
                  //             decoration: const BoxDecoration(
                  //                 // boxShadow: [AppColors.containerShadow],
                  //                 // borderRadius: BorderRadius.circular(15),
                  //                 ),
                  //             child: TextFormField(
                  //               cursorColor: Colors.black,
                  //               cursorHeight: 20.sp,
                  //               controller: passwordController,
                  //               style: kTextFieldInputStyle,
                  //               obscureText: true,
                  //               decoration: InputDecoration(
                  //                   hintText: 'Enter a secure password',
                  //                   hintStyle: TextStyle(
                  //                       fontSize: 12.sp, fontStyle: FontStyle.italic),
                  //                   border: kTextFieldBorder,
                  //                   enabledBorder: kTextFieldBorder,
                  //                   focusedBorder: kTextFieldBorder),
                  //             )),
                  //       ),
                  //       Padding(
                  //         padding: EdgeInsets.symmetric(horizontal: 25.h),
                  //         child: Container(
                  //             margin: EdgeInsets.symmetric(vertical: 12.h),
                  //             decoration: const BoxDecoration(
                  //                 // boxShadow: [AppColors.containerShadow],
                  //                 // borderRadius: BorderRadius.circular(15),
                  //                 ),
                  //             child: TextField(
                  //               cursorColor: Colors.black,
                  //               cursorHeight: 20.sp,
                  //               controller: confirmPasswordController,
                  //               style: kTextFieldInputStyle,
                  //               obscureText: true,
                  //               decoration: InputDecoration(
                  //                   hintText: 'Enter password again',
                  //                   hintStyle: TextStyle(
                  //                       fontSize: 12.sp, fontStyle: FontStyle.italic),
                  //                   border: kTextFieldBorder,
                  //                   enabledBorder: kTextFieldBorder,
                  //                   focusedBorder: kTextFieldBorder),
                  //             )),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  SizedBox(
                    height: 25.h,
                  ),
                  provider.signUpLoading
                      ? SpinKitSpinningLines(
                          color: Colors.blue,
                          size: 20.0,
                        )
                      : Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [shadow],
                          ),
                          child: ElevatedButton(
                            style: ButtonStyle(
                              padding: MaterialStateProperty.all(
                                  EdgeInsets.symmetric(horizontal: 35.w)),
                              foregroundColor:
                                  MaterialStateProperty.all(Colors.white),
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.blue),
                            ),
                            child: Text(
                              "Sign up",
                              style: TextStyle(fontSize: 15.sp),
                            ),
                            onPressed: () {
                              // signup(context: context);
                              // provider.changeSigupLoading(value: true);
                              if (!_formkey.currentState!.validate()) {
                              } else {
                                // return "Enter";
                                if (validateOTP()) {
                                  if (passwordController.text.toString() ==
                                      confirmPasswordController.text
                                          .toString()) {
                                    FirebaseController().signup(
                                        context: context,
                                        email:
                                            emailController.text.toLowerCase(),
                                        password: passwordController.text
                                            .toLowerCase());
                                  }
                                } else {
                                  Loading.showAlertDialog(
                                      context,
                                      "Password miss matched",
                                      "Both the passwords do not match");
                                }
                              }

                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (builder) => const CompleteProfile()));
                            },
                          ),
                        ),
                  SizedBox(
                    height: 30.h,
                  )
                ],
              ),
            ),
          ),
        )),
      ),
    );
  }
}
