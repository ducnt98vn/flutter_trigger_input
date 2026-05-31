import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_trigger_input/src/modal/text_segment.dart';

void main() {
  group('TextSegment Tests', () {
    test('Khởi tạo plain text segment', () {
      final s = TextSegment(text: 'Hello');
      expect(s.isPlain, isTrue);
      expect(s.isMention, isFalse);
      expect(s.text, 'Hello');
    });

    test('Khởi tạo mention segment', () {
      final s = TextSegment(
        text: '@James',
        attributes: {
          'mention': {'id': '1'},
        },
      );
      expect(s.isPlain, isFalse);
      expect(s.isMention, isTrue);
      expect(s.isHashtag, isFalse);
    });

    test('toJson trả về cấu trúc Delta chuẩn', () {
      final s = TextSegment(
        text: '#flutter',
        attributes: {'hashtag': 'flutter'},
      );
      final json = s.toJson();
      expect(json['insert'], '#flutter');
      expect(json['attributes']['hashtag'], 'flutter');
    });

    test('copyWith hoạt động chính xác', () {
      final s1 = TextSegment(text: 'old');
      final s2 = s1.copyWith(text: 'new');
      expect(s2.text, 'new');
      expect(s1.text, 'old');
    });
  });
}
