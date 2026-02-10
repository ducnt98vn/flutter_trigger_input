import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_trigger_input/extensions/string_ext.dart';

void main() {
  group('StringUtils Tests', () {
    test('isNumericOnly: trả về true nếu chỉ có số', () {
      expect('123456'.isNumericOnly, isTrue);
      expect('123a45'.isNumericOnly, isFalse);
      expect(''.isNumericOnly, isFalse);
    });

    test('removeVietnameseAccent: loại bỏ dấu chính xác', () {
      expect('Tiếng Việt'.removeVietnameseAccent(), 'tieng viet');
      expect('Đường Đời'.removeVietnameseAccent(), 'duong doi');
      expect('chữ có dấu huyền'.removeVietnameseAccent(), 'chu co dau huyen');
    });

    test('removeVietnameseAccent: xử lý lỗi (catch error)', () {
      // Vì String trong Dart hiếm khi gây lỗi try-catch khi xử lý text cơ bản,
      // nhưng test này đảm bảo hàm không crash.
      expect('Normal Text'.removeVietnameseAccent(), 'normal text');
    });
  });
}
