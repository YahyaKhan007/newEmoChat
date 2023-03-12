import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String? uid;
  String? fullName;
  String? email;
  String? pushToken;
  String? profilePicture;
  String? bio;
  Timestamp? memberSince;
// ! simple Constructor
  UserModel(
      {required this.uid,
      required this.fullName,
      required this.email,
      required this.bio,
      required this.memberSince,
      required this.pushToken,
      required this.profilePicture});

//  !  will be Used to change your Map/Json data into UserModel
  UserModel.fromMap(Map<String, dynamic> map) {
    uid = map["uid"];
    fullName = map["fullName"];
    email = map["email"];
    memberSince = map["memberSince"];
    pushToken = map["pushToken"];
    profilePicture = map["profilePicture"];
    bio = map["bio"];
  }

//  !  will be Used to change your UserModel object into Map/Json
  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "fullName": fullName,
      "email": email,
      "memberSince": memberSince,
      "profilePicture": profilePicture,
      "pushToken": pushToken,
      "bio": bio
    };
  }
}
