import 'package:flutter_test/flutter_test.dart';
import 'package:milo/models/task.dart';

void main() {
  test('Task.fromApi reads the fields returned by the notes API', () {
    final task = Task.fromApi({
      'id': 7,
      'title': 'Groceries',
      'imageUrl': 'notes/user/cover.png',
      'createdAt': '2026-01-01T10:00:00.000Z',
      'blocks': [
        {
          'type': 'paragraph',
          'data': {'text': 'Milk'},
        },
        'not a block',
      ],
    });

    expect(task.id, 7);
    expect(task.title, 'Groceries');
    expect(task.imageUrl, 'notes/user/cover.png');
    expect(task.createdOn, '2026-01-01T10:00:00.000Z');
    expect(task.updatedOn, '');
    expect(task.blocks, hasLength(1), reason: 'non-map entries are skipped');
  });

  test('displayTitle falls back when the title is blank', () {
    expect(const Task(id: 1, title: '  ').displayTitle, 'Untitled note');
    expect(const Task(id: 1, title: ' Plan ').displayTitle, 'Plan');
  });

  test('copyWith replaces blocks and keeps everything else', () {
    const original = Task(id: 1, title: 'A', imageUrl: 'img');
    final copy = original.copyWith(
      blocks: [
        {'type': 'delimiter', 'data': <String, dynamic>{}},
      ],
    );

    expect(copy.id, 1);
    expect(copy.title, 'A');
    expect(copy.imageUrl, 'img');
    expect(copy.blocks, hasLength(1));
  });
}
