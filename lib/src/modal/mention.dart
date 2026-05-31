import 'package:flutter/material.dart';
import 'package:flutter_trigger_input/src/modal/suggestion_info.dart';

class Mention<T extends SuggestionInfo> {
  Mention({
    required this.trigger,
    this.data = const [],
    this.style,
    this.contextMenuLabel,
    this.onContextMenuPressed,
  });

  final String trigger;

  List<T> data;

  TextStyle? style;

  /// Custom label for the context menu button when this mention is selected.
  final String? contextMenuLabel;

  /// Custom action for the context menu button.
  /// If null, it defaults to copying the JSON markup of the segment to the clipboard.
  final void Function(String markup)? onContextMenuPressed;
}
