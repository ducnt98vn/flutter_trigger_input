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
      // Sử dụng TextDiff để xác định chính xác vùng thay đổi (Surgical replacement)
      final diff = TextDiff.execute(
        leftStr: cacheDisplayText,
        rightStr: text,
      );
      
      int replaceStart = diff.leftStr.start;
      int replaceEnd = diff.leftStr.end;
      String newStr = diff.rightStr.displayStr;

      // Tối ưu hoá: "Trượt" vùng thay đổi về bên trái nếu các ký tự lặp lại (Ambiguous Insertion)
      // Ví dụ: "@James" -> "@@James", diff trả về chèn '@' tại index 1, 
      // ta trượt nó về index 0 để tránh làm hỏng mention bắt đầu từ index 0.
      if (replaceStart == replaceEnd && newStr.isNotEmpty) {
        while (replaceStart > 0 && cacheDisplayText[replaceStart - 1] == newStr[newStr.length - 1]) {
          newStr = newStr[newStr.length - 1] + newStr.substring(0, newStr.length - 1);
          replaceStart--;
          replaceEnd--;
        }
      }

      final cacheLen = cacheDisplayText.length;

      // Đảm bảo chỉ số nằm trong phạm vi an toàn
      replaceStart = replaceStart.clamp(0, cacheLen);
      replaceEnd = replaceEnd.clamp(replaceStart, cacheLen);

      // Deep copy mentions để tránh side-effect
      final List<LengthMap> tempMentions = tfController.mentionedStrs
          .map((m) => LengthMap(
                start: m.start,
                end: m.end,
                displayStr: m.displayStr,
                originStr: m.originStr,
              ))
          .toList();

      // Xác định các mention bị ảnh hưởng bởi phép thay thế
      final affectedMentions = tempMentions.where((m) {
        return replaceStart < m.end && replaceEnd > m.start;
      }).toList();

      // Nếu là thao tác xoá (newStr rỗng) và nằm trong phạm vi của CHỈ MỘT mention
      // thì kích hoạt Atomic Entity Deletion (xoá toàn bộ text của mention đó)
      if (newStr.isEmpty && affectedMentions.length == 1) {
        final mention = affectedMentions.first;
        if (replaceStart > mention.start || (replaceStart == mention.start && replaceEnd > mention.start)) {
          replaceStart = mention.start;
          replaceEnd = mention.end;
        }
      }

      int difference = newStr.length - (replaceEnd - replaceStart);
      
      // Cập nhật danh sách mention: Xoá những cái bị chạm vào, dịch chuyển những cái phía sau
      for (int i = 0; i < tempMentions.length; i++) {
        final mention = tempMentions[i];

        // Nếu mention nằm trong danh sách bị ảnh hưởng -> Xoá metadata
        if (affectedMentions.contains(mention)) {
          tempMentions.removeAt(i);
          i--;
          continue;
        }

        // Nếu phép thay thế nằm hoàn toàn trước mention -> Dịch chuyển mention
        if (replaceEnd <= mention.start) {
          mention.start += difference;
          mention.end += difference;
        }
      }

      // Tạo văn bản kết quả
      final resultText = cacheDisplayText.replaceRange(
        replaceStart,
        replaceEnd,
        newStr,
      );

      // Đồng bộ từ markup nếu phát hiện BBCode (thường do paste)
      if (BbCode.getMentionsBbobInText(resultText).isNotEmpty) {
        return _syncFromMarkup(resultText);
      }

      // Nếu văn bản kết quả khớp với controller, tin tưởng selection của controller (IME)
      final resultSelection = (resultText == text)
          ? selection
          : TextSelection.collapsed(offset: replaceStart + newStr.length);

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
