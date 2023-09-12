import 'package:email_otp/email_otp.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:simplechat/pages/screens/screens.dart';
import 'package:simplechat/widgets/utils.dart';

import '../../provider/loading_provider.dart';

class VarifyEmailPage extends StatefulWidget {
  VarifyEmailPage({super.key, required this.email});
  final String email;

  @override
  State<VarifyEmailPage> createState() => _VarifyEmailPageState();
}

class _VarifyEmailPageState extends State<VarifyEmailPage> {
  final TextEditingController one = TextEditingController();

  final TextEditingController two = TextEditingController();

  final TextEditingController three = TextEditingController();

  final TextEditingController four = TextEditingController();

  final oneFocus = FocusNode();

  final twoFocus = FocusNode();

  final threeFocus = FocusNode();

  final fourFocus = FocusNode();
  final email = FocusNode();

  @override
  void dispose() {
    oneFocus.dispose();
    twoFocus.dispose();
    threeFocus.dispose();
    fourFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LoadingProvider>(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(
              Icons.arrow_back_ios,
              size: 20,
            )),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Center(
              child: SizedBox(
                height: 60,
                child: Image.asset(
                  "assets/logo.png",
                  // color: Colors.grey.shade600,
                ),
              ),
            ),
            // Center(
            //   child: SizedBox(
            //     height: 60,
            //     child: Image.asset(
            //       "assets/iconImages/numPad.png",
            //       color: Colors.grey.shade600,
            //     ),
            //   ),
            // ),
            SizedBox(
              height: 35.h,
            ),
            Center(
              child: Text("ENTER VARIFICATION OTP",
                  style: GoogleFonts.lato(
                    textStyle: Theme.of(context).textTheme.bodyMedium,
                    fontSize: 25.sp,
                    color: Colors.blue,
                    letterSpacing: -1,
                    wordSpacing: 5,
                    fontWeight: FontWeight.w600,
                  )),
            ),
            SizedBox(
              height: 20.h,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 45.w),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      // maxLength: 1,
                      autofocus: true,
                      textAlign: TextAlign.center,
                      focusNode: oneFocus,
                      controller: one,
                      onChanged: (v) {
                        setState(() {
                          twoFocus.requestFocus();
                        });
                      },
                      decoration:
                          InputDecoration(border: UnderlineInputBorder()),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: TextFormField(
                      // maxLength: 1,
                      focusNode: twoFocus,
                      textAlign: TextAlign.center,
                      controller: two,
                      onChanged: (v) {
                        threeFocus.requestFocus();
                      },
                      decoration:
                          InputDecoration(border: UnderlineInputBorder()),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: TextFormField(
                      // maxLength: 1,
                      textAlign: TextAlign.center,
                      controller: three,
                      focusNode: threeFocus,
                      onChanged: (v) {
                        fourFocus.requestFocus();
                      },
                      decoration:
                          InputDecoration(border: UnderlineInputBorder()),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: TextField(
                      // maxLength: 1,
                      textAlign: TextAlign.center,
                      controller: four,
                      focusNode: fourFocus,
                      onChanged: (v) {
                        fourFocus.unfocus();
                      },
                      decoration:
                          InputDecoration(border: UnderlineInputBorder()),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10.h,
            ),
            CupertinoButton(
                child: Text(
                  "Can't find the PIN?",
                  style: TextStyle(fontSize: 14.sp),
                ),
                onPressed: () {
                  myauth.setConfig(
                      appEmail: "varify@emochat.com",
                      appName: "Email OTP",
                      userEmail: widget.email,
                      otpLength: 4,
                      otpType: OTPType.digitsOnly);

                  try {
                    myauth.sendOTP();
                    utils.showSnackbar(
                        color: Colors.green,
                        seconds: 2,
                        context: context,
                        content: "OTP has been Sent to ${widget.email}");
                  } catch (e) {}
                }),
            SizedBox(
              height: 10.h,
            ),
            Center(
              child: ElevatedButton.icon(
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all(
                        EdgeInsets.symmetric(horizontal: 35.w)),
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                    backgroundColor: MaterialStateProperty.all(Colors.blue),
                  ),
                  onPressed: () {
                    if (myauth.verifyOTP(
                        otp: one.text + two.text + three.text + four.text)) {
                      provider.changeEmailVarfied(value: true);
                      utils.showSnackbar(
                          color: Colors.green,
                          seconds: 1,
                          context: context,
                          content: "OTP Confirmed");
                      Navigator.push(
                          context,
                          PageTransition(
                              duration: const Duration(milliseconds: 700),
                              type: PageTransitionType.fade,
                              child: Signup(
                                isVarify: true,
                                focusEmail: true,
                                emailText: widget.email,
                              ),
                              isIos: true));
                    }
                  },
                  icon: Icon(Icons.done_all, color: Colors.grey.shade200),
                  label: Text(
                    "Confirm",
                    style: TextStyle(fontSize: 15.sp),
                  )),
            )
          ],
        ),
      ),
    );
  }
}
