import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  Color _themeColor = Colors.deepPurple;

  Color get themeColor => _themeColor;

  set themeColor(Color color) {
    _themeColor = color;
    notifyListeners();
  }
}
