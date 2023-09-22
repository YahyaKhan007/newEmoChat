import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';

class ModeProvider extends ChangeNotifier {
  String _mode = "";
  String get mode => _mode;
  void updateMode(String mode) {
    _mode = mode;
    notifyListeners();
  }

  String _base64Image = '';
  String get base64Image => _base64Image;
  void updateBase64Image(String base64) {
    _base64Image = base64;

    notifyListeners();
  }

  Uint8List? _bytes = null;
  Uint8List? get bytes => _bytes;
  void updateUni8List(val) async {
    _bytes = val;
    notifyListeners();
  }

  // ^  For Image
  File? _imageFile;

  File? get imageFile => _imageFile;

  void updateImage(File img) {
    _imageFile = img;
    log("Updated --> " + imageFile.toString());
    notifyListeners();
  }

  List<String> _emotionsList = [];
  List<String> get emotionList => _emotionsList;

  void updateEmotionList(String img) {
    _emotionsList.add(img);
    log("Emotion added --> " + img);
    notifyListeners();
  }
}
