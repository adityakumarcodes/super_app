import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class WordProvider extends ChangeNotifier {
  WordProvider() {
    loadWords();
  }

  final _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ),
  );

  List<Map<String, String>> words = [];
  bool isLoading = true;
  String? error;

  Future<void> loadWords() async {
    try {
      final response = await _dio.get(
        'http://192.168.1.11:3000/api/word-of-the-day',
      );
      // hostname -I
      words = (response.data as List)
          .map(
            (item) => {
              'word': item['word'] as String,
              'meaning': item['meaning'] as String,
            },
          )
          .toList();

      error = null;
    } catch (e) {
      error = 'Unable to load words.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
