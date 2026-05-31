import 'package:flutter_trigger_input/flutter_trigger_input.dart';

class SuggestionListener {
  LengthMap? execute({
    required TFController tfController,
    List<String> triggerSymbols = const ['@', '#'],
    bool allowSpace = false,
  }) {
    final text = tfController.text;
    final selection = tfController.selection;
    if (!selection.isCollapsed) return null;

    final cursorIndex = selection.baseOffset.clamp(0, text.length);
    final textUntilCursor = text.substring(0, cursorIndex);

    // Tạo pattern cho các trigger symbols
    // Cần cẩn thận khi dùng trong [] (character class)
    final String triggerCharsForClass = triggerSymbols
        .map((s) {
          if (s == ']' || s == '\\' || s == '^' || s == '-') {
            return '\\$s';
          }
          return s;
        })
        .join('');

    final triggersPattern = triggerSymbols.map(RegExp.escape).join('|');

    // Logic cho phần keyword:
    // Nếu allowSpace = true: Lấy mọi thứ trừ các trigger hoặc xuống dòng.
    // Nếu allowSpace = false: Chỉ lấy các ký tự word, dots, underscores.
    final keywordPattern = allowSpace
        ? '[^$triggerCharsForClass\\n]*'
        : r'[\w._]*';

    // Pattern hoàn chỉnh: (khoảng trắng hoặc đầu dòng) (trigger) (keyword)
    final regex = RegExp('(\\s|^)($triggersPattern)($keywordPattern)\$');
    final match = regex.firstMatch(textUntilCursor);

    if (match != null) {
      final prefix = match.group(1) ?? '';
      final trigger = match.group(2) ?? '';
      final keyword = match.group(3) ?? '';

      final start = match.start + prefix.length;

      return LengthMap(
        start: start,
        end: cursorIndex,
        displayStr: '$trigger$keyword',
      );
    }

    return null;
  }
}
