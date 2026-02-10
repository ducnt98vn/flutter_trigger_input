import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_trigger_input/flutter_trigger_input.dart';
import 'package:flutter_trigger_input/src/modal/suggestion_engine_result.dart';

// Tạo một class giả lập kế thừa từ SuggestionInfo để test tính Generic
class MockSuggestion extends SuggestionInfo {
  MockSuggestion({required super.id, required super.name});
}

void main() {
  group('SuggestionEngineResult Tests', () {
    test('Nên khởi tạo đúng với showSuggestions = false và danh sách rỗng', () {
      final result = SuggestionEngineResult(showSuggestions: false);

      expect(result.showSuggestions, isFalse);
      expect(result.suggestionInfos, isNull);
    });

    test('Nên chứa danh sách các đối tượng Generic đúng kiểu', () {
      final mockList = [
        MockSuggestion(id: '1', name: 'Gợi ý 1'),
        MockSuggestion(id: '2', name: 'Gợi ý 2'),
      ];

      final result = SuggestionEngineResult<MockSuggestion>(
        showSuggestions: true,
        suggestionInfos: mockList,
      );

      expect(result.showSuggestions, isTrue);
      expect(result.suggestionInfos?.length, 2);
      expect(result.suggestionInfos?[0].name, 'Gợi ý 1');
      // Kiểm tra tính Generic: đối tượng phải là instance của MockSuggestion
      expect(result.suggestionInfos?[0], isA<MockSuggestion>());
    });

    test('Nên cho phép suggestionInfos là null khi showSuggestions là true', () {
      // Trường hợp này có thể xảy ra khi đang load dữ liệu nhưng vẫn muốn hiện khung menu rỗng/loading
      final result = SuggestionEngineResult(
        showSuggestions: true,
        suggestionInfos: null,
      );

      expect(result.showSuggestions, isTrue);
      expect(result.suggestionInfos, isNull);
    });
  });
}
