import 'package:flutter_test/flutter_test.dart';
import 'package:milo/models/note_body.dart';

// Plain unit tests: call a function, then check the result with expect().
void main() {
  group('NoteBody.toBlocks', () {
    test('splits text into one paragraph block per blank-line gap', () {
      final blocks = NoteBody.toBlocks('First\n\nSecond');

      expect(blocks, [
        {
          'type': 'paragraph',
          'data': {'text': 'First'},
        },
        {
          'type': 'paragraph',
          'data': {'text': 'Second'},
        },
      ]);
    });

    test('escapes HTML and keeps single line breaks as <br>', () {
      final blocks = NoteBody.toBlocks('a < b\nc & d');

      expect(blocks.single['data'], {'text': 'a &lt; b<br>c &amp; d'});
    });

    test('ignores empty paragraphs', () {
      expect(NoteBody.toBlocks('  \n\n  '), isEmpty);
    });
  });

  group('NoteBody.toText', () {
    test('round-trips text written by toBlocks', () {
      const text = 'Hello <world>\nline two\n\nSecond & last';

      expect(NoteBody.toText(NoteBody.toBlocks(text)), text);
    });

    test('returns null for notes with non-paragraph blocks', () {
      final blocks = [
        {
          'type': 'image',
          'data': {'url': 'x'},
        },
      ];

      expect(NoteBody.toText(blocks), isNull);
    });

    test('returns null for formatted paragraphs', () {
      final blocks = [
        {
          'type': 'paragraph',
          'data': {'text': '<b>bold</b>'},
        },
      ];

      expect(NoteBody.toText(blocks), isNull);
    });
  });
}
