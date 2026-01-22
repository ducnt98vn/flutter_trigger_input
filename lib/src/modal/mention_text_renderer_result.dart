import 'package:flutter/material.dart';
import 'package:flutter_trigger_input/src/modal/length_map.dart';

class MentionTextRendererResult {
  final String cacheDisplayText;
  final TextSelection selection;
  final String? text;
  final List<LengthMap>? mentionedStrs;

  MentionTextRendererResult({
    required this.cacheDisplayText,
    required this.selection,
    this.text,
    this.mentionedStrs,
  });
}
