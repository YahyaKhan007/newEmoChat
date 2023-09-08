import 'dart:developer';

import 'package:flutter/foundation.dart';

class LoadingProvider extends ChangeNotifier {
  bool _signUpLoading = false;
  bool _creating = false;
  bool _loading = false;
  bool _loginLoading = false;
  bool _show = true;
  bool _Show = true;

  bool _otpVisibility = false;
  bool get otpVisibility => _otpVisibility;
  void changeOtpVisibility({required bool value}) {
    _otpVisibility = value;
    notifyListeners();
  }

  bool _signupText = false;
  bool get signupText => _signupText;
  void changeSignupText({required bool value}) {
    _signupText = value;
    notifyListeners();
  }

  bool _emailVarified = false;
  bool get emailVarified => _emailVarified;
  void changeEmailVarfied({required bool value}) {
    _emailVarified = value;
    notifyListeners();
  }
  // !   Signup Loading

  bool get signUpLoading => _signUpLoading;
  void changeSigupLoading({required bool value}) {
    _signUpLoading = value;
    notifyListeners();
  }

  bool get show => _show;
  void changeShow({required bool value}) {
    _show = value;
    notifyListeners();
  }

  bool get Show => _show;
  void ChangeShow({required bool value}) {
    _Show = value;
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

  // !   send Request
  bool _sendRequest = false;
  bool get sendRequest => _sendRequest;
  void changeSendRequest({required bool value}) {
    _sendRequest = value;
    notifyListeners();
  }

  // !   send Request
  bool _pending = false;
  bool get pending => _pending;
  void changePending({required bool value}) {
    _pending = value;
    notifyListeners();
  }

  // !   count friends
  bool _friendsCOunt = true;
  bool get friendsCOunt => _friendsCOunt;
  void changeFriendsCount({required bool value}) {
    _friendsCOunt = value;
    notifyListeners();
  }
}
