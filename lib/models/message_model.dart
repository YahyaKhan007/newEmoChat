import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  String? messageId;
  String? sender;
  String? text;
  bool? seen;
  Timestamp? createdOn;

// ! simple Constructor
  MessageModel(
      {this.messageId, this.sender, this.text, this.seen, this.createdOn});

//  !  will be Used to change your Map/Json data into MessageModel
  MessageModel.fromMap(Map<String, dynamic> map) {
    messageId = map["messageId"];
    sender = map["sender"];
    text = map["text"];
    seen = map["seen"];
    createdOn = map["createdOn"];
  }

//  !  will be Used to change your MessageModel object into Map/Json
  Map<String, dynamic> toMap() {
    return {
      "messageId": messageId,
      "sender": sender,
      "text": text,
      "seen": seen,
      "createdOn": createdOn
    };
  }
}
