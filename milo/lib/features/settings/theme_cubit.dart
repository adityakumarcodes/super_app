import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:milo/core/preferences_service.dart';

class ThemeState {
  const ThemeState(this.color, this.mode);
  final Color color;
  final ThemeMode mode;
}

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit(this._preferences)
    : super(
        ThemeState(
          _preferences.accentColor,
          ThemeMode.values.firstWhere(
            (mode) => mode.name == _preferences.savedThemeMode,
            orElse: () => ThemeMode.light,
          ),
        ),
      );
  final PreferencesService _preferences;
  Future<void> setThemeColor(Color color) async {
    await _preferences.saveAccentColor(color);
    emit(ThemeState(color, state.mode));
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == state.mode) return;
    await _preferences.saveThemeMode(mode.name);
    emit(ThemeState(state.color, mode));
  }
}
