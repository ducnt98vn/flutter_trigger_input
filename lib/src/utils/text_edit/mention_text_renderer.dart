import 'package:flutter/material.dart' hide Text, Element;
import 'package:flutter_trigger_input/flutter_trigger_input.dart';
import 'package:flutter_trigger_input/src/modal/mention_text_renderer_result.dart';
import 'package:flutter_trigger_input/src/utils/bbcode.dart';
import 'package:flutter_trigger_input/src/utils/bbob_dart/lib/bbob_dart.dart';
import 'text_diff.dart';

class MentionTextRenderer {
  MentionTextRendererResult execute({
    required String cacheDisplayText,
    required TFController tfController,
    required TextSelection cacheSelection,
    bool enableLinkReplacement = true,
    String linkReplacementText = 'See link',
    bool appendSpaceOnReplace = false,
  }) {
    final text = tfController.text;
    final selection = tfController.selection;

    if (text == cacheDisplayText) {
      return MentionTextRendererResult(
        cacheDisplayText: text,
        selection: selection,
        mentionedStrs: [],
        segments: tfController.segments,
      );
    }

    final diff = TextDiff.execute(leftStr: cacheDisplayText, rightStr: text);
    int replaceStart = diff.leftStr.start;
    int replaceEnd = diff.leftStr.end;
    String newStr = diff.rightStr.displayStr;

    // Tự động nhận diện URL khi dán/nhập (Link Replacement)
    final urlRegex = RegExp(r'^https?://\S+$');
    Map<String, dynamic>? linkAttributes;
    int linkLengthDiff = 0;

    if (enableLinkReplacement &&
        newStr.length > 5 &&
        urlRegex.hasMatch(newStr.trim())) {
      linkAttributes = {
        'link': {'url': newStr.trim()},
      };

      String replacementWithSuffix = linkReplacementText;
      if (appendSpaceOnReplace) {
        replacementWithSuffix += ' ';
      }

      linkLengthDiff = newStr.length - replacementWithSuffix.length;
      newStr = replacementWithSuffix;
    }

    // Sliding logic for ambiguous insertions
    if (replaceStart == replaceEnd &&
        newStr.isNotEmpty &&
        linkAttributes == null) {
      while (replaceStart > 0 &&
          cacheDisplayText[replaceStart - 1] == newStr[newStr.length - 1]) {
        newStr =
            newStr[newStr.length - 1] + newStr.substring(0, newStr.length - 1);
        replaceStart--;
        replaceEnd--;
      }
    }

    final List<TextSegment> oldSegments = tfController.segments;
    final List<TextSegment> newSegments = [];

    int currentOffset = 0;
    bool newStrInserted = false;
    int extraDeletionOffset = 0;

    if (oldSegments.isEmpty ||
        (oldSegments.length == 1 && oldSegments.first.text.isEmpty)) {
      newSegments.add(TextSegment(text: newStr, attributes: linkAttributes));
      newStrInserted = true;
    } else {
      for (var segment in oldSegments) {
        final int segmentStart = currentOffset;
        final int segmentEnd = currentOffset + segment.text.length;
        currentOffset = segmentEnd;

        // 1. Replacement is entirely AFTER this segment
        if (replaceStart >= segmentEnd) {
          newSegments.add(segment);
          continue;
        }

        // 2. Replacement is entirely BEFORE this segment
        if (replaceEnd <= segmentStart) {
          if (!newStrInserted) {
            newSegments.add(
              TextSegment(text: newStr, attributes: linkAttributes),
            );
            newStrInserted = true;
          }
          newSegments.add(segment);
          continue;
        }

        // 3. Replacement overlaps with this segment
        final int relStart = (replaceStart - segmentStart).clamp(
          0,
          segment.text.length,
        );
        final int relEnd = (replaceEnd - segmentStart).clamp(
          0,
          segment.text.length,
        );

        if (!segment.isPlain) {
          // Atomic Deletion logic
          if (newStr.isEmpty && (replaceEnd - replaceStart) > 0) {
            // Nếu xóa bất kỳ phần nào của một thực thể đặc biệt, ta xóa sạch cả thực thể đó.
            // Để con trỏ không bị nhảy, ta cần tính toán xem đã xóa thêm bao nhiêu ký tự
            // so với những gì Framework nghĩ (những ký tự nằm trước replaceStart).
            if (replaceStart > segmentStart) {
              extraDeletionOffset += (replaceStart - segmentStart);
            }
            continue; // Bỏ qua toàn bộ segment này
          } else {
            // Thay đổi nội dung bên trong thực thể -> biến thành văn bản thường
            final updatedText = segment.text.replaceRange(
              relStart,
              relEnd,
              !newStrInserted ? newStr : "",
            );
            if (updatedText.isNotEmpty) {
              newSegments.add(
                TextSegment(
                  text: updatedText,
                  attributes: (linkAttributes != null &&
                          !newStrInserted &&
                          updatedText == newStr)
                      ? linkAttributes
                      : null,
                ),
              );
            }
            if (!newStrInserted) newStrInserted = true;
          }
        } else {
          // Xử lý văn bản thường: Chia nhỏ segment nếu chèn vào giữa
          if (relStart > 0) {
            newSegments.add(
              TextSegment(text: segment.text.substring(0, relStart)),
            );
          }
          if (!newStrInserted) {
            newSegments.add(
              TextSegment(text: newStr, attributes: linkAttributes),
            );
            newStrInserted = true;
          }
          if (relEnd < segment.text.length) {
            newSegments.add(TextSegment(text: segment.text.substring(relEnd)));
          }
        }
      }
    }

    if (!newStrInserted && newStr.isNotEmpty) {
      newSegments.add(TextSegment(text: newStr, attributes: linkAttributes));
    }

    final optimizedSegments = _optimizeSegments(newSegments);
    final String resultPlainText =
        optimizedSegments.map((e) => e.text).join('');

    if (BbCode.getMentionsBbobInText(resultPlainText).isNotEmpty) {
      return _syncFromMarkup(resultPlainText);
    }

    // --- LOGIC XỬ LÝ IME (composing) ---
    TextRange safeComposing = tfController.value.composing;
    if (safeComposing.isValid) {
      int diffLength = resultPlainText.length - text.length;
      if (diffLength != 0 && safeComposing.start >= replaceStart) {
        safeComposing = TextRange(
          start: (safeComposing.start + diffLength)
              .clamp(0, resultPlainText.length),
          end:
              (safeComposing.end + diffLength).clamp(0, resultPlainText.length),
        );
      }
    }

    // --- LOGIC XỬ LÝ SELECTION ---
    int safeOffset = selection.baseOffset;

    // Điều chỉnh cho link replacement (URL dài thành "See link" ngắn)
    if (linkLengthDiff != 0 &&
        selection.baseOffset >=
            replaceStart + (newStr.length + linkLengthDiff)) {
      safeOffset -= linkLengthDiff;
    }

    // Điều chỉnh cho xóa nguyên tử (Xóa cả block thay vì 1 ký tự)
    if (extraDeletionOffset != 0) {
      safeOffset -= extraDeletionOffset;
    }

    safeOffset = safeOffset.clamp(0, resultPlainText.length);

    // Sử dụng fromPosition để bảo toàn thuộc tính affinity (hướng con trỏ)
    final safeSelection = TextSelection.fromPosition(
      TextPosition(offset: safeOffset, affinity: selection.affinity),
    );

    return MentionTextRendererResult(
      cacheDisplayText: resultPlainText,
      text: resultPlainText,
      selection: safeSelection,
      composing: safeComposing,
      mentionedStrs: [],
      segments: optimizedSegments,
    );
  }

  MentionTextRendererResult _syncFromMarkup(String markupText) {
    final nodes = parse(
      markupText,
      onError: (msg) {},
      openTag: '[',
      closeTag: ']',
      enableEscapeTags: false,
      validTags: null,
    );

    final List<TextSegment> segments = [];
    final plainTextBuffer = StringBuffer();

    for (final node in nodes) {
      if (node is Text) {
        segments.add(TextSegment(text: node.text));
        plainTextBuffer.write(node.text);
      } else if (node is Element) {
        if (node.attributes.containsKey('id') &&
            node.attributes.containsKey('name')) {
          final name = node.attributes['name'] ?? '';
          final trigger = node.attributes['trigger'] ?? '@';
          final displayStr = '$trigger$name';

          segments.add(
            TextSegment(
              text: displayStr,
              attributes: {
                'mention': {
                  'id': node.attributes['id'],
                  'name': name,
                  'trigger': trigger,
                },
              },
            ),
          );
          plainTextBuffer.write(displayStr);
        } else {
          segments.add(TextSegment(text: node.textContent));
          plainTextBuffer.write(node.textContent);
        }
      }
    }

    final optimized = _optimizeSegments(segments);
    final finalPlainText = plainTextBuffer.toString();

    return MentionTextRendererResult(
      cacheDisplayText: finalPlainText,
      text: finalPlainText,
      selection: TextSelection.collapsed(offset: finalPlainText.length),
      mentionedStrs: [],
      segments: optimized,
    );
  }

  List<TextSegment> _optimizeSegments(List<TextSegment> segments) {
    if (segments.isEmpty) return [TextSegment(text: '')];
    final List<TextSegment> result = [];
    for (var s in segments) {
      if (result.isNotEmpty && result.last.isPlain && s.isPlain) {
        result.last.text += s.text;
      } else if (s.text.isNotEmpty || !s.isPlain) {
        result.add(s);
      }
    }
    return result.isEmpty ? [TextSegment(text: '')] : result;
  }
}
