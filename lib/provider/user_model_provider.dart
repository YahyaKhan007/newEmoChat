import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/models.dart';

class UserModelProvider extends ChangeNotifier {
  User? _firebaseUser;
  UserModel? _userModel;

  UserModel get userModel => _userModel!;

  void updateUser(UserModel value) {
    _userModel = value;
    notifyListeners();
    log("============================>>>     Called");
  }

  User? get firebaseUser => _firebaseUser!;

  void updateFirebaseUser(User value) {
    _firebaseUser = value;
    notifyListeners();
  }

  int _screenIndex = 0;
  int get screenIndex => _screenIndex;

  void changeScreenIndex(int value) {
    _screenIndex = value;
    notifyListeners();
  }

  bool _sendEmotion = false;
  bool get sendEmotion => _sendEmotion;

  void changeSendEmotionOption(bool value) {
    _sendEmotion = value;
    notifyListeners();
  }
}
