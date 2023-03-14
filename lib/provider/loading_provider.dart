import 'dart:developer';

import 'package:flutter/foundation.dart';

class LoadingProvider extends ChangeNotifier {
  bool _signUpLoading = false;
  bool _creating = false;
  bool _loading = false;
  bool _loginLoading = false;

  // !   Signup Loading

  bool get signUpLoading => _signUpLoading;
  void changeSigupLoading({required bool value}) {
    _signUpLoading = value;
    notifyListeners();
  }

  // !   login Loading
  bool get loginLoading => _loginLoading;
  void changeLoginLoading({required bool value}) {
    _loginLoading = value;
    notifyListeners();
  }

// ! complete profile
  bool get loading => _loading;
  void changeLoading({required bool value}) {
    _loading = value;
    notifyListeners();
  }

  // !  creating chatroom
  bool get creating => _creating;
  void changeCreating({required bool value}) {
    _creating = value;
    notifyListeners();
  }

  // !   showPassword
  bool _showPassword = false;
  bool get showPassword => _showPassword;
  void changeUploadDataLoading({required bool value}) {
    _showPassword = value;
    log("$_showPassword");
    notifyListeners();
  }

  // !   send photo
  bool _send = true;
  bool get send => _send;
  void sendPhotoCmplete({required bool value}) {
    _send = value;
    log("$_send");
    notifyListeners();
  }
}
