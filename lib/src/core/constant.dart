import 'package:flutter_trigger_input/flutter_trigger_input.dart';

class Constant {
  Constant._();

  static const validTags = {'link', 'mention'};
}

class BbcodeTags {
  BbcodeTags._();

  static const link = {'link'};
  static const mention = {'mention'};
}

typedef SuggestionExecuteCallback<T extends SuggestionInfo> =
    void Function(String trigger, String keyword);
