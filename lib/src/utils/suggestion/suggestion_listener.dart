import 'package:flutter_trigger_input/flutter_trigger_input.dart';
import 'package:flutter_trigger_input/src/modal/length_map.dart';

class SuggestionListener {
  LengthMap? execute({required TFController tfController}) {
    final cursorPos = tfController.selection.baseOffset;
    final currentText = tfController.value.text;

    if (currentText.trim().isEmpty ||
        !tfController.selection.isCollapsed ||
        cursorPos == 0) {
      return null;
    }

    int? atSignPos;

    final runes = tfController.value.text.runes;
    for (var i = cursorPos - 1; i >= 0; i--) {
      if (i < runes.length) {
        final rune = runes.elementAt(i);
        String currentCharacter = String.fromCharCode(rune);
        if (currentCharacter == '@') {
          atSignPos = i;
          break;
        }
      }
    }

    if (atSignPos == null) {
      return null;
    }

    // TODO: chỗ này cần tối ưu
    int mentionedIndex = tfController.mentionedStrs.indexWhere(
      (mentionedStr) =>
          cursorPos > mentionedStr.start && cursorPos < mentionedStr.end,
    );

    mentionedIndex = tfController.mentionedStrs.indexWhere(
      (mentionedStr) =>
          atSignPos! > mentionedStr.start && atSignPos < mentionedStr.end,
    );

    // Hiển thị gợi ý khi con trỏ không nằm trong vị trị có mention
    return mentionedIndex != -1
        ? null
        : LengthMap(
            start: atSignPos,
            end: cursorPos,
            displayStr: currentText.substring(atSignPos, cursorPos),
          );
  }
}
