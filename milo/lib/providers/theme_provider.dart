import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  Color _themeColor = Colors.orange;

  Color get themeColor => _themeColor;

  set themeColor(Color color) {
    _themeColor = color;
    notifyListeners();
  }
}
