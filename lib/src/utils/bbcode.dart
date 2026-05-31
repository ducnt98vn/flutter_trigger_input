import 'package:flutter/foundation.dart';
import 'package:flutter_trigger_input/src/modal/length_map.dart';

class BbCode {
  /// Tạo chuỗi BBCode cho mention/trigger.
  /// Thêm thuộc tính `trigger` để phân biệt @, #, v.v. khi parse ngược.
  static String createMentionBbob({
    String trigger = '@',
    String id = '',
    String name = '',
  }) {
    return '[mention trigger="$trigger" id="$id" name="$name"][/mention]';
  }

  static String createLinkBbob({String link = ''}) {
    return '[link]$link[/link]';
  }

  static List<LengthMap> getMentionsBbobInText(String source) {
    List<LengthMap> results = [];
    // Regex linh hoạt: nhận diện mọi cặp thẻ [tag]...[/tag]
    String regex = r'\[([^\]\s=]+)([^\]]*)\]([\s\S]*?)\[\/\1\]';

    RegExp regExp = RegExp(regex, caseSensitive: false, multiLine: false);

    try {
      Iterable<Match> matches = regExp.allMatches(source);

      for (final Match m in matches) {
        results.add(
          LengthMap(start: m.start, end: m.end, displayStr: m[0] ?? ''),
        );
      }

      return results;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return results;
  }
}
