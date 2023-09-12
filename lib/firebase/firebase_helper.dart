import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

import '../models/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../provider/user_model_provider.dart';

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

  void updateUserModelWithFirebaseUser(
      UserModelProvider userModelProvider) async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    User? firebaseUser = _auth.currentUser;

    // Assuming you have a function to fetch UserModel from Firebase
    await fetchUserModelFromFirebase(firebaseUser!);

    // Update the provider with the new user data
    // userModelProvider.updateUser(newUserModel);
  }

  Future<UserModel?> fetchUserModelFromFirebase(User firebaseUser) async {
    UserModel? userModel;

    // Get the user's ID
    String userId = firebaseUser.uid;

    // Assuming you have a Firestore collection named 'users'
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userDoc.exists) {
      // Convert the Firestore document data to your UserModel
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      userModel = UserModel.fromMap(
          userData); // You'll need to define fromJson method in UserModel class

      return userModel;
    }
    return userModel;

    // Return a default user model or handle the case where the user is not found
    // You'll need to define your default UserModel constructor
  }
}
