// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simplechat/models/models.dart';
import 'package:simplechat/provider/loading_provider.dart';
import 'package:simplechat/provider/user_model_provider.dart';
import 'package:page_transition/page_transition.dart';
import 'package:simplechat/zoom_drawer.dart';
import '../pages/screens/screens.dart';
import '../widgets/utils.dart';

enum Status {
  done,
}

class FirebaseController extends ChangeNotifier {
  // ! Signup here
  void signup(
      {required BuildContext context,
      required String email,
      required String password}) async {
    UserCredential? credential;

    var provider = Provider.of<LoadingProvider>(context, listen: false);
    var userModelProvider =
        Provider.of<UserModelProvider>(context, listen: false);

    try {
      provider.changeSigupLoading(value: true);
      credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email.toString(), password: password.toString());

      log("just came here 2 ======================================>  $credential");
    } on FirebaseAuthException catch (e) {
      provider.changeSigupLoading(value: false);
      provider.changeOtpVisibility(value: true);
      utils.showSnackbar(
          color: Colors.red,
          content: "Provided Email is already is use",
          context: context,
          seconds: 2);

      log(
        "the error is  ============================================?  $e",
      );
    }
    if (credential != null) {
      String uid = credential.user!.uid;
      UserModel newUser = UserModel(
          sendEmotion: true,
          friends: [],
          sender: [],
          reciever: [],
          uid: uid,
          fullName: "",
          email: email,
          profilePicture: "",
          accountType: "",
          bio: "",
          pushToken: "",
          memberSince: Timestamp.now(),
          isVarified: true);

      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .set(newUser.toMap())
          .then((value) => provider.changeSigupLoading(value: false))
          .then((value) => userModelProvider.updateUser(newUser))
          .then(
              (value) => Navigator.popUntil(context, (route) => route.isFirst))
          .then((value) => userModelProvider.changeScreenIndex(0))
          .then((value) => Navigator.pushReplacement(
              context,
              PageTransition(
                  duration: const Duration(milliseconds: 700),
                  type: PageTransitionType.fade,
                  child: CompleteProfile(
                    firebaseUser: credential!.user!,
                    userModel: newUser,
                  ),
                  isIos: true)));
    }
  }

  // ! Login Here

  Future<bool> login(
      {required BuildContext context,
      required String email,
      required String password}) async {
    var provider = Provider.of<LoadingProvider>(context, listen: false);
    var userModelProvider =
        Provider.of<UserModelProvider>(context, listen: false);
    try {
      provider.changeLoginLoading(value: true);

      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: email.toString(), password: password.toString());

      String uid = userCredential.user!.uid;
      DocumentSnapshot userData =
          await FirebaseFirestore.instance.collection("users").doc(uid).get();

      UserModel userModel =
          UserModel.fromMap(userData.data() as Map<String, dynamic>);

// ! *****************************************

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          duration: Duration(milliseconds: 700),
          backgroundColor: Colors.green,
          content: Text("User Logged in")));
      provider.changeLoginLoading(value: false);

      userModelProvider.updateUser(userModel);
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        userModelProvider.updateFirebaseUser(currentUser);
        userModelProvider.changeScreenIndex(0);
      }
      Navigator.popUntil(context, (route) => route.isFirst);

      Navigator.pushReplacement(
          context,
          PageTransition(
              duration: const Duration(milliseconds: 700),
              type: PageTransitionType.fade,
              child: userModelProvider.userModel.fullName == ""
                  ? CompleteProfile(
                      userModel: userModel,
                      firebaseUser: userModelProvider.firebaseUser!)
                  : MyHomePage(userModel: userModel),
              isIos: true));

      return true;
    } catch (e) {
      provider.changeLoginLoading(value: false);
      utils.showSnackbar(
          context: context,
          color: Colors.redAccent,
          content: "InValid Email Password",
          seconds: 3);
      // Loading.showAlertDialog(context, "Signup Error", e.toString());
      log("$e");
      return false;
    }
  }

  // ! Logout
  static void signout({required BuildContext context}) async {
    await FirebaseAuth.instance.signOut();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        duration: Duration(milliseconds: 700),
        content: Text("User Logged Out")));
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (builder) => Login()));
  }
}
