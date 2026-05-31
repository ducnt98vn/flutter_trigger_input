import 'package:flutter_trigger_input/src/modal/length_map.dart';
import 'package:flutter_trigger_input/src/modal/text_diff_result.dart';

class TextDiff {
  static TextDiffResult execute({
    required String leftStr,
    required String rightStr,
  }) {
    if (leftStr == rightStr) {
      return TextDiffResult(
        leftStr: LengthMap(start: 0, end: 0, displayStr: ''),
        rightStr: LengthMap(start: 0, end: 0, displayStr: ''),
      );
    }

    // Tìm độ dài tiền tố chung (prefix)
    int prefix = 0;
    while (prefix < leftStr.length &&
        prefix < rightStr.length &&
        leftStr[prefix] == rightStr[prefix]) {
      prefix++;
    }

    // Tìm độ dài hậu tố chung (suffix)
    int suffix = 0;
    while (suffix < leftStr.length - prefix &&
        suffix < rightStr.length - prefix &&
        leftStr[leftStr.length - 1 - suffix] ==
            rightStr[rightStr.length - 1 - suffix]) {
      suffix++;
    }

    final replaceStart = prefix;
    final replaceEnd = leftStr.length - suffix;
    final newTextEnd = rightStr.length - suffix;

    return TextDiffResult(
      leftStr: LengthMap(
        start: replaceStart,
        end: replaceEnd,
        displayStr: leftStr.substring(replaceStart, replaceEnd),
      ),
      rightStr: LengthMap(
        start: replaceStart,
        end: newTextEnd,
        displayStr: rightStr.substring(replaceStart, newTextEnd),
      ),
    );
  }
}
