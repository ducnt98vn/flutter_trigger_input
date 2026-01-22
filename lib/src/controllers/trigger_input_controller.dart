import 'package:flutter/material.dart' hide Text, Element;
import 'package:flutter_trigger_input/flutter_trigger_input.dart';
import 'package:flutter_trigger_input/src/modal/length_map.dart';
import 'package:flutter_trigger_input/src/utils/bbcode.dart';
import 'package:flutter_trigger_input/src/utils/suggestion/suggestion_engine.dart';
import 'package:flutter_trigger_input/src/utils/suggestion/suggestion_listener.dart';
import 'package:flutter_trigger_input/src/utils/text_edit/mention_text_renderer.dart';

import 'trigger_state.dart';

class TriggerInputController<T extends SuggestionInfo> extends ChangeNotifier {
  final state = TriggerState<T>();
  TFController tfController = TFController();
  MentionTextRenderer mentionTextRenderer = MentionTextRenderer();
  SuggestionListener suggestionListenerC = SuggestionListener();
  SuggestionEngine suggestionEngine = SuggestionEngine();

  void suggestMentionDispose() {
    final TriggerState(
      :suggestionInfos,
      selectedMentionInfos: selectedMentions,
      selectedMentionLengths: selectedMention,
    ) = state;

    selectedMentions.dispose();

    suggestionInfos.dispose();

    selectedMention.dispose();
  }

  void addMention(T value) {
    final TriggerState(
      selectedMentionLengths: selectedMention,
      setSelectedMentionLengths: setSelectedMention,
    ) = state;

    if (selectedMention.value == null) return;

    final cloneText = tfController.value.text;
    final sm = LengthMap.fromJson(selectedMention.value!.toJson());

    setSelectedMention(null);

    // find the text by range and replace with the new value.
    final replaceStart =
        sm.start > cloneText.length ? cloneText.length : sm.start;
    final replaceEnd = sm.end > cloneText.length ? cloneText.length : sm.end;

    final replaceStr = '${'@'}${value.suggestionName}';

    state.cacheDisplayText = cloneText.replaceRange(
      replaceStart,
      replaceEnd,
      '$replaceStr${state.appendSpaceOnAdd ? ' ' : ''}',
    );

    tfController.addMention(
      cursorPos: tfController.selection.baseOffset,
      cacheText: cloneText,
      cacheStr: sm
        ..start = replaceStart
        ..end = replaceEnd,
      mentionStr: LengthMap(
        start: replaceStart,
        end: replaceStart + '${'@'}${value.suggestionName}'.length,
        displayStr: replaceStr,
        originStr: BbCode.createMentionBbob(name: value.name, id: value.id),
      ),
    );
  }

  // TODO: IMPROVE
  void insertEntityAtStart({required T entity}) {
    final TriggerState(selectedMentionInfos: selectedMentions) = state;

    final findIndex = tfController.mentionedStrs.indexWhere(
      (element) =>
          element.originStr ==
          BbCode.createMentionBbob(id: entity.id, name: entity.name),
    );
    if (findIndex > -1) return;

    final cloneText = tfController.value.text;

    String str = '${'@'}${entity.name}';

    selectedMentions.value.add(entity);

    state.cacheDisplayText = cloneText.replaceRange(
      0,
      0,
      '$str${state.appendSpaceOnAdd ? ' ' : ''}',
    );

    tfController.addMention(
      cursorPos: 0,
      cacheText: cloneText,
      cacheStr: LengthMap(start: 0, end: 0, displayStr: ''),
      mentionStr: LengthMap(
        start: 0,
        end: str.length,
        displayStr: str,
        originStr: BbCode.createMentionBbob(id: entity.id, name: entity.name),
      ),
    );
  }

  void onMentionSearchChanged({
    required List<T> canMentions,
    String trigger = '',
    String keyword = '',
  }) {
    final result = suggestionEngine.execute<T>(
      tfTextInputController: tfController,
      canMentions: canMentions,
      suggestionInfos: state.suggestionInfos.value,
      trigger: trigger,
      keyword: keyword,
    );

    state.suggestionInfos.value = result.suggestionInfos ?? [];
    state.showSuggestions.value = result.showSuggestions;

    return;
  }

  void suggestionListener() {
    final TriggerState(:showSuggestions, :setSelectedMentionLengths) = state;

    final result = suggestionListenerC.execute(tfController: tfController);

    showSuggestions.value = result.showSuggestions;
    setSelectedMentionLengths(result.selectedMention);

    return;
  }

  // void addMentionFromText({required List<Node> data}) {
  //   final TriggerState(:setSelectedMentionInfos) = state;

  //   setSelectedMentionInfos([
  //     for (var item in ExtractBbcode.getMentionsListInText(data))
  //       SuggestionInfo(
  //         id: item.attributes['id'] ?? '',
  //         name: item.attributes['name'] ?? '',
  //       ),
  //   ]);

  //   tfController.mentionedStrs = ExtractBbcode.getMentionsInText(data);
  // }

  void renderMentionListener() {
    final result = mentionTextRenderer.execute(
      cacheDisplayText: state.cacheDisplayText,
      tfController: tfController,
      cacheSelection: state.cacheSelection,
    );

    state.cacheSelection = result.selection;
    state.cacheDisplayText = result.cacheDisplayText;

    if (result.mentionedStrs case final mentionedStrs?) {
      tfController.mentionedStrs = mentionedStrs;
    }

    tfController.value = TextEditingValue(
      text: result.text ?? tfController.value.text,
      selection: result.selection,
    );
  }
}
