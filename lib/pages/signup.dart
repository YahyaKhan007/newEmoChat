import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:simplechat/firebase/auth_credential.dart';

import '../provider/loading_provider.dart';
import 'screens.dart';

class Signup extends StatelessWidget {
  Signup({super.key});
  var spinkit = const SpinKitSpinningLines(
    color: Colors.black,
    size: 50.0,
  );

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

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
      bottomNavigationBar: CupertinoButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: Text(
          "Already have an Account?     Login here",
          style: TextStyle(color: Theme.of(context).primaryColor),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 35),
        child: Center(
            child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                "Signup",
                style: TextStyle(
                    fontSize: 35,
                    color: Theme.of(context).colorScheme.background,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: emailController,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade800),
                decoration: const InputDecoration(
                    labelText: "Email", labelStyle: TextStyle(fontSize: 16)),
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: passwordController,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade800),
                decoration: const InputDecoration(
                    labelText: "Password", labelStyle: TextStyle(fontSize: 16)),
              ),
              const SizedBox(
                height: 20,
              ),
              GestureDetector(
                onTap: () {
                  // signup(context: context);
                  FirebaseController().signup(
                      context: context,
                      email: emailController.text.toLowerCase(),
                      password: passwordController.text.toLowerCase());
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (builder) => const CompleteProfile()));
                },
                child: provider.signUpLoading
                    ? spinkit
                    : Container(
                        height: 60,
                        width: 120,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Theme.of(context).colorScheme.background),
                        child: Center(
                            child: Text(
                          "Signup",
                          style: TextStyle(
                              color: Theme.of(context).canvasColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w700),
                        )),
                      ),
              )
            ],
          ),
        )),
      ),
    );
  }
}
