import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_trigger_input/src/controllers/tf_controller.dart';
import 'package:flutter_trigger_input/src/modal/length_map.dart';
import 'package:flutter_trigger_input/src/utils/bbcode.dart';
import 'package:flutter_trigger_input/src/utils/text_edit/mention_text_renderer.dart';

class TestCase {
  final String description;
  final String cacheText;
  final TextSelection cacheSelection;
  final String newText;
  final TextSelection newSelection;
  final List<LengthMap> initialMentions;
  final String expectedText;
  final int expectedOffset;
  final int expectedMentionCount;
  final List<Map<String, dynamic>>? expectedMentionDetails;

  TestCase({
    required this.description,
    required this.cacheText,
    required this.cacheSelection,
    required this.newText,
    required this.newSelection,
    this.initialMentions = const [],
    required this.expectedText,
    required this.expectedOffset,
    required this.expectedMentionCount,
    this.expectedMentionDetails,
  });
}

void main() {
  final renderer = MentionTextRenderer();
  final tfController = TFController();

  void runTests(String groupName, List<TestCase> cases) {
    group(groupName, () {
      for (var tc in cases) {
        test(tc.description, () {
          tfController.text = tc.newText;
          tfController.selection = tc.newSelection;
          tfController.mentionedStrs = tc.initialMentions;

          final result = renderer.execute(
            cacheDisplayText: tc.cacheText,
            tfController: tfController,
            cacheSelection: tc.cacheSelection,
          );

          expect(result.cacheDisplayText, tc.expectedText, reason: 'Text mismatch in: ${tc.description}');
          expect(result.selection.extentOffset, tc.expectedOffset, reason: 'Selection offset mismatch in: ${tc.description}');
          expect(result.mentionedStrs.length, tc.expectedMentionCount, reason: 'Mention count mismatch in: ${tc.description}');
          
          if (tc.expectedMentionDetails != null) {
            for (int i = 0; i < tc.expectedMentionDetails!.length; i++) {
              final expected = tc.expectedMentionDetails![i];
              final actual = result.mentionedStrs[i];
              expect(actual.start, expected['start'], reason: 'Mention $i start mismatch');
              expect(actual.end, expected['end'], reason: 'Mention $i end mismatch');
              expect(actual.displayStr, expected['displayStr'], reason: 'Mention $i displayStr mismatch');
            }
          }
        });
      }
    });
  }

  runTests('Hashtag & Multi-Trigger', [
    TestCase(
      description: '1. Thêm text vào TRƯỚC một hashtag',
      cacheText: "Hello #flutter",
      cacheSelection: const TextSelection.collapsed(offset: 0),
      newText: "Hi ! Hello #flutter",
      newSelection: const TextSelection.collapsed(offset: 5),
      initialMentions: [
        LengthMap(start: 6, end: 14, displayStr: '#flutter', originStr: BbCode.createMentionBbob(trigger: '#', id: '1', name: 'flutter')),
      ],
      expectedText: "Hi ! Hello #flutter",
      expectedOffset: 5,
      expectedMentionCount: 1,
      expectedMentionDetails: [{'start': 11, 'end': 19, 'displayStr': '#flutter'}],
    ),
    TestCase(
      description: '2. Xoá một phần hashtag (Xoá lùi) -> Xoá toàn bộ',
      cacheText: "#flutter",
      cacheSelection: const TextSelection.collapsed(offset: 8),
      newText: "#flutte",
      newSelection: const TextSelection.collapsed(offset: 7),
      initialMentions: [
        LengthMap(start: 0, end: 8, displayStr: '#flutter', originStr: BbCode.createMentionBbob(trigger: '#', id: '1', name: 'flutter')),
      ],
      expectedText: "",
      expectedOffset: 0,
      expectedMentionCount: 0,
    ),
    TestCase(
      description: '3. Thay thế một phần hashtag bằng text khác -> Xoá metadata',
      cacheText: "Love #dart",
      cacheSelection: const TextSelection(baseOffset: 5, extentOffset: 10),
      newText: "Love #java",
      newSelection: const TextSelection.collapsed(offset: 10),
      initialMentions: [
        LengthMap(start: 5, end: 10, displayStr: '#dart', originStr: BbCode.createMentionBbob(trigger: '#', id: '2', name: 'dart')),
      ],
      expectedText: "Love #java",
      expectedOffset: 10,
      expectedMentionCount: 0,
    ),
    TestCase(
      description: '4. Hỗ trợ nhiều loại trigger cùng lúc (@, #, [)',
      cacheText: "@user #news",
      cacheSelection: const TextSelection.collapsed(offset: 6),
      newText: "@user and #news",
      newSelection: const TextSelection.collapsed(offset: 10),
      initialMentions: [
        LengthMap(start: 0, end: 5, displayStr: '@user', originStr: BbCode.createMentionBbob(trigger: '@', id: '1', name: 'user')),
        LengthMap(start: 6, end: 11, displayStr: '#news', originStr: BbCode.createMentionBbob(trigger: '#', id: '2', name: 'news')),
      ],
      expectedText: "@user and #news",
      expectedOffset: 10,
      expectedMentionCount: 2,
      expectedMentionDetails: [
        {'start': 0, 'end': 5, 'displayStr': '@user'},
        {'start': 10, 'end': 15, 'displayStr': '#news'},
      ],
    ),
  ]);

  runTests('Vòng đời Mention (CRUD)', [
    TestCase(
      description: 'Dán (Paste) đoạn text chứa BBCode',
      cacheText: "",
      cacheSelection: const TextSelection.collapsed(offset: 0),
      newText: "Check ${BbCode.createMentionBbob(trigger: '@', id: 'u1', name: 'John')}",
      newSelection: TextSelection.collapsed(offset: "Check ${BbCode.createMentionBbob(trigger: '@', id: 'u1', name: 'John')}".length),
      expectedText: "Check @John",
      expectedOffset: 11,
      expectedMentionCount: 1,
      expectedMentionDetails: [{'start': 6, 'end': 11, 'displayStr': '@John'}],
    ),
    TestCase(
      description: 'Thêm text vào SAU một mention',
      cacheText: "@John",
      cacheSelection: const TextSelection.collapsed(offset: 5),
      newText: "@John is back",
      newSelection: const TextSelection.collapsed(offset: 13),
      initialMentions: [
        LengthMap(start: 0, end: 5, displayStr: '@John', originStr: BbCode.createMentionBbob(trigger: '@', id: 'u1', name: 'John')),
      ],
      expectedText: "@John is back",
      expectedOffset: 13,
      expectedMentionCount: 1,
    ),
    TestCase(
      description: 'Xoá trắng mention bằng Backspace (Atomic Deletion)',
      cacheText: "@John",
      cacheSelection: const TextSelection.collapsed(offset: 5),
      newText: "@Joh",
      newSelection: const TextSelection.collapsed(offset: 4),
      initialMentions: [
        LengthMap(start: 0, end: 5, displayStr: '@John', originStr: BbCode.createMentionBbob(trigger: '@', id: 'u1', name: 'John')),
      ],
      expectedText: "",
      expectedOffset: 0,
      expectedMentionCount: 0,
    ),
  ]);

  runTests('Logic ranh giới và con trỏ', [
    TestCase(
      description: 'Xoá ký tự trắng ngay trước mention',
      cacheText: "Hello @John",
      cacheSelection: const TextSelection.collapsed(offset: 6),
      newText: "Hello@John",
      newSelection: const TextSelection.collapsed(offset: 5),
      initialMentions: [
        LengthMap(start: 6, end: 11, displayStr: '@John', originStr: BbCode.createMentionBbob(trigger: '@', id: 'u1', name: 'John')),
      ],
      expectedText: "Hello@John",
      expectedOffset: 5,
      expectedMentionCount: 1,
      expectedMentionDetails: [{'start': 5, 'end': 10, 'displayStr': '@John'}],
    ),
    TestCase(
      description: 'Nhập ký tự trùng với ký tự đầu của mention',
      cacheText: "@James",
      cacheSelection: const TextSelection.collapsed(offset: 0),
      newText: "@@James",
      newSelection: const TextSelection.collapsed(offset: 1),
      initialMentions: [
        LengthMap(start: 0, end: 6, displayStr: '@James', originStr: BbCode.createMentionBbob(trigger: '@', id: 'u1', name: 'James')),
      ],
      expectedText: "@@James",
      expectedOffset: 1,
      expectedMentionCount: 1,
      expectedMentionDetails: [{'start': 1, 'end': 7, 'displayStr': '@James'}],
    ),
    TestCase(
      description: 'Case emoji xen kẽ mention: "Hi @James 🔥"',
      cacheText: "Hi @James 🔥",
      cacheSelection: const TextSelection.collapsed(offset: 12),
      newText: "Hi @James 🔥 updated",
      newSelection: const TextSelection.collapsed(offset: 20),
      initialMentions: [
        LengthMap(start: 3, end: 9, displayStr: '@James', originStr: '...'),
      ],
      expectedText: "Hi @James 🔥 updated",
      expectedOffset: 20,
      expectedMentionCount: 1,
      expectedMentionDetails: [{'start': 3, 'end': 9, 'displayStr': '@James'}],
    ),
    TestCase(
      description: 'Mention nằm ở dòng thứ 2 (Text đa dòng)',
      cacheText: "Line1\n@John",
      cacheSelection: const TextSelection.collapsed(offset: 5),
      newText: "Line1 - updated\n@John",
      newSelection: const TextSelection.collapsed(offset: 15),
      initialMentions: [
        LengthMap(start: 6, end: 11, displayStr: '@John', originStr: '...'),
      ],
      expectedText: "Line1 - updated\n@John",
      expectedOffset: 15,
      expectedMentionCount: 1,
      expectedMentionDetails: [{'start': 16, 'end': 21, 'displayStr': '@John'}],
    ),
  ]);

  runTests('Xử lý lỗi & Trường hợp đặc biệt', [
    TestCase(
      description: 'Thay đổi ID của mention trong markup',
      cacheText: "@John",
      cacheSelection: const TextSelection(baseOffset: 0, extentOffset: 5),
      newText: "[mention trigger=\"@\" id=\"new_id\" name=\"John\"][/mention]",
      newSelection: const TextSelection.collapsed(offset: 55),
      initialMentions: [
        LengthMap(start: 0, end: 5, displayStr: '@John', originStr: BbCode.createMentionBbob(trigger: '@', id: 'old_id', name: 'John')),
      ],
      expectedText: "@John",
      expectedOffset: 5,
      expectedMentionCount: 1,
    ),
  ]);
}
