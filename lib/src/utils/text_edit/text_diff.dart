import 'dart:math';

import 'package:flutter_trigger_input/src/modal/length_map.dart';
import 'package:flutter_trigger_input/src/modal/text_diff_result.dart';

class TextDiff {
  static TextDiffResult execute({
    required String leftStr,
    required String rightStr,
  }) {
    try {
      // DiffMatchPatch dmp = new DiffMatchPatch();
      // List<Diff> d = dmp.diff('Hello World.', 'Goodbye World.');

      // dmp.diffCleanupSemantic(d);
      // // Result: [(-1, "Hello"), (1, "Goodbye"), (0, " World.")]
      // print(d);

      // 2 chuỗi bằng nhau không có thay đổi gì
      // có TH chuỗi được dán giống chuỗi đầu
      if (leftStr == rightStr) {
        return TextDiffResult(
          leftStr: LengthMap(start: 0, end: 0, displayStr: ''),
          rightStr: LengthMap(start: 0, end: 0, displayStr: rightStr),
        );
      }

      // TH có 1 chuỗi rỗng
      if (leftStr.isEmpty) {
        return TextDiffResult(
          leftStr: LengthMap(start: 0, end: 0, displayStr: ''),
          rightStr: LengthMap(
            start: 0,
            end: rightStr.length,
            displayStr: rightStr,
          ),
        );
      }

      if (rightStr.isEmpty) {
        return TextDiffResult(
          leftStr: LengthMap(
            start: 0,
            end: leftStr.length,
            displayStr: leftStr,
          ),
          rightStr: LengthMap(start: 0, end: 0, displayStr: ''),
        );
      }

      final int minLength = min(leftStr.length, rightStr.length);
      final int maxLength = max(leftStr.length, rightStr.length);

      LengthMap repLeftStr = LengthMap(start: -1, end: -1, displayStr: '');
      LengthMap repRightStr = LengthMap(start: -1, end: -1, displayStr: '');

      for (int i = 0; i < minLength; i++) {
        if (leftStr[i] != rightStr[i]) {
          repLeftStr
            ..start = i
            ..end = i;
          repRightStr
            ..start = i
            ..end = i;
          break;
        }
      }

      if (repLeftStr.start == -1 && repRightStr.start == -1) {
        repLeftStr
          ..start = minLength
          ..end = leftStr.length == minLength ? minLength : maxLength;
        repRightStr
          ..start = minLength
          ..end = rightStr.length == minLength ? minLength : maxLength;
      }

      for (
        int iLeftStr = leftStr.length - 1, iRightStr = rightStr.length - 1;
        iLeftStr >= repLeftStr.start && iRightStr >= repRightStr.start;
        iLeftStr--, iRightStr--
      ) {
        if (iLeftStr == repLeftStr.start || iRightStr == repRightStr.start) {
          if (minLength == maxLength) {
            repLeftStr.end = iLeftStr + 1;
            repRightStr.end = iRightStr + 1;
          } else {
            repLeftStr.end = iLeftStr;
            repRightStr.end = iRightStr;
          }
          break;
        }
        if (leftStr[iLeftStr] != rightStr[iRightStr]) {
          repLeftStr.end = iLeftStr + 1;
          repRightStr.end = iRightStr + 1;
          break;
        }
      }

      repLeftStr.displayStr = leftStr.substring(
        repLeftStr.start,
        repLeftStr.end,
      );
      repRightStr.displayStr = rightStr.substring(
        repRightStr.start,
        repRightStr.end,
      );

      return TextDiffResult(leftStr: repLeftStr, rightStr: repRightStr);
    } catch (e) {
      return TextDiffResult(
        leftStr: LengthMap(start: 0, end: leftStr.length, displayStr: leftStr),
        rightStr: LengthMap(
          start: 0,
          end: rightStr.length,
          displayStr: rightStr,
        ),
      );
    }
  }
}
