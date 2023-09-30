import 'package:flutter/foundation.dart';

class SpaceControlProvider extends ChangeNotifier {
  double _height = 0;
  double get height => _height;

  void changeHeight({required double hyte}) {
    _height = hyte;
    notifyListeners();
  }
}
