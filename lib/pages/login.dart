import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:simplechat/firebase/auth_credential.dart';
import '../provider/loading_provider.dart';
import 'screens.dart';

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
      bottomNavigationBar: CupertinoButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (builder) => Signup()));
        },
        child: Text(
          "Don't have an Account?     Signup here",
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
                "Login",
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
                onTap: () async {
                  Future<bool> res = FirebaseController().login(
                      context: context,
                      email: emailController.text.toLowerCase(),
                      password: passwordController.text.toLowerCase());

                  log("$res");
                },
                child: provider.loginLoading
                    ? spinkit
                    : Container(
                        height: 60,
                        width: 120,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Theme.of(context).colorScheme.background),
                        child: Center(
                            child: Text(
                          "Login",
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
