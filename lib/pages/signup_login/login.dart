import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:simplechat/firebase/auth_credential.dart';
import 'package:simplechat/pages/screens/forgetPassword.dart';
import '../../colors/colors.dart';
import '../../provider/loading_provider.dart';
import '../screens/screens.dart';

// ignore: must_be_immutable
class Login extends StatefulWidget {
  Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  var spinkit = const SpinKitCircle(
    color: Colors.blue,
    size: 20.0,
  );

  TextEditingController emailController = TextEditingController();

  TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  final _formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LoadingProvider>(context, listen: true);

    bool show = true;

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
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formkey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 60.h,
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
                        "Login to your account",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                      ),
                      SizedBox(
                        height: 25.h,
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
                                  validator: (value) {
                                    if (!RegExp(
                                            r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$")
                                        .hasMatch(value!)) {
                                      return "Enter Correct Email";
                                    } else {
                                      return null;
                                    }
                                  },
                                  // controller: ,
                                  style: kTextFieldInputStyle,
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
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [avatarShadow],
                                ),
                                child: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  radius: 40.r,
                                  child: Center(
                                      child: Icon(
                                    Icons.person_2_outlined,
                                    color: Colors.blue,
                                  )),
                                ),
                              ),
                            ),
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
                                    controller: passwordController,
                                    style: kTextFieldInputStyle,
                                    obscureText: provider.Show,
                                    decoration: InputDecoration(
                                      suffixIcon: InkWell(
                                        onTap: () {
                                          provider.ChangeShow(
                                              value: !provider.Show);
                                        },
                                        child: Icon(
                                          Icons.remove_red_eye_outlined,
                                          color: Colors.blue,
                                          size: 20.sp,
                                        ),
                                      ),
                                      hintText: 'Enter password',
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
                                  radius: 40.r,
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
                    ],
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.w),
                child: Row(
                  children: [
                    Spacer(),
                    InkWell(
                        child: Text(
                          "Forgot Password",
                          style: TextStyle(
                              fontStyle: FontStyle.italic,
                              fontSize: 11.5.sp,
                              color: Colors.blue),
                        ),
                        onTap: () {
                          Navigator.push(
                              context,
                              PageTransition(
                                  duration: const Duration(milliseconds: 700),
                                  type: PageTransitionType.fade,
                                  child: ForgetPassword(),
                                  isIos: true));
                        }),
                  ],
                ),
              ),

              // Container(
              //   margin: EdgeInsets.symmetric(horizontal: 10.w),
              //   height: 50.h,
              //   decoration: BoxDecoration(
              //       boxShadow: [
              //         AppColors.containerShadow,
              //       ],
              //       color: AppColors.foregroundColor,
              //       borderRadius: BorderRadius.only(
              //           topLeft: Radius.circular(100.r),
              //           bottomRight: Radius.circular(100.r))),
              //   child: SingleChildScrollView(
              //     child: Column(
              //       children: [
              //         Center(
              //           child: AnimatedContainer(
              //             duration: const Duration(seconds: 2),
              //             curve: Curves.fastOutSlowIn,
              //             height: 100.h,
              //             child: AnimatedTextKit(
              //                 displayFullTextOnTap: true,
              //                 repeatForever: true,
              //                 isRepeatingAnimation: true,
              //                 stopPauseOnTap: true,
              //                 animatedTexts: [
              //                   RotateAnimatedText("Login",
              //                       textStyle: TextStyle(
              //                         fontSize: 32.sp,
              //                         // fontFamily: ,
              //                         fontWeight: FontWeight.bold,
              //                         fontStyle: FontStyle.italic,
              //                         color: Colors.black,
              //                       ))
              //                 ]),
              //           ),
              //         ),
              //         Padding(
              //           padding: EdgeInsets.symmetric(horizontal: 25.h),
              //           child: Container(
              //               margin: EdgeInsets.symmetric(vertical: 12.h),
              //               decoration: const BoxDecoration(boxShadow: [
              //                 // AppColors.containerShadow,
              //               ]
              //                   // borderRadius: BorderRadius.circular(15),
              //                   ),
              //               child: TextField(
              //                 controller: emailController,
              //                 cursorColor: Colors.black,
              //                 cursorHeight: 20.sp,
              //                 // controller: ,
              //                 style: kTextFieldInputStyle,
              //                 decoration: InputDecoration(
              //                     hintText: 'someOne@something.com',
              //                     hintStyle: TextStyle(
              //                         fontSize: 12.sp,
              //                         fontStyle: FontStyle.italic),
              //                     // label: Text(
              //                     //   'Email',
              //                     //   style: TextStyle(
              //                     //       color: Colors.black, fontSize: 13.sp),
              //                     // ),
              //                     border: kTextFieldBorder,
              //                     enabledBorder: kTextFieldBorder,
              //                     focusedBorder: kTextFieldBorder),
              //               )),
              //         ),
              //         Padding(
              //           padding: EdgeInsets.symmetric(horizontal: 25.h),
              //           child: Container(
              //               margin: EdgeInsets.symmetric(vertical: 12.h),
              //               decoration: const BoxDecoration(boxShadow: [
              //                 // AppColors.containerShadow,
              //               ]
              //                   // borderRadius: BorderRadius.circular(15),
              //                   ),
              //               child: TextField(
              //                 cursorColor: Colors.black,
              //                 cursorHeight: 20.sp,
              //                 controller: passwordController,
              //                 style: kTextFieldInputStyle,
              //                 obscureText: true,
              //                 decoration: InputDecoration(
              //                     hintText: 'Enter a secure password',
              //                     hintStyle: TextStyle(
              //                         fontSize: 12.sp,
              //                         fontStyle: FontStyle.italic),
              //                     border: kTextFieldBorder,
              //                     enabledBorder: kTextFieldBorder,
              //                     focusedBorder: kTextFieldBorder),
              //               )),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
              SizedBox(
                height: 25.h,
              ),
              provider.loginLoading
                  ? spinkit
                  : Container(
                      decoration: BoxDecoration(
                        // shape: BoxShape.circle,
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
                        onPressed: () async {
                          if (!_formkey.currentState!.validate()) {
                          } else {
                            Future<bool> res = FirebaseController().login(
                                context: context,
                                email: emailController.text.toLowerCase(),
                                password:
                                    passwordController.text.toLowerCase());
                          }

                          // await Future.delayed(Duration(seconds: 4)).then(
                          //     (value) => provider.changeLoginLoading(value: false));
                        },
                        child: Text(
                          "Login",
                        ),
                      ),
                    ),
              // SizedBox(
              //   height: 15.h,
              // ),
              // Padding(
              //   padding: EdgeInsets.symmetric(horizontal: 80.w),
              //   child: Row(children: [
              //     Expanded(
              //         child: Container(
              //       height: 0.5,
              //       color: Colors.grey,
              //     )),
              //     Text(
              //       "\t\tOR\t\t",
              //       style: TextStyle(fontSize: 20),
              //     ),
              //     Expanded(
              //         child: Container(
              //       height: 0.5,
              //       color: Colors.grey,
              //     )),
              //   ]),
              // )
            ],
          ),
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

BoxShadow avatarShadow = BoxShadow(
  color: Colors.blue,
  blurRadius: 3,
  offset: Offset(-1, 4),
  spreadRadius: 0.00,
);

BoxShadow shadow = BoxShadow(
  color: Colors.blue.shade300,
  blurRadius: 5,
  offset: Offset(1, 4),
  spreadRadius: 0.00,
);
