import 'package:flutter_trigger_input/src/modal/suggestion_engine_result.dart';

extension SuggestionEngineResultExt on SuggestionEngineResult {
  bool get hasData => suggestionInfos != null && suggestionInfos!.isNotEmpty;
}
