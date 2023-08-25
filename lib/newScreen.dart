import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NewScreen extends StatefulWidget {
  NewScreen({super.key});

  @override
  State<NewScreen> createState() => _NewScreenState();
}

String appId = "dc0f522c825e41a090c7dc6c5033f65a";

class _NewScreenState extends State<NewScreen> {
  // Instantiate the client

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Email Auth sample'),
          ),
          body: Column(
            children: [
              TextField(
                controller: email,
                decoration: InputDecoration(hintText: "Email"),
              ),
              TextField(
                controller: password,
                decoration: InputDecoration(hintText: "Password"),
              ),
              CupertinoButton(
                child: Text("Signup"),
                onPressed: () async {
                  try {
                    await FirebaseAuth.instance
                        .createUserWithEmailAndPassword(
                            email: email.text.trim(),
                            password: password.text.trim())
                        .then((value) => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (builder) => EmailvarifiedPage())));
                  } on FirebaseAuthException catch (e) {
                    print(e);
                    Utils.snakbar(context: context, content: "${e.message}");
                  }
                },
              )
            ],
          )),
    );
  }
}

class EmailvarifiedPage extends StatefulWidget {
  EmailvarifiedPage({super.key});

  @override
  State<EmailvarifiedPage> createState() => _EmailvarifiedPageState();
}

class _EmailvarifiedPageState extends State<EmailvarifiedPage> {
  bool isEmailVarified = false;

  @override
  void initState() {
    super.initState();

    isEmailVarified = FirebaseAuth.instance.currentUser!.emailVerified;

    if (!isEmailVarified) {
      sendVarificationEmail();

      // timer = Timer.periodic(Duration(seconds: 3), (_) => checkEmailVarified());
    } else {}
  }

  void checkEmailVarified() {
    setState(() {
      isEmailVarified = FirebaseAuth.instance.currentUser!.emailVerified;
    });
  }

  @override
  void dispose() {
    super.dispose();
    // timer!.cancel();
  }

  Future sendVarificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      await user!.sendEmailVerification();
    } catch (e) {
      Utils.snakbar(context: context, content: "${e}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return isEmailVarified
        ? HomePage()
        : Scaffold(
            appBar: AppBar(
              title: Text("Not Varified"),
            ),
          );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Email is  Varified"),
      ),
    );
  }
}

class Utils extends StatelessWidget {
  const Utils({super.key});
  static snakbar({required BuildContext context, required String content}) {
    return ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(content)));
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
