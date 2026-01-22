import 'package:flutter_trigger_input/flutter_trigger_input.dart';

class SuggestionEngineResult<T extends SuggestionInfo> {
  final bool showSuggestions;
  final List<T>? suggestionInfos;

  SuggestionEngineResult({required this.showSuggestions, this.suggestionInfos});
}
