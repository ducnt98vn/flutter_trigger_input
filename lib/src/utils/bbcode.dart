import 'package:flutter/foundation.dart';
import 'package:flutter_trigger_input/src/modal/length_map.dart';

class BbCode {
  static String createMentionBbob({String id = '', String name = ''}) {
    return '[mention id="$id" name="$name"][/mention]';
  }

  static String createLinkBbob({String link = ''}) {
    return '[link]$link[/link]';
  }

  static List<LengthMap> getMentionsBbobInText(String source) {
    List<LengthMap> results = [];
    String regex = r'\[mention([^\]]*)\]([\s\S]*?)\[\/mention\]';

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
