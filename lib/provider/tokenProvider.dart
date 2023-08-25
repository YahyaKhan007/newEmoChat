import 'package:flutter/foundation.dart';

class TokenProvider extends ChangeNotifier {
  String _token = "";

  String get token => _token;
  void changeToken({required String value}) {
    _token = value;
    notifyListeners();
  }
}
