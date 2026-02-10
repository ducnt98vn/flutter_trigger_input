import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_trigger_input/src/utils/text_edit/text_diff.dart';

void main() {
  group('TextDiff.execute - Các trường hợp cơ bản', () {
    test('Hai chuỗi giống hệt nhau', () {
      final result = TextDiff.execute(
        leftStr: 'Xin chào',
        rightStr: 'Xin chào',
      );
      expect(result.leftStr.displayStr, '');
      expect(result.rightStr.displayStr, 'Xin chào');
    });

    test('Chuỗi cũ rỗng (Thêm mới toàn bộ)', () {
      final result = TextDiff.execute(leftStr: '', rightStr: 'Chào');
      expect(result.leftStr.displayStr, '');
      expect(result.rightStr.displayStr, 'Chào');
      expect(result.rightStr.start, 0);
      expect(result.rightStr.end, 4);
    });

    test('Chuỗi mới rỗng (Xóa toàn bộ)', () {
      final result = TextDiff.execute(leftStr: 'Tạm biệt', rightStr: '');
      expect(result.leftStr.displayStr, 'Tạm biệt');
      expect(result.rightStr.displayStr, '');
      expect(result.leftStr.start, 0);
      expect(result.leftStr.end, 8);
    });
  });

  group('TextDiff.execute - Thao tác Thêm (Insert)', () {
    test('Thêm ký tự vào cuối chuỗi', () {
      final result = TextDiff.execute(leftStr: 'Flutter', rightStr: 'Flutter!');
      expect(result.leftStr.displayStr, '');
      expect(result.rightStr.displayStr, '!');
      expect(result.rightStr.start, 7);
    });

    test('Thêm ký tự vào đầu chuỗi', () {
      final result = TextDiff.execute(
        leftStr: 'học code',
        rightStr: 'đang học code',
      );
      // Logic của bạn sẽ tìm điểm khác biệt đầu tiên
      expect(result.rightStr.displayStr, 'đang ');
      expect(result.rightStr.start, 0);
    });

    test('Thêm ký tự vào giữa chuỗi', () {
      final result = TextDiff.execute(
        leftStr: 'Xin bạn',
        rightStr: 'Xin chào bạn',
      );
      expect(result.rightStr.displayStr, 'chào ');
    });
  });

  group('TextDiff.execute - Thao tác Xóa (Delete)', () {
    test('Xóa ký tự ở cuối', () {
      final result = TextDiff.execute(leftStr: 'Dart!', rightStr: 'Dart');
      expect(result.leftStr.displayStr, '!');
      expect(result.rightStr.displayStr, '');
    });

    test('Xóa ký tự ở giữa', () {
      final result = TextDiff.execute(
        leftStr: 'Xin chào Việt Nam',
        rightStr: 'Xin Việt Nam',
      );
      expect(result.leftStr.displayStr, 'chào ');
      expect(result.rightStr.displayStr, '');
    });
  });

  group('TextDiff.execute - Thao tác Thay thế (Replace/Update)', () {
    test('Thay thế một từ ở giữa', () {
      final result = TextDiff.execute(
        leftStr: 'Tôi yêu Java',
        rightStr: 'Tôi yêu Dart',
      );
      expect(result.leftStr.displayStr, 'Java');
      expect(result.rightStr.displayStr, 'Dart');
    });

    test('Dán (Paste) một đoạn văn bản mới đè lên đoạn cũ', () {
      final result = TextDiff.execute(
        leftStr: 'Câu hỏi cũ',
        rightStr: 'Câu trả lời mới',
      );
      // Kết quả mong đợi: Phần khác biệt bắt đầu từ "hỏi cũ" thay bằng "trả lời mới"
      expect(result.leftStr.displayStr, contains('hỏi cũ'));
      expect(result.rightStr.displayStr, contains('trả lời mới'));
    });
  });

  group('TextDiff.execute - Tiếng Việt và Ký tự đặc biệt', () {
    test('Thay đổi dấu tiếng Việt', () {
      final result = TextDiff.execute(leftStr: 'Ăn cơm', rightStr: 'Ẩn cơm');
      expect(result.leftStr.displayStr, 'Ă');
      expect(result.rightStr.displayStr, 'Ẩ');
    });

    test('Thêm emoji hoặc ký tự đặc biệt', () {
      final result = TextDiff.execute(leftStr: 'Hot', rightStr: 'Hot 🔥');
      expect(result.rightStr.displayStr, ' 🔥');
    });
  });

  group('TextDiff.execute - Edge Cases (Trường hợp biên)', () {
    test('Thay đổi xảy ra ở vị trí trùng lặp (vd: thêm "a" vào "aaa")', () {
      final result = TextDiff.execute(leftStr: 'aa', rightStr: 'aaa');
      // Với logic so sánh từ 2 đầu, kết quả thường trả về ký tự cuối hoặc đầu tùy thuật toán
      expect(result.rightStr.displayStr.length, 1);
      expect(result.rightStr.displayStr, 'a');
    });
  });
}
