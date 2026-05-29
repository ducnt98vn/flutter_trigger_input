import 'package:flutter/material.dart' hide Text, Element;
import 'package:flutter_trigger_input/flutter_trigger_input.dart';
import 'package:flutter_trigger_input/src/modal/length_map.dart';
import 'package:flutter_trigger_input/src/modal/mention_text_renderer_result.dart';
import 'package:flutter_trigger_input/src/utils/bbcode.dart';
import 'package:flutter_trigger_input/src/utils/bbob_dart/lib/bbob_dart.dart';

import 'text_diff.dart';

class MentionTextRenderer {
  MentionTextRendererResult execute({
    required String cacheDisplayText,
    required TFController tfController,
    required TextSelection cacheSelection,
  }) {
    final TextEditingValue(:text, :selection) = tfController.value;

    if (!selection.isValid || !cacheSelection.isValid) {
      return MentionTextRendererResult(
        cacheDisplayText: text,
        selection: selection,
        mentionedStrs: tfController.mentionedStrs,
      );
    }

    if (text.isEmpty) {
      return MentionTextRendererResult(
        cacheDisplayText: '',
        mentionedStrs: [],
        selection: selection,
      );
    }

    if (text == cacheDisplayText) {
      return MentionTextRendererResult(
        cacheDisplayText: text,
        selection: selection,
        mentionedStrs: tfController.mentionedStrs,
      );
    }

    try {
      // Thuật toán dựa trên việc xác định: Thay thế vùng (replaceStart, replaceEnd) bằng chuỗi mới (newStr)
      int replaceStart;
      int replaceEnd;
      String newStr;

      final cacheLen = cacheDisplayText.length;
      final textLen = text.length;

      if (!cacheSelection.isCollapsed) {
        // 1. Trường hợp có vùng chọn (Selection): Thay thế vùng chọn bằng văn bản mới (hoặc rỗng nếu xoá)
        replaceStart = cacheSelection.start;
        replaceEnd = cacheSelection.end;
        newStr = text.substring(
          replaceStart,
          selection.end.clamp(replaceStart, textLen),
        );
      } else if (textLen > cacheLen) {
        // 2. Trường hợp Thêm (Insertion) tại con trỏ
        replaceStart = cacheSelection.start;
        replaceEnd = cacheSelection.start;

        // Xử lý bộ gõ tiếng Việt hoặc nhập liệu phức tạp (ví dụ: 'a' + 's' -> 'á')
        final typedPortion = text.substring(
          cacheSelection.start,
          selection.end,
        );
        if (typedPortion.trim().isNotEmpty) {
          // Tìm ranh giới từ để xác định chính xác phần nào trong từ đã thay đổi
          final wordStart = _findWordStart(
            cacheDisplayText,
            cacheSelection.start,
          );
          final diff = TextDiff.execute(
            leftStr: cacheDisplayText.substring(wordStart, cacheSelection.end),
            rightStr: text.substring(wordStart, selection.end),
          );
          replaceStart = wordStart + diff.leftStr.start;
          replaceEnd = wordStart + diff.leftStr.end;
          newStr = diff.rightStr.displayStr;
        } else {
          newStr = typedPortion;
        }
      } else if (textLen < cacheLen) {
        // 3. Trường hợp Xoá (Deletion) tại con trỏ
        if (selection.start < cacheSelection.start) {
          // Backspace (Xoá lùi)
          replaceStart = selection.start;
          replaceEnd = cacheSelection.start;
          newStr = "";
        } else {
          // Forward Delete (Xoá tiến - phím Del)
          replaceStart = cacheSelection.start;
          replaceEnd = cacheSelection.start + (cacheLen - textLen);
          newStr = "";
        }
      } else {
        // 4. Trường hợp Thay thế (Replacement) cùng độ dài (ví dụ: thay đổi dấu mà không di chuyển con trỏ)
        final diff = TextDiff.execute(
          leftStr: cacheDisplayText,
          rightStr: text,
        );
        replaceStart = diff.leftStr.start;
        replaceEnd = diff.leftStr.end;
        newStr = diff.rightStr.displayStr;
      }

      // Đảm bảo chỉ số nằm trong phạm vi an toàn
      replaceStart = replaceStart.clamp(0, cacheLen);
      replaceEnd = replaceEnd.clamp(replaceStart, cacheLen);

      // Cập nhật Mentions dựa trên phép thay thế
      final List<LengthMap> tempMentions = tfController.mentionedStrs
          .map(
            (m) => LengthMap(
              start: m.start,
              end: m.end,
              displayStr: m.displayStr,
              originStr: m.originStr,
            ),
          )
          .toList();
      int difference = newStr.length - (replaceEnd - replaceStart);

      for (int i = 0; i < tempMentions.length; i++) {
        final mention = tempMentions[i];

        // Phép thay thế nằm hoàn toàn sau mention -> Không ảnh hưởng
        if (replaceStart >= mention.end) continue;

        // Phép thay thế nằm hoàn toàn trước mention -> Dịch chuyển mention
        if (replaceEnd <= mention.start) {
          mention.start += difference;
          mention.end += difference;
          continue;
        }

        // Phép thay thế đè lên mention (Overlap)
        // Bổ sung logic "Atomic Entity Deletion": Nếu xoá một phần mention, tự động xoá toàn bộ
        if (newStr.isEmpty &&
            (replaceStart > mention.start ||
                (replaceStart == mention.start &&
                    replaceEnd > mention.start))) {
          final int mentionLen = mention.end - mention.start;
          replaceStart = mention.start;
          replaceEnd = mention.end;
          difference = -mentionLen;
        }

        tempMentions.removeAt(i);
        i--;
      }

      // Tạo văn bản kết quả
      final resultText = cacheDisplayText.replaceRange(
        replaceStart,
        replaceEnd,
        newStr,
      );

      // Nếu văn bản kết quả khớp với controller, tin tưởng selection của controller (IME)
      final resultSelection = (resultText == text)
          ? selection
          : TextSelection.collapsed(offset: replaceStart + newStr.length);

      // Đồng bộ từ markup nếu phát hiện BBCode (thường do paste)
      if (BbCode.getMentionsBbobInText(resultText).isNotEmpty) {
        return _syncFromMarkup(resultText);
      }

      return MentionTextRendererResult(
        cacheDisplayText: resultText,
        text: resultText,
        selection: resultSelection,
        mentionedStrs: tempMentions,
      );
    } catch (e) {
      debugPrint('MentionTextRenderer error: $e');
      return MentionTextRendererResult(
        cacheDisplayText: text,
        selection: selection,
        mentionedStrs: tfController.mentionedStrs,
      );
    }
  }

  int _findWordStart(String text, int cursor) {
    for (int i = cursor - 1; i >= 0; i--) {
      if (text[i].trim().isEmpty) return i + 1;
    }
    return 0;
  }

  MentionTextRendererResult _syncFromMarkup(String markupText) {
    final nodes = parse(
      markupText,
      onError: (msg) {},
      openTag: '[',
      closeTag: ']',
      enableEscapeTags: false,
      validTags: {'link', 'mention'},
    );

    final plainTextBuffer = StringBuffer();
    final List<LengthMap> mentions = [];

    for (final node in nodes) {
      if (node is Text) {
        plainTextBuffer.write(node.text);
      } else if (node is Element) {
        if (node.tag == 'mention') {
          final name = node.attributes['name'] ?? '';
          final id = node.attributes['id'] ?? '';
          final trigger = node.attributes['trigger'] ?? '@';
          final displayStr = '$trigger$name';

          mentions.add(
            LengthMap(
              start: plainTextBuffer.length,
              end: plainTextBuffer.length + displayStr.length,
              displayStr: displayStr,
              originStr: BbCode.createMentionBbob(
                trigger: trigger,
                id: id,
                name: name,
              ),
            ),
          );

          plainTextBuffer.write(displayStr);
        } else if (node.tag == 'link') {
          final displayStr = node.textContent;
          plainTextBuffer.write(displayStr);
        } else {
          plainTextBuffer.write(node.textContent);
        }
      }
    }

    final resultText = plainTextBuffer.toString();
    return MentionTextRendererResult(
      cacheDisplayText: resultText,
      text: resultText,
      selection: TextSelection.collapsed(offset: resultText.length),
      mentionedStrs: mentions,
    );
  }
}
