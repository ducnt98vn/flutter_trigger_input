import 'package:flutter/material.dart';
import 'package:flutter_trigger_input/src/modal/text_segment.dart';
import 'package:flutter_trigger_input/src/modal/mention.dart';
import 'package:flutter_trigger_input/src/modal/length_map.dart';

class TFController extends TextEditingController {
  List<TextSegment> _segments = [TextSegment(text: '')];
  Map<String, Mention> _triggerConfigs = {};

  List<TextSegment> get segments => _segments;

  /// Cập nhật segments mà không gây ra notifyListeners()
  set segmentsInternal(List<TextSegment> newSegments) {
    _segments = newSegments;
  }

  set triggerConfigs(List<Mention> configs) {
    _triggerConfigs = {for (var c in configs) c.trigger: c};
  }

  List<LengthMap> get mentionedStrs {
    final List<LengthMap> results = [];
    int currentOffset = 0;
    for (var segment in _segments) {
      if (!segment.isPlain) {
        final Map<String, dynamic>? mentionAttr =
            segment.attributes?['mention'] as Map<String, dynamic>?;
        final String trigger =
            (mentionAttr?['trigger'] as String?) ??
            (segment.text.isNotEmpty ? segment.text[0] : '@');
        final String id = (mentionAttr?['id'] as String?) ?? '';
        final String name =
            (mentionAttr?['name'] as String?) ??
            segment.text.replaceFirst(trigger, '');

        results.add(
          LengthMap(
            start: currentOffset,
            end: currentOffset + segment.text.length,
            displayStr: segment.text,
            originStr:
                '[mention trigger="$trigger" id="$id" name="$name"][/mention]',
          ),
        );
      }
      currentOffset += segment.text.length;
    }
    return results;
  }

  void replaceRange(int start, int end, String newText) {
    _applyReplacement(start, end, [TextSegment(text: newText)]);
  }

  void replaceRangeWithSegment(int start, int end, TextSegment newSegment) {
    _applyReplacement(start, end, [newSegment]);
  }

  void replaceRangeWithSegments(
    int start,
    int end,
    List<TextSegment> newSegmentsList,
  ) {
    _applyReplacement(start, end, newSegmentsList);
  }

  void _applyReplacement(
    int start,
    int end,
    List<TextSegment> newSegmentsList,
  ) {
    final List<TextSegment> nextSegments = [];
    int currentOffset = 0;
    bool replaced = false;

    for (var segment in _segments) {
      final int segmentStart = currentOffset;
      final int segmentEnd = currentOffset + segment.text.length;
      currentOffset = segmentEnd;

      if (replaced || start > segmentEnd || end < segmentStart) {
        nextSegments.add(segment);
      } else if (start >= segmentStart && end <= segmentEnd) {
        if (start > segmentStart) {
          nextSegments.add(
            TextSegment(
              text: segment.text.substring(0, start - segmentStart),
              attributes: segment.attributes,
            ),
          );
        }

        nextSegments.addAll(newSegmentsList);
        replaced = true;

        if (end < segmentEnd) {
          nextSegments.add(
            TextSegment(
              text: segment.text.substring(end - segmentStart),
              attributes: segment.attributes,
            ),
          );
        }
      } else {
        nextSegments.add(segment);
      }
    }

    if (!replaced) {
      nextSegments.addAll(newSegmentsList);
    }

    _segments = _optimizeSegments(nextSegments);

    final fullText = _segments.map((e) => e.text).join('');
    final totalAddedLength = newSegmentsList.fold(
      0,
      (sum, s) => sum + s.text.length,
    );
    final newOffset = (start + totalAddedLength).clamp(0, fullText.length);

    value = TextEditingValue(
      text: fullText,
      selection: TextSelection.collapsed(offset: newOffset),
    );
  }

  List<TextSegment> _optimizeSegments(List<TextSegment> segments) {
    if (segments.isEmpty) return [TextSegment(text: '')];
    final List<TextSegment> result = [];
    for (var s in segments) {
      if (result.isNotEmpty && result.last.isPlain && s.isPlain) {
        result.last.text += s.text;
      } else if (s.text.isNotEmpty || !s.isPlain) {
        // Chỉ thêm segment nếu nó có nội dung hoặc có thuộc tính (metadata)
        result.add(s);
      }
    }
    // Đảm bảo luôn có ít nhất 1 segment rỗng để tránh lỗi TextField
    return result.isEmpty ? [TextSegment(text: '')] : result;
  }

  /// Trả về chuỗi JSON đại diện cho nội dung (Kiến trúc Delta)
  String get markupText {
    // Lọc bỏ các phân đoạn rỗng hoàn toàn trước khi xuất dữ liệu
    final validSegments = _segments
        .where((s) => s.text.isNotEmpty || !s.isPlain)
        .toList();

    if (validSegments.isEmpty) return '[]';

    return validSegments.map((s) => s.toJson()).toList().toString();
  }

  @override
  TextSpan buildTextSpan({
    BuildContext? context,
    TextStyle? style,
    bool? withComposing,
  }) {
    final children = <InlineSpan>[];
    int currentOffset = 0;

    for (final segment in _segments) {
      final int segmentStart = currentOffset;
      final int segmentEnd = currentOffset + segment.text.length;
      currentOffset = segmentEnd;

      TextStyle? segmentStyle = style;

      if (segment.isMention || segment.isHashtag) {
        final trigger = segment.text.isNotEmpty ? segment.text[0] : '';
        segmentStyle =
            _triggerConfigs[trigger]?.style ??
            style?.copyWith(color: Colors.blue, fontWeight: FontWeight.bold);
      } else if (segment.isLink) {
        segmentStyle = style?.copyWith(
          color: Colors.blue,
          decoration: TextDecoration.underline,
        );
      }

      final bool isOverlapping =
          selection.isValid &&
          !selection.isCollapsed &&
          segmentStart < selection.end &&
          segmentEnd > selection.start;

      if (isOverlapping && (segment.isMention || segment.isHashtag)) {
        final int relSelStart = (selection.start - segmentStart).clamp(
          0,
          segment.text.length,
        );
        final int relSelEnd = (selection.end - segmentStart).clamp(
          0,
          segment.text.length,
        );

        if (relSelStart > 0) {
          children.add(
            TextSpan(
              text: segment.text.substring(0, relSelStart),
              style: segmentStyle,
            ),
          );
        }

        children.add(
          TextSpan(
            text: segment.text.substring(relSelStart, relSelEnd),
            style: segmentStyle?.copyWith(backgroundColor: Colors.transparent),
          ),
        );

        if (relSelEnd < segment.text.length) {
          children.add(
            TextSpan(
              text: segment.text.substring(relSelEnd),
              style: segmentStyle,
            ),
          );
        }
      } else {
        children.add(TextSpan(text: segment.text, style: segmentStyle));
      }
    }

    return TextSpan(style: style, children: children);
  }
}
