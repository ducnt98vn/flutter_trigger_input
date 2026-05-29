import 'package:flutter_trigger_input/flutter_trigger_input.dart';
import 'package:flutter_trigger_input/src/modal/length_map.dart';

class SuggestionListener {
  LengthMap? execute({
    required TFController tfController,
    List<String> triggerSymbols = const ['@'],
    bool allowSpace = false,
  }) {
    final cursorPos = tfController.selection.baseOffset;
    final currentText = tfController.value.text;

    if (currentText.isEmpty ||
        !tfController.selection.isCollapsed ||
        cursorPos == 0) {
      return null;
    }

    int? triggerPos;

    // Optimization: Use string indexing instead of runes.elementAt for O(N) performance
    for (var i = cursorPos - 1; i >= 0; i--) {
      final char = currentText[i];
      if (triggerSymbols.contains(char)) {
        triggerPos = i;
        break;
      }
      // Stop if we hit a space and allowSpace is false
      if (!allowSpace && char.trim().isEmpty) {
        break;
      }

      // Always stop at newline
      if (char == '\n') {
        break;
      }
    }

    if (triggerPos == null) {
      return null;
    }

    // Check if the trigger position is inside an existing mention
    bool isInsideExistingMention(int index) {
      return tfController.mentionedStrs.any(
        (m) => index >= m.start && index < m.end,
      );
    }

    if (isInsideExistingMention(triggerPos)) {
      return null;
    }

    return LengthMap(
      start: triggerPos,
      end: cursorPos,
      displayStr: currentText.substring(triggerPos, cursorPos),
    );
  }
}
