import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:simplechat/widgets/utils.dart';

class ForgetPassword extends StatefulWidget {
  ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  final TextEditingController email = TextEditingController();

  final _formkey = GlobalKey<FormState>();
  Future<void> resetPassword() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: email.text)
          .then((value) => utils.showSnackbar(
              context: context,
              color: Colors.green,
              content: "An Email has been sent to your Email",
              seconds: 2));
      // Show a success message or navigate to a success screen
      print('Password reset email sent');
    } catch (error) {
      // Show an error message
      print('Error sending password reset email: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(120),
          child: AppBar(
            backgroundColor: Colors.white,

            leading: InkWell(
              onTap: () {
                Navigator.of(context, rootNavigator: false).pop();
              },
              child: Icon(
                Icons.arrow_back_ios,
                color: Colors.black.withOpacity(0.7),
              ),
            ),
            //  Image.asset("assets/iconImages/back.png"),
          ),
        ),
        body: Form(
          key: _formkey,
          child: SingleChildScrollView(
            child: Column(
                // mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text("EmoChat",
                      style: GoogleFonts.blackOpsOne(
                          textStyle: Theme.of(context).textTheme.bodyMedium,
                          decorationColor: Colors.black,
                          backgroundColor: Colors.grey.shade100,
                          color: Colors.blue,
                          fontSize: 55.sp)),
                  SizedBox(
                    height: _size.height * 0.0216541,
                  ),
                  SizedBox(
                    height: _size.height * 0.02016541,
                  ),
                  Text(
                    'Forgot your password?',
                    style: GoogleFonts.slabo13px(
                      color: Colors.black,
                      backgroundColor: Colors.grey.shade100,
                      fontWeight: FontWeight.bold,
                      textStyle: Theme.of(context).textTheme.bodySmall,
                      fontSize: 17.sp,
                    ),
                  ),
                  SizedBox(
                    height: _size.height * 0.04,
                  ),
                  Text(
                    'Enter Your registerd email below to receive \n password reset instruction',
                    style: GoogleFonts.slabo13px(
                      color: Colors.black,
                      backgroundColor: Colors.grey.shade100,
                      textStyle: Theme.of(context).textTheme.bodySmall,
                      fontSize: 13.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                    child: SizedBox(
                      height: 50.h,
                      child: TextFormField(
                        style: TextStyle(fontSize: 13.sp, color: Colors.black),
                        controller: email,
                        validator: (value) {
                          if (!RegExp(
                                  r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$")
                              .hasMatch(value!)) {
                            return "Enter Correct Email";
                          } else {
                            return null;
                          }
                        },
                        decoration: InputDecoration(
                          hintText: "Email",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                      child: ElevatedButton(
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
                              resetPassword();
                            }
                          },
                          child: Text("Send Email"))),
                ]),
          ),
        ));
  }
}
