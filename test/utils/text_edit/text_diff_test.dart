import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_trigger_input/src/utils/text_edit/text_diff.dart';

class TextDiffTestCase {
  final String description;
  final String leftStr;
  final String rightStr;
  final String expectedLeftDisplay;
  final String expectedRightDisplay;
  final int? expectedRightStart;

  TextDiffTestCase({
    required this.description,
    required this.leftStr,
    required this.rightStr,
    required this.expectedLeftDisplay,
    required this.expectedRightDisplay,
    this.expectedRightStart,
  });
}

void main() {
  void runTests(String groupName, List<TextDiffTestCase> cases) {
    group(groupName, () {
      for (var tc in cases) {
        test(tc.description, () {
          final result = TextDiff.execute(leftStr: tc.leftStr, rightStr: tc.rightStr);
          expect(result.leftStr.displayStr, tc.expectedLeftDisplay, reason: 'Left display mismatch');
          expect(result.rightStr.displayStr, tc.expectedRightDisplay, reason: 'Right display mismatch');
          if (tc.expectedRightStart != null) {
            expect(result.rightStr.start, tc.expectedRightStart, reason: 'Right start mismatch');
          }
        });
      }
    });
  }

  runTests('Cơ bản', [
    TextDiffTestCase(
      description: 'Hai chuỗi giống hệt nhau',
      leftStr: 'Xin chào',
      rightStr: 'Xin chào',
      expectedLeftDisplay: '',
      expectedRightDisplay: 'Xin chào',
    ),
    TextDiffTestCase(
      description: 'Chuỗi cũ rỗng',
      leftStr: '',
      rightStr: 'Chào',
      expectedLeftDisplay: '',
      expectedRightDisplay: 'Chào',
      expectedRightStart: 0,
    ),
    TextDiffTestCase(
      description: 'Chuỗi mới rỗng',
      leftStr: 'Tạm biệt',
      rightStr: '',
      expectedLeftDisplay: 'Tạm biệt',
      expectedRightDisplay: '',
    ),
  ]);

  runTests('Thêm (Insert)', [
    TextDiffTestCase(
      description: 'Thêm vào cuối',
      leftStr: 'Flutter',
      rightStr: 'Flutter!',
      expectedLeftDisplay: '',
      expectedRightDisplay: '!',
      expectedRightStart: 7,
    ),
    TextDiffTestCase(
      description: 'Thêm vào đầu',
      leftStr: 'học code',
      rightStr: 'đang học code',
      expectedLeftDisplay: '',
      expectedRightDisplay: 'đang ',
      expectedRightStart: 0,
    ),
    TextDiffTestCase(
      description: 'Thêm vào giữa',
      leftStr: 'Xin bạn',
      rightStr: 'Xin chào bạn',
      expectedLeftDisplay: '',
      expectedRightDisplay: 'chào ',
    ),
  ]);

  runTests('Xóa (Delete)', [
    TextDiffTestCase(
      description: 'Xóa ở cuối',
      leftStr: 'Dart!',
      rightStr: 'Dart',
      expectedLeftDisplay: '!',
      expectedRightDisplay: '',
    ),
    TextDiffTestCase(
      description: 'Xóa ở giữa',
      leftStr: 'Xin chào Việt Nam',
      rightStr: 'Xin Việt Nam',
      expectedLeftDisplay: 'chào ',
      expectedRightDisplay: '',
    ),
  ]);

  runTests('Thay thế (Replace)', [
    TextDiffTestCase(
      description: 'Thay thế từ ở giữa',
      leftStr: 'Tôi yêu Java',
      rightStr: 'Tôi yêu Dart',
      expectedLeftDisplay: 'Java',
      expectedRightDisplay: 'Dart',
    ),
    TextDiffTestCase(
      description: 'Thay đổi dấu tiếng Việt',
      leftStr: 'Ăn cơm',
      rightStr: 'Ẩn cơm',
      expectedLeftDisplay: 'Ă',
      expectedRightDisplay: 'Ẩ',
    ),
  ]);
}
