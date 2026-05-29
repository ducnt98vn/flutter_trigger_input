import 'package:flutter/material.dart' hide Text, Element;
import 'package:flutter_trigger_input/flutter_trigger_input.dart';
import 'package:flutter_trigger_input/src/modal/length_map.dart';
import 'package:flutter_trigger_input/src/utils/bbcode.dart';
import 'package:flutter_trigger_input/src/utils/suggestion/suggestion_listener.dart';
import 'package:flutter_trigger_input/src/utils/text_edit/mention_text_renderer.dart';

import 'trigger_state.dart';

class TriggerInputController<T extends SuggestionInfo> extends ChangeNotifier {
  final state = TriggerState<T>();
  final tfController = TFController();
  final mentionTextRenderer = MentionTextRenderer();
  final suggestionListenerC = SuggestionListener();

  TriggerInputController({List<Mention<T>>? triggers}) {
    if (triggers != null) {
      state.triggers.value = triggers;
      tfController.triggerConfigs = triggers;
    }
  }

  void suggestMentionDispose() {
    state.selectedMentionInfos.dispose();
    state.suggestionInfos.dispose();
    state.selectedMentionLengths.dispose();
  }

  @override
  void dispose() {
    suggestMentionDispose();
    tfController.dispose();
    super.dispose();
  }

  /// Adds a mention at the current suggestion position.
  void addMention(T value) {
    final selectedMention = state.selectedMentionLengths.value;
    if (selectedMention == null) return;

    state.setSelectedMentionLengths(null);

    final currentText = tfController.text;
    final replaceStart = selectedMention.start.clamp(0, currentText.length);
    final replaceEnd = selectedMention.end.clamp(
      replaceStart,
      currentText.length,
    );

    final trigger = selectedMention.displayStr.isNotEmpty
        ? selectedMention.displayStr[0]
        : '@';

    final mentionConfig = state.triggers.value.firstWhere(
      (element) => element.trigger == trigger,
      orElse: () => Mention<T>(trigger: trigger),
    );

    final mentionDisplay = '$trigger${value.suggestionName}';
    final suffix = state.appendSpaceOnAdd ? ' ' : '';
    final fullReplaceStr = '$mentionDisplay$suffix';

    final originStr = mentionConfig.markupBuilder != null
        ? mentionConfig.markupBuilder!(trigger, value.id, value.name)
        : BbCode.createMentionBbob(
            trigger: trigger,
            name: value.name,
            id: value.id,
          );

    // Synchronize cache to prevent jumpy UI during renderMentionListener
    state.cacheDisplayText = currentText.replaceRange(
      replaceStart,
      replaceEnd,
      fullReplaceStr,
    );
    state.cacheSelection = TextSelection.collapsed(
      offset: replaceStart + fullReplaceStr.length,
    );

    tfController.addMention(
      cursorPos: tfController.selection.baseOffset,
      cacheText: currentText,
      cacheStr: LengthMap(
        start: replaceStart,
        end: replaceEnd,
        displayStr: currentText.substring(replaceStart, replaceEnd),
      ),
      mentionStr: LengthMap(
        start: replaceStart,
        end: replaceStart + mentionDisplay.length,
        displayStr: mentionDisplay,
        originStr: originStr,
      ),
      appendSpaceOnAdd: state.appendSpaceOnAdd,
    );

    _syncSelectedMentionInfos(value);
  }

  /// Inserts an entity at the very beginning of the text field.
  void insertEntityAtStart({required T entity, String trigger = '@'}) {
    final mentionConfig = state.triggers.value.firstWhere(
      (element) => element.trigger == trigger,
      orElse: () => Mention<T>(trigger: trigger),
    );

    final mentionDisplay = '$trigger${entity.name}';
    final originStr = mentionConfig.markupBuilder != null
        ? mentionConfig.markupBuilder!(trigger, entity.id, entity.name)
        : BbCode.createMentionBbob(
            trigger: trigger,
            id: entity.id,
            name: entity.name,
          );

    // Prevent duplicate insertion of the same entity if it's already there
    final exists = tfController.mentionedStrs.any(
      (e) => e.originStr == originStr,
    );
    if (exists) return;

    final currentText = tfController.text;
    final suffix = state.appendSpaceOnAdd ? ' ' : '';
    final fullInsertStr = '$mentionDisplay$suffix';

    state.cacheDisplayText = currentText.replaceRange(0, 0, fullInsertStr);
    state.cacheSelection = TextSelection.collapsed(
      offset: fullInsertStr.length,
    );

    tfController.addMention(
      cursorPos: 0,
      cacheText: currentText,
      cacheStr: LengthMap(start: 0, end: 0, displayStr: ''),
      mentionStr: LengthMap(
        start: 0,
        end: mentionDisplay.length,
        displayStr: mentionDisplay,
        originStr: originStr,
      ),
      appendSpaceOnAdd: state.appendSpaceOnAdd,
    );

    _syncSelectedMentionInfos(entity);
  }

  /// Synchronizes the list of selected mention objects.
  void _syncSelectedMentionInfos(T entity) {
    final currentList = state.selectedMentionInfos.value;
    if (!currentList.any((e) => e.id == entity.id)) {
      state.setSelectedMentionInfos([...currentList, entity]);
    }
  }

  void suggestionListener() {
    final triggerSymbols = state.triggers.value.map((e) => e.trigger).toList();
    final result = suggestionListenerC.execute(
      tfController: tfController,
      triggerSymbols: triggerSymbols.isEmpty ? ['@'] : triggerSymbols,
      allowSpace: state.allowSpace,
    );
    state.setSelectedMentionLengths(result);
  }

  void renderMentionListener() {
    final result = mentionTextRenderer.execute(
      cacheDisplayText: state.cacheDisplayText,
      tfController: tfController,
      cacheSelection: state.cacheSelection,
    );

    state.cacheSelection = result.selection;
    state.cacheDisplayText = result.cacheDisplayText;
    tfController.mentionedStrs = result.mentionedStrs;

    final newText = result.text ?? tfController.text;

    // Only update if there's an actual change to avoid unnecessary rebuilds
    if (tfController.text != newText ||
        tfController.selection != result.selection) {
      tfController.value = TextEditingValue(
        text: newText,
        selection: result.selection,
      );
    }
  }
}
