import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_trigger_input/src/modal/length_map.dart';
import 'package:flutter_trigger_input/src/modal/text_diff_result.dart';

void main() {
  group('TextDiffResult Tests', () {
    // Khởi tạo dữ liệu mẫu
    final left = LengthMap(start: 0, end: 5, displayStr: '@James');
    final right = LengthMap(start: 0, end: 4, displayStr: '@Jim');

    test('Khởi tạo đối tượng thành công', () {
      final diff = TextDiffResult(leftStr: left, rightStr: right);

      expect(diff.leftStr.displayStr, '@James');
      expect(diff.rightStr.displayStr, '@Jim');
    });

    group('JSON Serialization', () {
      test('fromJson nên tạo đối tượng đúng với dữ liệu lồng nhau', () {
        final json = {
          'left_str': {'start': 0, 'end': 6, 'display_str': '@Flutter'},
          'right_str': {'start': 0, 'end': 4, 'display_str': '@Dart'},
        };

        final diff = TextDiffResult.fromJson(json);

        expect(diff.leftStr.displayStr, '@Flutter');
        expect(diff.rightStr.displayStr, '@Dart');
        expect(diff.leftStr.end, 6);
      });

      test('toJson nên trả về Map lồng nhau (explicit_to_json)', () {
        final diff = TextDiffResult(leftStr: left, rightStr: right);
        final json = diff.toJson();

        // Kiểm tra field name đã được chuyển sang snake_case theo config của bạn
        expect(json.containsKey('left_str'), isTrue);
        expect(json.containsKey('right_str'), isTrue);

        // Kiểm tra giá trị bên trong: Vì explicit_to_json: true,
        // giá trị phải là Map chứ không phải Instance của LengthMap
        expect(json['left_str']['display_str'], '@James');
        expect(json['right_str']['display_str'], '@Jim');
        expect(json['left_str']['start'], 0);
      });
    });
  });
}
