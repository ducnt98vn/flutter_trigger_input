import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_trigger_input/src/modal/length_map.dart';

void main() {
  group('LengthMap Tests', () {
    test('Khởi tạo đối tượng với các giá trị mặc định', () {
      final map = LengthMap(start: 0, end: 5, displayStr: '@James');

      expect(map.start, 0);
      expect(map.end, 5);
      expect(map.displayStr, '@James');
      expect(map.originStr, ''); // Kiểm tra giá trị mặc định
    });

    group('Getter trigger', () {
      test('Nên trả về ký tự đầu tiên của displayStr', () {
        final map = LengthMap(start: 0, end: 1, displayStr: '#Flutter');
        expect(map.trigger, '#');
      });

      test(
        'Nên báo lỗi hoặc trả về chuỗi rỗng nếu displayStr trống (Edge case)',
        () {
          final map = LengthMap(start: 0, end: 0, displayStr: '');

          // Lưu ý: substring(0, 1) trên chuỗi rỗng sẽ gây lỗi RangeError
          // Test này giúp bạn nhận ra có nên handle lỗi này trong code chính không
          expect(() => map.trigger, throwsRangeError);
        },
      );
    });

    group('JSON Serialization', () {
      test('fromJson nên tạo đối tượng đúng từ Map (snake_case)', () {
        final json = {
          'start': 10,
          'end': 20,
          'display_str': '@Alice', // Kiểm tra FieldRename.snake
          'origin_str': 'Alice Smith',
        };

        final map = LengthMap.fromJson(json);

        expect(map.start, 10);
        expect(map.displayStr, '@Alice');
        expect(map.originStr, 'Alice Smith');
      });

      test('toJson nên trả về Map đúng định dạng snake_case', () {
        final map = LengthMap(
          start: 5,
          end: 15,
          displayStr: '@Bob',
          originStr: 'Robert',
        );

        final json = map.toJson();

        expect(json['start'], 5);
        expect(json['display_str'], '@Bob');
        expect(json['origin_str'], 'Robert');
      });
    });
  });
}
