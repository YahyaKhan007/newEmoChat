import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart';

import '../models/user_model.dart';

class LocalNotificationServic {
  static String serveKey =
      'AAAAXk1Z2Yw:APA91bEJJT8NzzNAbx-pNe3_h6uB5x84hga6FtIatZmRSXk40p6FzF9H7iVoQ9jmVa_rDM79hfuQxSjssxJQMuXMCCfn_X3q_4dvZXl7z-MxPCxMG5-hyfPYlxI5A0DQlIxq5ib0SqCV';

// !  methode 1
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static void initialize() {
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: AndroidInitializationSettings("@mipmap/launcher_icon"));

    _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // !  methode 2
  static void display(RemoteMessage message) async {
    try {
      Random random = new Random();
      int id = random.nextInt(1000);
      final NotificationDetails notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails("chats", "my chats",
            importance: Importance.max, priority: Priority.high),
      );
      print("My id is ---> ${id.toString()}");

      await _flutterLocalNotificationsPlugin.show(
          id,
          message.notification!.title,
          message.notification!.body,
          notificationDetails);
    } on Exception catch (e) {
      print("Error ------->  $e");
    }
  }

  // !  methode 3
  static Future<void> sendPushNotificatio(
      UserModel chatUser, String msg) async {
    try {
      final body = {
        "to": chatUser.pushToken,
        "notification": {
          "title": chatUser.fullName,
          "body": msg,
          // "android_channel_id": "chats"
        },
        "priority": 'high'
      };

      var res = await post(Uri.parse("https://fcm.googleapis.com/fcm/send"),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader: 'key=$serveKey',
          },
          body: jsonEncode(
            body,
          ));

      print("Response status : ${res.statusCode}");
      print("Response body : ${res.body}");
    } catch (e) {
      print("Send Notification  E --->      $e");
    }
  }
}
