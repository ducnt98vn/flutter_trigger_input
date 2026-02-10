import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_trigger_input/src/modal/length_map.dart';
import 'package:flutter_trigger_input/src/modal/mention_text_renderer_result.dart';

void main() {
  group('MentionTextRendererResult Tests', () {
    test('Khởi tạo thành công với đầy đủ các tham số', () {
      const selection = TextSelection.collapsed(offset: 10);
      final mentionedStrs = [LengthMap(start: 0, end: 5, displayStr: '@James')];

      final result = MentionTextRendererResult(
        cacheDisplayText: 'Hello @James',
        selection: selection,
        text: 'Hello @James',
        mentionedStrs: mentionedStrs,
      );

      expect(result.cacheDisplayText, 'Hello @James');
      expect(result.selection.baseOffset, 10);
      expect(result.text, 'Hello @James');
      expect(result.mentionedStrs.length, 1);
      expect(result.mentionedStrs[0].displayStr, '@James');
    });

    test('Khởi tạo với các tham số optional là null', () {
      const selection = TextSelection.collapsed(offset: 0);

      final result = MentionTextRendererResult(
        cacheDisplayText: '',
        selection: selection,
        mentionedStrs: [],
      );

      expect(result.text, isNull);
      expect(result.mentionedStrs, isEmpty);
      expect(result.cacheDisplayText, '');
    });

    test('Kiểm tra tính bất biến (Immutability)', () {
      // Vì các trường là final, chúng ta kiểm tra xem dữ liệu có bị thay đổi
      // gián tiếp qua reference của List không
      final list = [LengthMap(start: 0, end: 1, displayStr: '@')];
      final result = MentionTextRendererResult(
        cacheDisplayText: '@',
        selection: const TextSelection.collapsed(offset: 1),
        mentionedStrs: list,
      );

      // Thêm phần tử vào list gốc
      list.add(LengthMap(start: 2, end: 3, displayStr: '#'));

      // Vì result giữ reference của list, nó sẽ thấy sự thay đổi (trừ khi bạn deep copy)
      // Test này giúp bạn quyết định có nên dùng List.unmodifiable hay không
      expect(result.mentionedStrs.length, 2);
    });
  });
}
