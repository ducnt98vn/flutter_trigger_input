import 'package:flutter/material.dart';
import 'package:flutter_trigger_input/src/modal/length_map.dart';

class MentionTextRendererResult {
  final String cacheDisplayText;
  final TextSelection selection;
  final List<LengthMap> mentionedStrs;
  final String? text;

  MentionTextRendererResult({
    required this.cacheDisplayText,
    required this.selection,
    required this.mentionedStrs,
    this.text,
  });
}
