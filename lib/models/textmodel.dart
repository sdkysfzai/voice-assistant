import 'package:flutter/cupertino.dart';

class TextModel with ChangeNotifier {
  TextModel(
    this.text,
    this.isListening,
    this.shouldShowMsg,
  );

  String text;
  bool isListening;
  bool shouldShowMsg;

  showMessage(bool val) {
    shouldShowMsg = val;
    notifyListeners();
  }

  setText(String newText) {
    text = newText;
    notifyListeners();
  }

  setIsListening(bool isListening) {
    isListening = isListening;
    notifyListeners();
  }
}
