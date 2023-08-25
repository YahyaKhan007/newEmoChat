import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:simplechat/widgets/glass_morphism.dart';

class ForgetPassword extends StatefulWidget {
  ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  final TextEditingController email = TextEditingController();

  final _formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.blue.shade100,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(120),
          child: AppBar(
            backgroundColor: Colors.blue.shade100,

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
        body: Container(
          // padding: EdgeInsets.only(bottom: _size.height * 0.3),
          height: _size.height,
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
          ),

          child: Form(
            key: _formkey,
            child: LayoutBuilder(
              builder: (context, constraints) => Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Spacer(),
                    Image.asset("assets/logo.png"),
                    Spacer(),
                    Spacer(),
                    Spacer(),
                    Spacer(),
                    GlassMorphism(
                        width: _size.width,
                        height: _size.height * 0.4,
                        blur: 0.3,
                        borderRadius: 20.0,
                        child: Container(
                            child: SingleChildScrollView(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: _size.height * 0.02816541,
                                ),
                                Image.asset("assets/iconImages/Indicator.png"),
                                SizedBox(
                                  height: _size.height * 0.02816541,
                                ),
                                Text(
                                  'Forgot your password?',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'Poppins-Medium',
                                    fontSize: 15.sp,
                                  ),
                                ),
                                SizedBox(
                                  height: _size.height * 0.04,
                                ),
                                Text(
                                  'Enter Your registerd email below to receive \n password reset instruction',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'Poppins-Medium',
                                    fontSize: 13.sp,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                _emailTextfield(context),
                                _loginButton(context),
                              ]),
                        ))),
                  ]),
            ),
          ),
        ));
  }

  Widget _emailTextfield(context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
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
    );
  }

  Widget _loginButton(context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 8),
      child: InkWell(
        onTap: () {
          if (!_formkey.currentState!.validate()) {
          } else {}
        },
        child: Container(
          decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(20)),
          height: 40.h,
          child: Center(
            child: Text(
              "Send Email",
              style: TextStyle(fontSize: 14.sp, color: Colors.black),
            ),
          ),
        ),
      ),
    );
  }
}
