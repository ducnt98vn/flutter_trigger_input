import 'package:flutter_trigger_input/flutter_trigger_input.dart';
import 'package:flutter_trigger_input/src/modal/length_map.dart';

class SuggestionListener {
  LengthMap? execute({
    required TFController tfController,
    List<String> triggerSymbols = const ['@'],
  }) {
    final cursorPos = tfController.selection.baseOffset;
    final currentText = tfController.value.text;

    if (currentText.isEmpty ||
        !tfController.selection.isCollapsed ||
        cursorPos == 0) {
      return null;
    }

    int? triggerPos;

    final runes = tfController.value.text.runes;
    for (var i = cursorPos - 1; i >= 0; i--) {
      if (i < runes.length) {
        final rune = runes.elementAt(i);
        String currentCharacter = String.fromCharCode(rune);
        if (triggerSymbols.contains(currentCharacter)) {
          triggerPos = i;
          break;
        }
        // Stop if we hit a space - triggers usually don't contain spaces
        if (currentCharacter.trim().isEmpty) {
          break;
        }
      }
    }

    if (triggerPos == null) {
      return null;
    }

    // Kiểm tra xem vị trí trigger hoặc con trỏ có nằm trong một mention đã tồn tại không
    bool isInsideExistingMention(int index) {
      return tfController.mentionedStrs.any(
        (m) => index > m.start && index < m.end,
      );
    }

    if (isInsideExistingMention(triggerPos) || isInsideExistingMention(cursorPos)) {
      return null;
    }

    return LengthMap(
      start: triggerPos,
      end: cursorPos,
      displayStr: currentText.substring(triggerPos, cursorPos),
    );
  }
}
