import 'package:flutter/material.dart';
import 'package:flutter_trigger_input/src/modal/mention.dart';
import 'package:flutter_trigger_input/src/modal/length_map.dart';
import 'package:flutter_trigger_input/src/utils/bbcode.dart';
import 'package:flutter_trigger_input/extensions/list_ext.dart';

class TFController extends TextEditingController {
  TextStyle baseEntityTextStyle = const TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    backgroundColor: Colors.pinkAccent,
  );
  Map<String, Mention> _triggerConfigs = {};

  List<LengthMap> mentionedStrs = [];

  set triggerConfigs(List<Mention> configs) {
    _triggerConfigs = {for (var c in configs) c.trigger: c};
  }

  TFController();

  /// Can be used to get the markup from the controller directly.
  String get markupText {
    try {
      StringBuffer someVal = StringBuffer('');
      if (mentionedStrs.isEmpty) {
        someVal.write(text);
      } else {
        int tempSelection = 0;

        for (var mention in mentionedStrs) {
          someVal.write(text.substring(tempSelection, mention.start));
          someVal.write(mention.originStr);

          tempSelection = mention.end;
        }

        someVal.write(text.substring(tempSelection, text.length));
      }

      return someVal.toString();
    } catch (e) {
      return text;
    }
  }

  void addMention({
    required int cursorPos,
    required String cacheText,
    required LengthMap cacheStr,
    required LengthMap mentionStr,
    void Function()? beforeUpdateValue,
    bool appendSpaceOnAdd = true,
  }) {
    try {
      String resultText = cacheText;
      List<LengthMap> tempMentions = mentionedStrs;
      int difference =
          mentionStr.displayStr.length +
          (appendSpaceOnAdd ? 1 : 0) -
          cacheStr.displayStr.length;

      if (tempMentions.isEmpty || cursorPos >= tempMentions.last.end) {
        tempMentions.add(mentionStr);
      } else {
        /// 3 TH:
        /// nằm trước mention
        /// nằm sau mention
        /// nằm giữa mention
        for (int index = 0; index < tempMentions.length; index++) {
          final currentMention = tempMentions[index];
          final previousMention = tempMentions.tryGet(index - 1);

          if (cursorPos <= currentMention.start) {
            if (previousMention != null) {
              tempMentions[index]
                ..start = tempMentions[index].start + difference
                ..end = tempMentions[index].end + difference;

              if (cursorPos > previousMention.end) {
                tempMentions.insert(index, mentionStr);
                index++;
              }
            } else {
              tempMentions[index]
                ..start = tempMentions[index].start + difference
                ..end = tempMentions[index].end + difference;

              tempMentions.insert(index, mentionStr);
              index++;
            }
          }
        }
      }

      resultText = resultText.replaceRange(
        cacheStr.start,
        cacheStr.end,
        mentionStr.displayStr + (appendSpaceOnAdd ? ' ' : ''),
      );

      mentionedStrs = tempMentions;

      value = TextEditingValue(
        text: resultText,
        selection: TextSelection.collapsed(
          offset: mentionStr.end + (appendSpaceOnAdd ? 1 : 0),
        ),
      );
      /**
       * Rebuild để xử lý trường hợp văn bản không thay đổi
       * nhưng có cập nhật danh sách mentionedStrs.
       */
      if (resultText == cacheText) notifyListeners();
    } catch (e) {
      value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: cursorPos),
      );
    }
  }

  @override
  TextSpan buildTextSpan({
    BuildContext? context,
    TextStyle? style,
    bool? withComposing,
  }) {
    if (mentionedStrs.isEmpty) return TextSpan(style: style, text: text);

    String markupResult = text;

    try {
      var children = <InlineSpan>[];

      int tempSelection = 0;

      for (LengthMap entity in mentionedStrs) {
        children.add(
          TextSpan(
            text: markupResult.substring(tempSelection, entity.start),
            style: style,
          ),
        );

        children.add(
          TextSpan(
            text: markupResult.substring(entity.start, entity.end),
            style: _triggerConfigs.containsKey(entity.trigger)
                ? _triggerConfigs[entity.trigger]?.style
                : style?.merge(baseEntityTextStyle),
          ),
        );

        tempSelection = entity.end;
      }

      children.add(
        TextSpan(
          text: markupResult.substring(tempSelection, markupResult.length),
          style: style,
        ),
      );

      return TextSpan(style: style, children: children);
    } catch (e) {
      return TextSpan(style: style, text: text);
    }
  }
}
