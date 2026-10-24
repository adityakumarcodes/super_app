import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:milo/core/app_config.dart';

class WordState {
  const WordState({this.words = const [], this.isLoading = true, this.error});
  final List<Map<String, String>> words;
  final bool isLoading;
  final String? error;
}

class WordCubit extends Cubit<WordState> {
  WordCubit({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 5),
              receiveTimeout: const Duration(seconds: 5),
            ),
          ),
      super(const WordState()) {
    loadWords();
  }
  final Dio _dio;
  Future<void> loadWords() async {
    emit(const WordState());
    try {
      final response = await _dio.get(
        '${AppConfig.apiBaseUrl}/word-of-the-day',
      );
      final words = (response.data as List)
          .map(
            (item) => {
              'word': item['word'] as String,
              'meaning': item['meaning'] as String,
            },
          )
          .toList(growable: false);
      emit(WordState(words: words, isLoading: false));
    } catch (_) {
      emit(const WordState(isLoading: false, error: 'Unable to load words.'));
    }
  }
}
