import 'package:flutter/foundation.dart';

class NotifyProvider extends ChangeNotifier {
  bool _isColse = false;

  bool get isClose => _isColse;
  void changeCloseOption({required bool value}) {
    _isColse = value;
    notifyListeners();
  }
}
