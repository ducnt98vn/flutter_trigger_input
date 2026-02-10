import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_trigger_input/src/modal/suggestion_info.dart';

void main() {
  group('SuggestionInfo Tests', () {
    test('Khởi tạo với các giá trị mặc định', () {
      final info = SuggestionInfo(id: 'u1');

      expect(info.id, 'u1');
      expect(info.name, ''); // Mặc định là chuỗi rỗng
      expect(info.score, 0); // Mặc định là 0
    });

    test('Getter suggestionName nên trả về đúng giá trị của name', () {
      final info = SuggestionInfo(id: 'u1', name: 'Gemini');
      expect(info.suggestionName, 'Gemini');
    });

    group('JSON Serialization (với snake_case config)', () {
      test('fromJson nên chuyển đổi đúng từ Map', () {
        final json = {'id': '123', 'name': 'Dart Learner', 'score': 99};

        final info = SuggestionInfo.fromJson(json);

        expect(info.id, '123');
        expect(info.name, 'Dart Learner');
        expect(info.score, 99);
      });

      test('toJson nên tạo ra Map chính xác', () {
        final info = SuggestionInfo(id: '456', name: 'Flutter Dev', score: 100);

        final json = info.toJson();

        expect(json['id'], '456');
        expect(json['name'], 'Flutter Dev');
        expect(json['score'], 100);
      });
    });
  });
}
