import 'package:flutter_test/flutter_test.dart';
import 'package:milo/core/task.dart';

void main() {
  test('Task.fromApi reads the unified notes API response', () {
    final task = Task.fromApi({
      'id': 7,
      'title': 'Groceries',
      'imageUrl': 'notes/user/cover.png',
      'coverUrl': 'https://cdn.example/cover.png?token=1',
      'content': '- Milk',
      'createdAt': '2026-01-01T10:00:00.000Z',
      'blocks': [
        {
          'type': 'list',
          'data': {'style': 'unordered', 'items': []},
        },
        'not a block',
      ],
    });

    expect(task.id, 7);
    expect(task.title, 'Groceries');
    expect(task.coverUrl, 'https://cdn.example/cover.png?token=1');
    expect(task.content, '- Milk');
    expect(task.createdOn, '2026-01-01T10:00:00.000Z');
    expect(task.updatedOn, '');
    expect(task.blocks, hasLength(1), reason: 'non-map entries are skipped');
  });

  test('content is null when the API cannot express the note as text', () {
    final task = Task.fromApi({'id': 1, 'content': null});

    expect(task.content, isNull);
    expect(task.blocks, isEmpty);
  });

  test('displayTitle falls back when the title is blank', () {
    expect(const Task(id: 1, title: '  ').displayTitle, 'Untitled note');
    expect(const Task(id: 1, title: ' Plan ').displayTitle, 'Plan');
  });
}
