import 'package:flutter/foundation.dart';

class NotifyProvider extends ChangeNotifier {
  bool _isColse = false;

  bool get isClose => _isColse;
  void changeCloseOption({required bool value}) {
    _isColse = value;
    notifyListeners();
  }

// ^ condition for terms and conditions

  bool _acceptTermsCondition = false;
  bool get acceptTermsCondition => _acceptTermsCondition;
  void changeAcceptTermsCondition({required bool value}) {
    _acceptTermsCondition = value;
    notifyListeners();
  }
}
