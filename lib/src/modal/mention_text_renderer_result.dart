import 'package:flutter/material.dart';
import 'package:flutter_trigger_input/src/modal/length_map.dart';
import 'package:flutter_trigger_input/src/modal/text_segment.dart';

class MentionTextRendererResult {
  final String cacheDisplayText;
  final TextSelection selection;
  final TextRange composing;
  final List<LengthMap> mentionedStrs;
  final String? text;
  final List<TextSegment>? segments;

  MentionTextRendererResult({
    required this.cacheDisplayText,
    required this.selection,
    this.composing = TextRange.empty,
    required this.mentionedStrs,
    this.text,
    this.segments,
  });
}
