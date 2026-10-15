import 'package:flutter/material.dart';
import 'package:milo/services/preferences_service.dart';

class ThemeProvider with ChangeNotifier {
  ThemeProvider(this._preferences)
    : _themeColor = _preferences.accentColor,
      _themeMode = ThemeMode.values.firstWhere(
        (mode) => mode.name == _preferences.savedThemeMode,
        orElse: () => ThemeMode.system,
      );

  final PreferencesService _preferences;
  Color _themeColor;
  ThemeMode _themeMode;

  Color get themeColor => _themeColor;
  ThemeMode get themeMode => _themeMode;

  Future<void> setThemeColor(Color color) async {
    await _preferences.saveAccentColor(color);
    _themeColor = color;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    await _preferences.saveThemeMode(mode.name);
    _themeMode = mode;
    notifyListeners();
  }
}
