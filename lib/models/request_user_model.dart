import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simplechat/models/models.dart';

class UserRequestModel {
  UserModel? sender;
  UserModel? reciever;
// ! simple Constructor
  UserRequestModel({
    required this.sender,
    required this.reciever,
  });

//  !  will be Used to change your Map/Json data into UserModel
  UserRequestModel.fromMap(Map<String, dynamic> map) {
    sender = map["sender"];
    reciever = map["reciever"];
  }

//  !  will be Used to change your UserModel object into Map/Json
  Map<String, dynamic> toMap() {
    return {
      "sender": sender,
      "reciever": reciever,
    };
  }
}
