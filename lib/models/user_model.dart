import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String? uid;
  String? fullName;
  String? email;
  String? pushToken;
  String? profilePicture;
  String? accountType;
  List? friends;
  List? sender;
  List? reciever;
  String? bio;
  Timestamp? memberSince;
  bool? isVarified;
// ! simple Constructor
  UserModel(
      {required this.uid,
      required this.fullName,
      required this.email,
      required this.bio,
      required this.sender,
      required this.reciever,
      required this.friends,
      required this.memberSince,
      required this.accountType,
      required this.pushToken,
      required this.isVarified,
      required this.profilePicture});

//  !  will be Used to change your Map/Json data into UserModel
  UserModel.fromMap(Map<String, dynamic> map) {
    uid = map["uid"];
    fullName = map["fullName"];
    email = map["email"];
    friends = map["friends"];
    sender = map["sender"];
    reciever = map["reciever"];
    memberSince = map["memberSince"];
    pushToken = map["pushToken"];
    accountType = map["accountType"];
    isVarified = map['isVarified'];
    profilePicture = map["profilePicture"];
    bio = map["bio"];
  }

//  !  will be Used to change your UserModel object into Map/Json
  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "fullName": fullName,
      "email": email,
      "friends": friends,
      "sender": sender,
      "reciever": reciever,
      "memberSince": memberSince,
      "accountType": accountType,
      "profilePicture": profilePicture,
      "pushToken": pushToken,
      'isVarified': isVarified,
      "bio": bio
    };
  }
}
