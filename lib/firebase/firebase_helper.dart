import '../models/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseHelper {
  // ! Signup Details

  // ! Login Details

  // ! Getting User By ID

  static Future<UserModel?> getUserModelById(String uid) async {
    UserModel? userModel;

    DocumentSnapshot docSnap =
        await FirebaseFirestore.instance.collection("users").doc(uid).get();

    if (docSnap.data() != null) {
      userModel = UserModel.fromMap(docSnap.data() as Map<String, dynamic>);
    }

    return userModel;
  }
}
