import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoomModel {
  String? chatroomid;
  Map<String, dynamic>? participants;
  String? lastMessage;
  Timestamp? timeChatroom;

// ! simple Constructor
  ChatRoomModel(
      {this.chatroomid,
      this.participants,
      this.lastMessage,
      this.timeChatroom});

//  !  will be Used to change your Map/Json data into ChatRoomModel
  ChatRoomModel.fromMap(Map<String, dynamic> map) {
    chatroomid = map["chatroomid"];
    participants = map["participants"];
    lastMessage = map["lastmessage"];
    timeChatroom = map["timeChatroom"];
  }

//  !  will be Used to change your ChatRoomModel object into Map/Json
  Map<String, dynamic> toMap() {
    return {
      "chatroomid": chatroomid,
      "participants": participants,
      "lastmessage": lastMessage,
      "timeChatroom": timeChatroom,
    };
  }
}
