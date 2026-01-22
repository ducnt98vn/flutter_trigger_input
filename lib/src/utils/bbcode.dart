import 'package:flutter/foundation.dart';
import 'package:flutter_trigger_input/src/core/constant.dart';
import 'package:flutter_trigger_input/src/modal/length_map.dart';
import 'package:flutter_trigger_input/src/utils/bbob_dart/lib/bbob_dart.dart';

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

  static Node extractBbcode(String inputText) {
    try {
      List<dynamic> tagArr = [];

      if (inputText.isEmpty) {
        return Text('');
      }
      try {
        tagArr = parse(
          inputText,
          onError: (msg) {},
          validTags: Constant.validTags,
        );
      } catch (error) {
        return Text(inputText);
      }

      if (tagArr.isEmpty) {
        // error
        return Text(inputText);
      }

      final dynamic firstEle = tagArr[0];

      if (firstEle is Element) {
        final String tagName = firstEle.tag;

        if ({...BbcodeTags.link, ...BbcodeTags.mention}.contains(tagName) ||
            !Constant.validTags.contains(tagName)) {
          return Element('text', {}, covertNormalData(inputText));
        }

        // error
        return Text(inputText);
      }

      return Element('text', {}, covertNormalData(inputText));
    } catch (e) {
      return Text(inputText);
    }
  }

  static List<Node> covertNormalData(String inputText) {
    List<Node> data = [];

    List<Node> dataArr = parse(
      inputText,
      onError: (msg) {
        if (kDebugMode) {
          print(msg);
        }
      },
      openTag: '[',
      closeTag: ']',
      enableEscapeTags: false,
      validTags: {'link', 'mention'},
    );

    for (int i = 0; i < dataArr.length; i++) {
      final word = dataArr[i];

      if (word is Element) {
        if (word.tag == 'link') {
          data.add(word);
        } else if (word.tag == 'mention') {
          data.add(
            Element('mention', {
              'id': word.attributes['id'] ?? '',
              'name': word.attributes['name'] ?? '',
            }, []),
          );
        }
      }
    }

    return data;
  }

  // TODO: IMPROVE
  static String getTextNotBbcode({String? text, List<Node>? nodeList}) {
    final result = StringBuffer('');

    if (text != null) {
      final extractData = BbCode.extractBbcode(text);

      if (extractData is Element && extractData.tag == 'text') {
        result.write(getTextNotBbcode(nodeList: extractData.children));
      }
    } else if (nodeList != null) {
      for (var item in nodeList) {
        if (item is Text) {
          result.write(item.text);
        } else if (item is Element) {
          if (item.tag == 'mention') {
            result.write('@${item.attributes['name']}');
          } else if (item.tag == 'link') {
            result.write(getTextNotBbcode(nodeList: item.children));
          }
        }
      }
    }

    return result.toString();
  }
}
