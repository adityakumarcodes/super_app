import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WordProvider extends ChangeNotifier {
  List _words = [];
  bool _isLoading = false;
  String? _error;

  List get words => _words;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchWords() async {
    if (_words.isNotEmpty) return; // Cache: don't refetch if already loaded

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await Supabase.instance.client
          .from('words')
          .select()
          .order('id', ascending: true);
      _words = response;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
