import 'package:flutter_better_auth/flutter_better_auth.dart';
import 'package:milo/services/app_config.dart';
import 'package:milo/models/task.dart';

class TaskService {
  Future<List<Task>> fetchTasks() async {
    try {
      final response = await FlutterBetterAuth.dioClient
          .get<List<dynamic>>(AppConfig.notesUrl)
          .timeout(AppConfig.requestTimeout);
      final notes = response.data;
      if (notes == null) throw const FormatException('Missing notes response.');

      return notes
          .map((note) {
            if (note is! Map) {
              throw const FormatException('Invalid note response.');
            }
            return Task.fromApi(Map<String, dynamic>.from(note));
          })
          .toList(growable: false);
    } catch (_) {
      throw Exception(
        'Could not load notes. Check your connection and try again.',
      );
    }
  }

  Future<Task> fetchTask(int id) async {
    try {
      final response = await FlutterBetterAuth.dioClient
          .get<Map<String, dynamic>>('${AppConfig.notesUrl}$id')
          .timeout(AppConfig.requestTimeout);
      final note = response.data;
      if (note == null) {
        throw const FormatException('Missing note response.');
      }

      return Task.fromApi(note);
    } catch (_) {
      throw Exception(
        'Could not load note details. Check your connection and try again.',
      );
    }
  }
}
