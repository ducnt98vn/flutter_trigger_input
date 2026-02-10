import 'package:flutter_trigger_input/flutter_trigger_input.dart';
import 'package:flutter_trigger_input/src/modal/suggestion_engine_result.dart';
import 'package:flutter_trigger_input/extensions/string_ext.dart';

class SuggestionEngine {
  SuggestionEngineResult<T> execute<T extends SuggestionInfo>({
    required TFController tfTextInputController,
    String id = '',
    required List<T> canMentions,
    required List<T> suggestionInfos,
    String trigger = '',
    String keyword = '',
  }) {
    List<T> tempSuggestionInfos = suggestionInfos;

    final cursorPos = tfTextInputController.selection.baseOffset;

    final triggerPos = cursorPos - keyword.length;

    bool allowShowSuggest =
        triggerPos <= 0 ||
        tfTextInputController.mentionedStrs.indexWhere(
              (mentionedStr) =>
                  mentionedStr.start < triggerPos &&
                  triggerPos <= mentionedStr.end,
            ) ==
            -1;

    if (trigger == '@' && allowShowSuggest) {
      final trimedKeyword = keyword.trim().toLowerCase();

      tempSuggestionInfos.clear();

      if (canMentions.isEmpty ||
          (keyword.isNotEmpty &&
              (trimedKeyword.isEmpty || ['\n'].contains(keyword[0])))) {
        return SuggestionEngineResult(
          suggestionInfos: tempSuggestionInfos,
          showSuggestions: true,
        );
      }

      final cloneSuggestionInfoList = [...canMentions];
      cloneSuggestionInfoList.removeAt(0);
      List<T> newSuggestionInfoList = [];

      if (trimedKeyword.isEmpty) {
        newSuggestionInfoList = cloneSuggestionInfoList
            .where((member) => member.id != id)
            .toList();
      } else {
        newSuggestionInfoList = cloneSuggestionInfoList
            .where(
              (member) =>
                  member.id != id &&
                  _checkSearchMemberInfo(
                    query: trimedKeyword,
                    suggestionInfo: member,
                  ),
            )
            .toList();
      }

      List<T> listSetMention = [];

      for (var current in newSuggestionInfoList) {
        if (listSetMention.indexWhere((item) => item.id == current.id) < 0) {
          current.name = current.suggestionName.removeVietnameseAccent();
          listSetMention.add(current);
        }
      }

      List<T> scoreListMention = [];
      if (trimedKeyword.isEmpty) {
        scoreListMention = [...listSetMention];
      } else {
        String cleanQuery = trimedKeyword.removeVietnameseAccent();
        for (var member in listSetMention) {
          final arrInfo = member.name.split(' ');
          String firstName = '';
          String midName = '';
          String lastName = '';

          if (arrInfo.length == 1) {
            firstName = arrInfo.first;
            lastName = arrInfo.last;
          } else if (arrInfo.length == 2) {
            firstName = arrInfo[1];
            lastName = arrInfo.first;
          } else {
            firstName = arrInfo[arrInfo.length - 1];
            lastName = arrInfo.first;
            midName = arrInfo.sublist(1, arrInfo.length - 1).join(' ');
          }

          int score = 0;

          final arrQuery = cleanQuery.split(' ');

          for (var i in arrQuery) {
            if (firstName.contains(i)) {
              score += 10000;
              if (firstName.removeVietnameseAccent() == cleanQuery) {
                score += 10000;
              }
            }
            if (midName.contains(i)) {
              score += 500;
              if (midName.removeVietnameseAccent() == cleanQuery) {
                score += 200;
              }
            }
            if (lastName.contains(i)) {
              score += 100;
              if (lastName.removeVietnameseAccent() == cleanQuery) {
                score += 100;
              }
            }
          }

          member.score = score;

          scoreListMention.add(member);
        }
      }

      scoreListMention.sort((a, b) => b.score - a.score);

      if (scoreListMention.isEmpty) {
        scoreListMention.clear();
        tempSuggestionInfos.clear();
      } else {
        tempSuggestionInfos = [...scoreListMention];
      }

      final find = tfTextInputController.mentionedStrs.indexWhere(
        (mentionedStr) =>
            mentionedStr.start > cursorPos && mentionedStr.end < cursorPos,
      );

      final findStr = tfTextInputController.mentionedStrs.indexWhere(
        (mentionedStr) =>
            mentionedStr.displayStr.toLowerCase() ==
            '$trigger${trimedKeyword.toLowerCase()}',
      );

      return SuggestionEngineResult(
        suggestionInfos: tempSuggestionInfos,
        showSuggestions:
            tfTextInputController.mentionedStrs.isEmpty || trimedKeyword.isEmpty
            ? true
            : find == -1 && findStr == -1,
      );
    } else {
      return SuggestionEngineResult(
        suggestionInfos: tempSuggestionInfos,
        showSuggestions: false,
      );
    }
  }

  bool _checkSearchMemberInfo<T extends SuggestionInfo>({
    String query = '',
    T? suggestionInfo,
  }) {
    List<String> listInfo = [];

    if (suggestionInfo == null) {
      return false;
    }

    if (suggestionInfo.suggestionName.isNotEmpty) {
      listInfo.add(suggestionInfo.suggestionName);
    }

    return listInfo
        .join(' - ')
        .removeVietnameseAccent()
        .toLowerCase()
        .contains(query.toLowerCase().removeVietnameseAccent());
  }
}
