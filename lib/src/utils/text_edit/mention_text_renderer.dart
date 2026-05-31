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
      linkLengthDiff = newStr.length - linkReplacementText.length;
      newStr = linkReplacementText;
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
            continue; // Skip the whole special entity
          } else {
            // Modification inside a special entity -> convert to plain text unless fully replaced by a link
            final updatedText = segment.text.replaceRange(
              relStart,
              relEnd,
              !newStrInserted ? newStr : "",
            );
            if (updatedText.isNotEmpty) {
              newSegments.add(
                TextSegment(
                  text: updatedText,
                  attributes:
                      (linkAttributes != null &&
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
          // Plain text modification: SPLIT the segment if it's a link insertion
          // Add prefix part
          if (relStart > 0) {
            newSegments.add(
              TextSegment(text: segment.text.substring(0, relStart)),
            );
          }
          // Add the replacement string (as a Link segment if attributes exist)
          if (!newStrInserted) {
            newSegments.add(
              TextSegment(text: newStr, attributes: linkAttributes),
            );
            newStrInserted = true;
          }
          // Add suffix part
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
    final String resultPlainText = optimizedSegments
        .map((e) => e.text)
        .join('');

    if (BbCode.getMentionsBbobInText(resultPlainText).isNotEmpty) {
      return _syncFromMarkup(resultPlainText);
    }

    int safeOffset = selection.baseOffset;
    if (linkLengthDiff != 0 &&
        selection.baseOffset >=
            replaceStart + (newStr.length + linkLengthDiff)) {
      safeOffset -= linkLengthDiff;
    }
    safeOffset = safeOffset.clamp(0, resultPlainText.length);

    return MentionTextRendererResult(
      cacheDisplayText: resultPlainText,
      text: resultPlainText,
      selection: TextSelection.collapsed(offset: safeOffset),
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
