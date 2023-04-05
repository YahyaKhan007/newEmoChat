// ignore: file_names
import 'package:flutter/foundation.dart';

class RandomName extends ChangeNotifier {
  // !   Signup Loading
  int _name = 0;

  int get randomName => _name;
  void randomNameChanger({required int value}) {
    _name = value;
    notifyListeners();
  }

  // ! check Messgae

  bool _disable = false;

  bool get disbale => _disable;
  void changeDisbale({required bool value}) {
    _disable = value;
    notifyListeners();
  }

  // ! check frnd

  bool _frnd = false;

  bool get frnd => _frnd;
  void changeFrnd({required bool value}) {
    _frnd = value;
    notifyListeners();
  }
}
