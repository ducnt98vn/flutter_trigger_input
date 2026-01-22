import 'package:flutter/material.dart' hide Text, Element;
import 'package:flutter_trigger_input/flutter_trigger_input.dart';
import 'package:flutter_trigger_input/src/modal/length_map.dart';
import 'package:flutter_trigger_input/src/modal/mention_text_renderer_result.dart';
import 'package:flutter_trigger_input/src/utils/bbcode.dart';
import 'package:flutter_trigger_input/src/utils/bbob_dart/lib/bbob_dart.dart';

import 'text_diff.dart';

class MentionTextRenderer {
  MentionTextRendererResult execute({
    required String cacheDisplayText,
    required TFController tfController,
    required TextSelection cacheSelection,
  }) {
    final currentText = tfController.text;
    final currentSelection = tfController.selection;
    try {
      String resultText = currentText;

      if (!cacheSelection.isValid || !currentSelection.isValid) {
        cacheSelection = currentSelection;

        return MentionTextRendererResult(
          cacheDisplayText: currentText,
          selection: currentSelection,
        );
      }

      if (currentText.isEmpty) {
        return MentionTextRendererResult(
          cacheDisplayText: '',
          mentionedStrs: [],
          selection: currentSelection,
        );
      }

      if (currentText != cacheDisplayText) {
        String cacheStr = '', newStr = '';
        int difference = 0,
            replaceStart = cacheSelection.start,
            replaceEnd = cacheSelection.end;
        TextSelection tempSelection = currentSelection;
        List<LengthMap> tempMentions = tfController.mentionedStrs;

        /**
         * TH: Logic to delete or replace one or more characters in the text field.
         */
        if (currentText.length < cacheDisplayText.length) {
          if (cacheSelection.isCollapsed) {
            replaceStart = currentSelection.baseOffset;
            replaceEnd = cacheSelection.extentOffset;
          } else {
            replaceStart = cacheSelection.baseOffset;
            replaceEnd = cacheSelection.extentOffset;
          }
          if (cacheSelection.baseOffset < currentSelection.extentOffset) {
            newStr = currentText.substring(
              cacheSelection.baseOffset,
              currentSelection.extentOffset,
            );
          }
        } else if (currentText.length > cacheDisplayText.length) {
          if (!cacheSelection.isCollapsed) {
            replaceStart = cacheSelection.baseOffset;
            replaceEnd = cacheSelection.extentOffset;
          }

          // newStr = currentText.substring(
          //   cacheSelection.baseOffset,
          //   currentSelection.extentOffset,
          // );

          /**
           * TH: Nhập ngôn ngữ tiếng việt.
           *
           * Ta có văn bản lúc đầu là "làm"
           * Step:
           *  1. Nhập "f" => văn bản sẽ thành "làmf"
           *
           * Case đúng: "lamf"
           */

          if (cacheSelection.isCollapsed && currentSelection.isCollapsed) {
            /**
             * Kiểm tra từ mới nhập có rỗng hay không
             * 1. Có => Bỏ qua.
             * 2. Không => cắt từ đó ra để lấy vị trí thay đổi của từ đó
             * Vd làm => lamf
             */
            if (currentText
                .substring(
                  cacheSelection.baseOffset,
                  currentSelection.extentOffset,
                )
                .trim()
                .isNotEmpty) {
              String cacheEditedWord = '';
              String newEditedWord = '';

              for (var i = cacheSelection.start - 1; i >= 0; i--) {
                if (cacheDisplayText[i].trim().isEmpty) {
                  cacheEditedWord = cacheDisplayText.substring(
                    i,
                    cacheSelection.end,
                  );
                  newEditedWord = currentText.substring(
                    i,
                    currentSelection.end,
                  );
                  replaceStart = i;
                  break;
                }

                /**
                 * TH: Checks if the trigger/text is at the start of a sentence.
                 */
                if (i == 0) {
                  cacheEditedWord = cacheDisplayText.substring(
                    0,
                    cacheSelection.end,
                  );
                  newEditedWord = currentText.substring(
                    0,
                    currentSelection.end,
                  );
                  replaceStart = i;
                }
              }

              /**
               * Scans from the start of the current word to locate diacritic/mark changes.
               */
              for (int i = 0; i < cacheEditedWord.length; i++) {
                if (cacheEditedWord[i] != newEditedWord[i]) {
                  replaceStart = replaceStart + i;
                  break;
                }

                if (i == cacheEditedWord.length - 1) {
                  replaceStart = replaceStart + cacheEditedWord.length;
                }
              }
            }

            replaceEnd = cacheSelection.end;
            cacheStr = cacheDisplayText.substring(
              replaceStart,
              cacheSelection.extentOffset,
            );
            newStr = currentText.substring(
              replaceStart,
              currentSelection.extentOffset,
            );
          } else {
            newStr = currentText.substring(
              cacheSelection.baseOffset,
              currentSelection.extentOffset,
            );
          }
        } else {
          replaceEnd = cacheSelection.extentOffset;

          /**
           * TH: Nhập ngôn ngữ tiếng việt.
           *
           * Ta có văn bản lúc đầu là "e"
           * Step:
           *  1. Nhập "e" => văn bản sẽ thành "ê"
           *  2. Vị trí con trỏ không thay đổi.
           *  3. Cắt sai ký tự thay đổi.
           *
           * Note: Các ngôn ngữ khác (Trung, Nhật, Ấn Độ,...) chưa kiểm tra =))) 👍
           */
          if (currentSelection.isCollapsed &&
              cacheSelection.isCollapsed &&
              cacheSelection.start == currentSelection.start) {
            final result = TextDiff.execute(
              leftStr: cacheDisplayText,
              rightStr: currentText,
            );

            replaceStart = result.leftStr.start;

            newStr = currentText.substring(
              replaceStart,
              currentSelection.extentOffset,
            );
          } else {
            replaceStart = cacheSelection.baseOffset;

            newStr = currentText.substring(
              cacheSelection.baseOffset,
              currentSelection.extentOffset,
            );
          }
        }

        cacheStr = cacheDisplayText.substring(replaceStart, replaceEnd);
        difference = newStr.length - cacheStr.length;

        for (int index = 0; index < tempMentions.length; index++) {
          final mention = tempMentions[index];

          if (replaceStart >= mention.end) continue;

          if (replaceStart < mention.start && replaceEnd > mention.start) {
            // if (replaceEnd < mention.end) {
            //   difference -= mention.end - replaceEnd;
            //   replaceEnd = mention.end;
            // }

            tempMentions.removeAt(index);
            index--;
            continue;
          }

          if (replaceStart > mention.start && replaceStart < mention.end ||
              replaceStart == mention.start && replaceEnd > mention.start) {
            // difference -= replaceStart - mention.start;
            // replaceStart = mention.start;

            // if (replaceEnd > mention.start && replaceEnd < mention.end) {
            //   difference -= mention.end - replaceEnd;
            //   replaceEnd = mention.end;
            // }

            tempMentions.removeAt(index);
            index--;
            continue;
          }

          if (replaceEnd <= mention.start) {
            tempMentions[index]
              ..start = tempMentions[index].start + difference
              ..end = tempMentions[index].end + difference;
          }
        }

        tempSelection = TextSelection.collapsed(
          offset: replaceStart + newStr.length,
        );

        resultText = cacheDisplayText.replaceRange(
          replaceStart,
          replaceEnd,
          newStr,
        );

        List<LengthMap> mentions = BbCode.getMentionsBbobInText(resultText);

        if (mentions.isNotEmpty) {
          String markupText = tfController.markupText;

          final dataArr = parse(
            markupText,
            onError: (msg) {},
            openTag: '[',
            closeTag: ']',
            enableEscapeTags: false,
            validTags: {'link', 'mention'},
          );

          markupText = '';

          tempMentions.clear();

          for (int i = 0; i < dataArr.length; i++) {
            final word = dataArr[i];

            if (word is Text) {
              markupText += word.text;
            } else if (word is Element) {
              if (word.tag == 'link') {
                markupText += word.textContent;
              } else if (word.tag == 'mention') {
                String name = word.attributes['name'] ?? '';
                String id = word.attributes['id'] ?? '';

                final text = '@$name';

                tempMentions.add(
                  LengthMap(
                    start: markupText.length,
                    end: markupText.length + text.length,
                    displayStr: text,
                    originStr: BbCode.createMentionBbob(id: id, name: name),
                  ),
                );

                markupText += text;
                markupText += word.textContent;
              } else {
                markupText += word.textContent;
              }
            }
          }

          resultText = markupText;
          tempSelection = TextSelection.collapsed(offset: resultText.length);
        }

        cacheSelection = tempSelection;

        return MentionTextRendererResult(
          cacheDisplayText: resultText,
          text: resultText,
          selection: tempSelection,
          mentionedStrs: tempMentions,
        );
      }

      return MentionTextRendererResult(
        cacheDisplayText: resultText,
        selection: currentSelection,
      );
    } catch (e) {
      debugPrint(e.toString());

      // rethrow;
      return MentionTextRendererResult(
        cacheDisplayText: currentText,
        selection: currentSelection,
        mentionedStrs: [],
      );
    }
  }
}
