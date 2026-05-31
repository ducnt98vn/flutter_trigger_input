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
  final List<TextSegment> initialSegments;
  final String expectedText;
  final int expectedOffset;
  final int expectedMentionCount;

  TestCase({
    required this.description,
    required this.cacheText,
    required this.cacheSelection,
    required this.newText,
    required this.newSelection,
    this.initialSegments = const [],
    required this.expectedText,
    required this.expectedOffset,
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

          tfController.text = tc.newText;
          tfController.selection = tc.newSelection;

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
}
