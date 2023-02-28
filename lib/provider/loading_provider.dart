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
  bool _loginLoading = false;

  bool get loginLoading => _signUpLoading;
  void changeLoginLoading({required bool value}) {
    _loginLoading = value;
    notifyListeners();
  }

  // !   DataUploading
  bool _uploadDataLoading = false;
  bool get uploadDataLoading => _uploadDataLoading;
  void changeUploadDataLoading({required bool value}) {
    _uploadDataLoading = value;
    log("$_uploadDataLoading");
    notifyListeners();
  }
}
