import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoomModel {
  String? chatroomid;
  Map<String, dynamic>? participants;
  String? lastMessage;
  Timestamp? createdOn;
  Timestamp? updatedOn;
  List<dynamic>? users;

// ! simple Constructor
  ChatRoomModel(
      {this.chatroomid,
      this.participants,
      this.lastMessage,
      this.createdOn,
      this.updatedOn,
      this.users});

//  !  will be Used to change your Map/Json data into ChatRoomModel
  ChatRoomModel.fromMap(Map<String, dynamic> map) {
    chatroomid = map["chatroomid"];
    participants = map["participants"];
    lastMessage = map["lastmessage"];
    createdOn = map["createdOn"];
    updatedOn = map["updatedOn"];
    users = map["users"];
  }

//  !  will be Used to change your ChatRoomModel object into Map/Json
  Map<String, dynamic> toMap() {
    return {
      "chatroomid": chatroomid,
      "participants": participants,
      "lastmessage": lastMessage,
      "createdOn": createdOn,
      "updatedOn": updatedOn,
      "users": users,
    };
  }
}
