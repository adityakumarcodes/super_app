import 'package:dio/dio.dart';
import 'package:flutter_better_auth/flutter_better_auth.dart';
import 'package:milo/core/task.dart';
import 'package:milo/core/app_config.dart';

/// Talks to the unified notes API. Responses are display-ready, so this class
/// only sends requests and parses JSON.
class TaskService {
  Dio get _dio => FlutterBetterAuth.dioClient;

  Future<List<Task>> fetchTasks() async {
    try {
      final response = await _dio
          .get<List<dynamic>>(AppConfig.notesUrl)
          .timeout(AppConfig.requestTimeout);
      return (response.data ?? const [])
          .whereType<Map>()
          .map((note) => Task.fromApi(Map<String, dynamic>.from(note)))
          .toList(growable: false);
    } catch (_) {
      throw Exception(
        'Could not load notes. Check your connection and try again.',
      );
    }
  }

  Future<Task> fetchTask(int id) async {
    try {
      final response = await _dio
          .get<Map<String, dynamic>>('${AppConfig.notesUrl}$id')
          .timeout(AppConfig.requestTimeout);
      return Task.fromApi(response.data!);
    } catch (_) {
      throw Exception(
        'Could not load note details. Check your connection and try again.',
      );
    }
  }

  /// [content] is note text; the backend turns it into Editor.js blocks.
  Future<Task> createTask({
    required String title,
    required String content,
  }) async {
    try {
      final response = await _dio
          .post<Map<String, dynamic>>(
            AppConfig.notesUrl,
            data: {'title': title, 'content': content},
          )
          .timeout(AppConfig.requestTimeout);
      return Task.fromApi(response.data!);
    } catch (_) {
      throw Exception('Could not save the note. Try again.');
    }
  }

  /// Leave [content] null to keep the note's existing blocks.
  Future<Task> updateTask(
    int id, {
    required String title,
    String? content,
  }) async {
    try {
      final response = await _dio
          .patch<Map<String, dynamic>>(
            '${AppConfig.notesUrl}$id',
            data: {'title': title, if (content != null) 'content': content},
          )
          .timeout(AppConfig.requestTimeout);
      return Task.fromApi(response.data!);
    } catch (_) {
      throw Exception('Could not save the note. Try again.');
    }
  }

  Future<void> deleteTask(int id) async {
    try {
      await _dio
          .delete<void>('${AppConfig.notesUrl}$id')
          .timeout(AppConfig.requestTimeout);
    } catch (_) {
      throw Exception('Could not delete the note. Try again.');
    }
  }
}
