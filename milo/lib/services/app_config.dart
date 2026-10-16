import 'package:flutter/foundation.dart';

abstract final class AppConfig {
  static const _configuredApiBaseUrl = String.fromEnvironment('API_BASE_URL');
  static const requestTimeout = Duration(seconds: 15);

  static String get apiBaseUrl {
    final configuredUrl = _configuredApiBaseUrl.trim();
    if (configuredUrl.isNotEmpty) return _withoutTrailingSlash(configuredUrl);

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://192.168.1.11:3000/api';
    }
    return 'http://localhost:3000/api';
  }

  static String get authBaseUrl => '$apiBaseUrl/auth';
  static String get notesUrl => '$apiBaseUrl/notes/';

  static String _withoutTrailingSlash(String value) =>
      value.endsWith('/') ? value.substring(0, value.length - 1) : value;
}
