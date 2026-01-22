import 'package:flutter/material.dart';
import 'package:flutter_trigger_input/src/modal/suggestion_info.dart';

class Mention<T extends SuggestionInfo> {
  Mention({
    required this.trigger,
    this.data = const [],
    this.style,
    this.markupBuilder,
  });

  final String trigger;

  List<T> data;

  TextStyle? style;

  final String Function(String trigger, String mention, String value)?
      markupBuilder;
}
