import 'dart:async';

import '../models/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

StreamController<UserModel> userDataController = StreamController<UserModel>();

class FirebaseHelper {
  // ! Signup Details

  // ! Login Details

  // ! Getting User By ID

  static Future<UserModel> getUserModelById(String uid) async {
    UserModel? userModel;
    print("===================================>>" + uid.toString());

    DocumentSnapshot docSnap =
        await FirebaseFirestore.instance.collection("users").doc(uid).get();

    if (docSnap.data() != null) {
      userModel = UserModel.fromMap(docSnap.data() as Map<String, dynamic>);

      print(userModel.fullName.toString());
    }

    return userModel!;
  }

  static void getUserData(String uid) async {
    DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection('requests').doc(uid).get();
    UserModel? userModel;

    // Create a UserModel object from the retrieved user data
    if (userSnapshot.data() != null) {
      userModel =
          UserModel.fromMap(userSnapshot.data() as Map<String, dynamic>);

      print(userModel.fullName.toString());
    }

    // Add the UserModel object to the stream
    userDataController.add(userModel!);
  }
}
