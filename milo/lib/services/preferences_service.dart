import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  PreferencesService(this._preferences);

  static const _accentColorKey = 'theme.accentColor';
  static const _themeModeKey = 'theme.mode';
  static const _navigationViewKey = 'navigation.view';
  static const _navigationTabOrderKey = 'navigation.tabOrder';
  static const _hiddenNavigationTabsKey = 'navigation.hiddenTabs';

  final SharedPreferences _preferences;

  static Future<PreferencesService> load() async {
    return PreferencesService(await SharedPreferences.getInstance());
  }

  Color get accentColor =>
      Color(_preferences.getInt(_accentColorKey) ?? Colors.orange.toARGB32());

  String? get savedThemeMode => _preferences.getString(_themeModeKey);

  String? get savedNavigationView => _preferences.getString(_navigationViewKey);

  List<String> get savedNavigationTabOrder =>
      _preferences.getStringList(_navigationTabOrderKey) ?? const [];

  List<String> get savedHiddenNavigationTabs =>
      _preferences.getStringList(_hiddenNavigationTabsKey) ?? const [];

  Future<void> saveAccentColor(Color color) async {
    _requireSave(
      await _preferences.setInt(_accentColorKey, color.toARGB32()),
      'accent color',
    );
  }

  Future<void> saveThemeMode(String modeName) async {
    _requireSave(
      await _preferences.setString(_themeModeKey, modeName),
      'theme mode',
    );
  }

  Future<void> saveNavigationView(String viewName) async {
    _requireSave(
      await _preferences.setString(_navigationViewKey, viewName),
      'navigation view',
    );
  }

  Future<void> saveNavigationTabOrder(List<String> tabNames) async {
    _requireSave(
      await _preferences.setStringList(_navigationTabOrderKey, tabNames),
      'navigation item order',
    );
  }

  Future<void> saveHiddenNavigationTabs(List<String> tabNames) async {
    _requireSave(
      await _preferences.setStringList(_hiddenNavigationTabsKey, tabNames),
      'visible navigation items',
    );
  }

  void _requireSave(bool saved, String setting) {
    if (!saved) throw StateError('Failed to save $setting.');
  }
}
