import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task.dart';

class TaskService {
  Future<List<Task>> fetchActiveTasks() async {
    try {
      final response = await Supabase.instance.client
          .from('notes')
          .select()
          .isFilter('category', null)
          .eq('type', 'task')
          .eq('status_flag', 'active')
          .order('id');
      return response.map((json) => Task.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch tasks: $e');
    }
  }
}
