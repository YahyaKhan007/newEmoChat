import 'dart:developer';

import 'package:flutter/foundation.dart';

class LoadingProvider extends ChangeNotifier {
  // !   Signup Loading
  bool _signUpLoading = false;

  bool get signUpLoading => _signUpLoading;
  void changeSigupLoading({required bool value}) {
    _signUpLoading = value;
    notifyListeners();
  }

  // !   login Loading

  bool get loginLoading => _signUpLoading;
  void changeLoginLoading({required bool value}) {
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
}
