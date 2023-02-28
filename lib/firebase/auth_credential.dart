// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simplechat/models/models.dart';
import 'package:simplechat/provider/loading_provider.dart';

import '../pages/screens.dart';

class FirebaseController {
  // ! Signup here
  void signup(
      {required BuildContext context,
      required String email,
      required String password}) async {
    UserCredential? credential;

    var provider = Provider.of<LoadingProvider>(context, listen: false);

    try {
      log("just came here 1");
      provider.changeSigupLoading(value: true);
      credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email.toString(), password: password.toString());
      log("just came here 2 ======================================>  $credential");
    } on FirebaseAuthException catch (e) {
      provider.changeSigupLoading(value: false);

      log(
        "the error is  ============================================?  $e",
      );
    }
    if (credential != null) {
      String uid = credential.user!.uid;
      UserModel newUser =
          UserModel(uid: uid, fullName: "", email: email, profilePicture: "");

      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .set(newUser.toMap())
          .then((value) => provider.changeSigupLoading(value: false))
          .then((value) => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (builder) => CompleteProfile(
                        firebaseUser: credential!.user!,
                        userModel: newUser,
                      ))));
    }
  }

  // ! Login Here

  Future<bool> login(
      {required BuildContext context,
      required String email,
      required String password}) async {
    var provider = Provider.of<LoadingProvider>(context, listen: false);
    try {
      provider.changeSigupLoading(value: true);

      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: email.toString(), password: password.toString());

      String uid = userCredential.user!.uid;
      DocumentSnapshot userData =
          await FirebaseFirestore.instance.collection("users").doc(uid).get();

      UserModel userModel =
          UserModel.fromMap(userData.data() as Map<String, dynamic>);

// ! *****************************************

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("User Logged in")));
      provider.changeSigupLoading(value: false);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (builder) => HomePage(
                    firebaseUser: userCredential.user!,
                    userModel: userModel,
                  )));

      return true;
    } catch (e) {
      provider.changeSigupLoading(value: false);
      log("$e");
      return false;
    }
  }

  // ! Logout
  void signout({required BuildContext context}) {
    FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (builder) => Login()));
  }
}
