import 'package:email_otp/email_otp.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:simplechat/firebase/auth_credential.dart';
import 'package:simplechat/pages/screens/varifyEmail.dart';
import 'package:simplechat/pages/signup_login/login.dart';
import 'package:simplechat/widgets/showLoading.dart';
import 'package:simplechat/widgets/utils.dart';

import '../../colors/colors.dart';
import '../../provider/loading_provider.dart';

// ignore: must_be_immutable
class Signup extends StatefulWidget {
  final bool focusEmail;
  final bool isVarify;
  final String emailText;
  Signup({
    super.key,
    required this.emailText,
    required this.focusEmail,
    required this.isVarify,
  });

  @override
  State<Signup> createState() => _SignupState();
}

EmailOTP myauth = EmailOTP();

class _SignupState extends State<Signup> {
  var spinkit = const SpinKitSpinningLines(
    color: Colors.black,
    size: 20.0,
  );

  bool showNewEmail = false;
  bool show = true;
  FocusNode _focusNode = FocusNode();
  TextEditingController emailController = TextEditingController();

  TextEditingController passwordController = TextEditingController();

  TextEditingController confirmPasswordController = TextEditingController();

  @override
  void initState() {
    emailController.text = widget.emailText;

    super.initState();
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
                    height: 50.h,
                  ),
                  Text("EmoChat",
                      style: GoogleFonts.blackOpsOne(
                          textStyle: Theme.of(context).textTheme.bodyMedium,
                          decorationColor: Colors.black,
                          backgroundColor: Colors.grey.shade100,
                          color: Colors.blue,
                          fontSize: 55.sp)),
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
                            padding: EdgeInsets.only(left: 80.w, right: 20.w),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    readOnly: widget.focusEmail,
                                    focusNode: _focusNode,
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
                                    onChanged: (v) {},

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
                                Visibility(
                                    visible: provider.emailVarified,
                                    child: CircleAvatar(
                                      radius: 10.r,
                                      backgroundColor: Colors.green,
                                      child: Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 15.sp,
                                      ),
                                    ))
                              ],
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
                    visible: provider.otpVisibility,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: CupertinoButton(
                          child: Text(
                            "Signup with new Email",
                            style:
                                TextStyle(fontSize: 12.sp, color: Colors.blue),
                          ),
                          onPressed: () {
                            provider.changeEmailVarfied(value: false);
                            provider.changeOtpVisibility(value: false);
                            Navigator.pushReplacement(
                                context,
                                PageTransition(
                                    duration: const Duration(milliseconds: 700),
                                    type: PageTransitionType.fade,
                                    child: Signup(
                                      emailText: "",
                                      isVarify: false,
                                      focusEmail: false,
                                    ),
                                    isIos: true));
                          }),
                    ),
                  ),
                  Visibility(
                    visible: provider.emailVarified,
                    child: Container(
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
                                  autofocus:
                                      widget.emailText != "" ? true : false,
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
                  ),
                  Visibility(
                    visible: provider.emailVarified,
                    child: Container(
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
                      : widget.isVarify
                          ? Container(
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

                                    if (passwordController.text.toString() ==
                                        confirmPasswordController.text
                                            .toString()) {
                                      FirebaseController().signup(
                                          context: context,
                                          email: emailController.text
                                              .toLowerCase(),
                                          password: passwordController.text
                                              .toLowerCase());
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
                            )
                          : ElevatedButton(
                              style: ButtonStyle(
                                padding: MaterialStateProperty.all(
                                    EdgeInsets.symmetric(horizontal: 35.w)),
                                foregroundColor:
                                    MaterialStateProperty.all(Colors.white),
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.blue),
                              ),
                              onPressed: () {
                                if (!_formkey.currentState!.validate()) {
                                } else {
                                  try {
                                    myauth.setConfig(
                                        appEmail: "varify@emochat.com",
                                        appName: "Email OTP",
                                        userEmail: emailController.text,
                                        otpLength: 4,
                                        otpType: OTPType.digitsOnly);
                                    myauth.sendOTP();
                                    utils.showSnackbar(
                                        color: Colors.green,
                                        seconds: 2,
                                        context: context,
                                        content:
                                            "OTP has been Sent to ${emailController.text}");
                                  } catch (e) {}
                                  Navigator.push(
                                      context,
                                      PageTransition(
                                          duration:
                                              const Duration(milliseconds: 700),
                                          type: PageTransitionType.fade,
                                          child: VarifyEmailPage(
                                              email: emailController.text),
                                          isIos: true));
                                }
                              },
                              child: Text("Varify Email")),
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
