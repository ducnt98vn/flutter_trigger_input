import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_trigger_input/src/controllers/tf_controller.dart';
import 'package:flutter_trigger_input/src/modal/text_segment.dart';
import 'package:flutter_trigger_input/src/utils/text_edit/mention_text_renderer.dart';

class TestCase {
  final String description;
  final String cacheText;
  final TextSelection cacheSelection;
  final String newText;
  final TextSelection newSelection;
  final TextRange composing;
  final List<TextSegment> initialSegments;
  final String expectedText;
  final int expectedOffset;
  final TextRange expectedComposing;
  final int expectedMentionCount;

  TestCase({
    required this.description,
    required this.cacheText,
    required this.cacheSelection,
    required this.newText,
    required this.newSelection,
    this.composing = TextRange.empty,
    this.initialSegments = const [],
    required this.expectedText,
    required this.expectedOffset,
    this.expectedComposing = TextRange.empty,
    required this.expectedMentionCount,
  });
}

void main() {
  final renderer = MentionTextRenderer();
  final tfController = TFController();

  void runTests(String groupName, List<TestCase> cases) {
    group(groupName, () {
      for (var tc in cases) {
        test(tc.description, () {
          // Setup state
          tfController.segmentsInternal = tc.initialSegments.isEmpty
              ? [TextSegment(text: tc.cacheText)]
              : tc.initialSegments;

          // We use a safe value for initial TextEditingValue to avoid assertion errors
          // in the controller's setter before we even run our test logic.
          tfController.value = TextEditingValue(
            text: tc.newText,
            selection: tc.newSelection,
            composing: tc.composing.isValid && tc.composing.end <= tc.newText.length 
                ? tc.composing 
                : TextRange.empty,
          );

          final result = renderer.execute(
            cacheDisplayText: tc.cacheText,
            tfController: tfController,
            cacheSelection: tc.cacheSelection,
          );

          expect(
            result.cacheDisplayText,
            tc.expectedText,
            reason: 'Text mismatch in: ${tc.description}',
          );
          expect(
            result.selection.extentOffset,
            tc.expectedOffset,
            reason: 'Selection offset mismatch in: ${tc.description}',
          );
          expect(
            result.composing,
            tc.expectedComposing,
            reason: 'Composing range mismatch in: ${tc.description}',
          );

          // Count non-plain segments
          final mentionCount =
              result.segments?.where((s) => !s.isPlain).length ?? 0;
          expect(
            mentionCount,
            tc.expectedMentionCount,
            reason: 'Mention count mismatch in: ${tc.description}',
          );
        });
      }
    });
  }

  runTests('Hashtag & Multi-Trigger (Segment Architecture)', [
    TestCase(
      description: '1. Thêm text vào TRƯỚC một hashtag',
      cacheText: "Hello #flutter",
      cacheSelection: const TextSelection.collapsed(offset: 0),
      newText: "Hi ! Hello #flutter",
      newSelection: const TextSelection.collapsed(offset: 5),
      initialSegments: [
        TextSegment(text: "Hello "),
        TextSegment(text: "#flutter", attributes: {"hashtag": "flutter"}),
      ],
      expectedText: "Hi ! Hello #flutter",
      expectedOffset: 5,
      expectedMentionCount: 1,
    ),
    TestCase(
      description: '2. Xoá một phần hashtag -> Xoá toàn bộ (Atomic)',
      cacheText: "#flutter",
      cacheSelection: const TextSelection.collapsed(offset: 8),
      newText: "#flutte",
      newSelection: const TextSelection.collapsed(offset: 7),
      initialSegments: [
        TextSegment(text: "#flutter", attributes: {"hashtag": "flutter"}),
      ],
      expectedText: "",
      expectedOffset: 0,
      expectedMentionCount: 0,
    ),
    TestCase(
      description: '3. Thay thế một phần hashtag -> Biến thành plain text',
      cacheText: "Love #dart",
      cacheSelection: const TextSelection(baseOffset: 5, extentOffset: 10),
      newText: "Love #java",
      newSelection: const TextSelection.collapsed(offset: 10),
      initialSegments: [
        TextSegment(text: "Love "),
        TextSegment(text: "#dart", attributes: {"hashtag": "dart"}),
      ],
      expectedText: "Love #java",
      expectedOffset: 10,
      expectedMentionCount: 0,
    ),
  ]);

  runTests('Vòng đời Mention (CRUD)', [
    TestCase(
      description: 'Xoá trắng mention bằng Backspace (Atomic Deletion)',
      cacheText: "@John",
      cacheSelection: const TextSelection.collapsed(offset: 5),
      newText: "@Joh",
      newSelection: const TextSelection.collapsed(offset: 4),
      initialSegments: [
        TextSegment(
          text: "@John",
          attributes: {
            "mention": {"id": "1"},
          },
        ),
      ],
      expectedText: "",
      expectedOffset: 0,
      expectedMentionCount: 0,
    ),
    TestCase(
      description: 'Gõ ký tự trùng với ký tự đầu của mention',
      cacheText: "@James",
      cacheSelection: const TextSelection.collapsed(offset: 0),
      newText: "@@James",
      newSelection: const TextSelection.collapsed(offset: 1),
      initialSegments: [
        TextSegment(
          text: "@James",
          attributes: {
            "mention": {"id": "2"},
          },
        ),
      ],
      expectedText: "@@James",
      expectedOffset: 1,
      expectedMentionCount: 1,
    ),
    TestCase(
      description: 'Gõ ký tự vào GIỮA mention -> Phá vỡ thực thể',
      cacheText: "@James",
      cacheSelection: const TextSelection.collapsed(offset: 3),
      newText: "@Ja1mes",
      newSelection: const TextSelection.collapsed(offset: 4),
      initialSegments: [
        TextSegment(
          text: "@James",
          attributes: {
            "mention": {"id": "2"},
          },
        ),
      ],
      expectedText: "@Ja1mes",
      expectedOffset: 4,
      expectedMentionCount: 0,
    ),
    TestCase(
      description: 'Gõ ký tự vào CUỐI mention',
      cacheText: "@James",
      cacheSelection: const TextSelection.collapsed(offset: 6),
      newText: "@James!",
      newSelection: const TextSelection.collapsed(offset: 7),
      initialSegments: [
        TextSegment(
          text: "@James",
          attributes: {
            "mention": {"id": "2"},
          },
        ),
      ],
      expectedText: "@James!",
      expectedOffset: 7,
      expectedMentionCount: 1,
    ),
  ]);

  runTests('Link Replacement', [
    TestCase(
      description: 'Tự động thay thế URL khi dán',
      cacheText: "Check this ",
      cacheSelection: const TextSelection.collapsed(offset: 11),
      newText: "Check this https://flutter.dev",
      newSelection: const TextSelection.collapsed(offset: 30),
      expectedText: "Check this See link",
      expectedOffset: 19,
      expectedMentionCount: 1,
    ),
  ]);

  runTests('IME & Multi-byte Characters Support', [
    TestCase(
      description: 'Japanese IME: Typing Hiragana (composing)',
      cacheText: "こんにちは ",
      cacheSelection: const TextSelection.collapsed(offset: 6),
      newText: "こんにちは わたし",
      newSelection: const TextSelection.collapsed(offset: 9),
      composing: const TextRange(start: 6, end: 9),
      expectedText: "こんにちは わたし",
      expectedOffset: 9,
      expectedComposing: const TextRange(start: 6, end: 9),
      expectedMentionCount: 0,
    ),
    TestCase(
      description: 'IME: Composing range shift after link replacement',
      cacheText: "See ",
      cacheSelection: const TextSelection.collapsed(offset: 4),
      newText: "See https://flutter.dev",
      newSelection: const TextSelection.collapsed(offset: 23),
      composing: const TextRange(start: 23, end: 23), // Composition starting right after URL
      expectedText: "See See link",
      expectedOffset: 12,
      expectedComposing: const TextRange(start: 12, end: 12), // Shifted by -11
      expectedMentionCount: 1,
    ),
    TestCase(
      description: 'IME: Composing range shift after atomic deletion',
      cacheText: "Hello @James ",
      cacheSelection: const TextSelection.collapsed(offset: 12), // end of '@James'
      newText: "Hello @Jame ",
      newSelection: const TextSelection.collapsed(offset: 11),
      composing: const TextRange(start: 12, end: 12), // Composition at the end
      initialSegments: [
        TextSegment(text: "Hello "),
        TextSegment(text: "@James", attributes: {"mention": {"id": "1"}}),
        TextSegment(text: " ")
      ],
      expectedText: "Hello  ", // '@James' removed (6 chars)
      expectedOffset: 7, // selection clamped to end of "Hello  "
      expectedComposing: const TextRange(start: 7, end: 7), // 12 - 5 = 7
      expectedMentionCount: 0,
    ),
    TestCase(
      description: 'Chinese IME: Finalizing composition',
      cacheText: "Ni hao ",
      cacheSelection: const TextSelection.collapsed(offset: 7),
      newText: "Ni hao 你好",
      newSelection: const TextSelection.collapsed(offset: 9),
      composing: TextRange.empty, // composition finalized
      expectedText: "Ni hao 你好",
      expectedOffset: 9,
      expectedComposing: TextRange.empty,
      expectedMentionCount: 0,
    ),
    TestCase(
      description: 'Complex Emojis and Mentions Support',
      cacheText: "Hello 👋 @James",
      cacheSelection: const TextSelection.collapsed(offset: 8),
      newText: "Hello 👋 😊 @James",
      newSelection: const TextSelection.collapsed(offset: 11),
      initialSegments: [
        TextSegment(text: "Hello 👋 "),
        TextSegment(text: "@James", attributes: {"mention": {"id": "1"}})
      ],
      expectedText: "Hello 👋 😊 @James",
      expectedOffset: 11,
      expectedMentionCount: 1,
    ),
  ]);
}
