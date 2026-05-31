import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_trigger_input/src/modal/length_map.dart';
import 'package:flutter_trigger_input/src/modal/mention_text_renderer_result.dart';
import 'package:flutter_trigger_input/src/modal/text_segment.dart';

void main() {
  group('MentionTextRendererResult Tests', () {
    test('Khởi tạo thành công với đầy đủ các tham số', () {
      const selection = TextSelection.collapsed(offset: 10);
      final mentionedStrs = [LengthMap(start: 0, end: 5, displayStr: '@James')];
      final segments = [
        TextSegment(text: 'Hello '),
        TextSegment(
          text: '@James',
          attributes: {
            'mention': {'id': '1'},
          },
        ),
      ];

      final result = MentionTextRendererResult(
        cacheDisplayText: 'Hello @James',
        selection: selection,
        text: 'Hello @James',
        mentionedStrs: mentionedStrs,
        segments: segments,
      );

      expect(result.cacheDisplayText, 'Hello @James');
      expect(result.selection.baseOffset, 10);
      expect(result.text, 'Hello @James');
      expect(result.mentionedStrs.length, 1);
      expect(result.segments?.length, 2);
      expect(result.segments?[1].isMention, isTrue);
    });

    test('Khởi tạo với các tham số optional là null', () {
      const selection = TextSelection.collapsed(offset: 0);

      final result = MentionTextRendererResult(
        cacheDisplayText: '',
        selection: selection,
        mentionedStrs: [],
      );

      expect(result.text, isNull);
      expect(result.segments, isNull);
      expect(result.mentionedStrs, isEmpty);
      expect(result.cacheDisplayText, '');
    });
  });
}
