import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_trigger_input/extensions/suggestion_ext.dart';
import 'package:flutter_trigger_input/src/modal/suggestion_engine_result.dart';
import 'package:flutter_trigger_input/src/modal/suggestion_info.dart';

void main() {
  group('SuggestionEngineResultExt Tests', () {
    test('hasData: trả về đúng trạng thái dữ liệu', () {
      final resEmpty = SuggestionEngineResult<SuggestionInfo>(
        showSuggestions: true,
        suggestionInfos: [],
      );

      final resNull = SuggestionEngineResult<SuggestionInfo>(
        showSuggestions: true,
        suggestionInfos: null,
      );

      expect(resEmpty.hasData, isFalse);
      expect(resNull.hasData, isFalse);
    });
  });
}
