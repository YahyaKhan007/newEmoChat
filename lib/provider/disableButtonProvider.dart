import 'package:flutter/foundation.dart';

class DisableButtonProvider extends ChangeNotifier {
  // !   Signup Loading
  bool _disable = false;

  bool get disable => _disable;
  void changeSigupLoading({required bool value}) {
    _disable = value;
    notifyListeners();
  }
}
