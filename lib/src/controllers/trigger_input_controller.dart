import 'package:flutter/material.dart' hide Text, Element;
import 'package:flutter_trigger_input/flutter_trigger_input.dart';
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

    final mentionDisplay = '$trigger${value.suggestionName}';
    final suffix = state.appendSpaceOnAdd ? ' ' : '';

    final mentionSegment = TextSegment(
      text: mentionDisplay,
      attributes: {
        'mention': {'id': value.id, 'name': value.name, 'trigger': trigger},
      },
    );

    // Chuẩn bị danh sách segment để chèn (Mention + Dấu cách)
    final List<TextSegment> insertSegments = [mentionSegment];
    if (state.appendSpaceOnAdd) {
      insertSegments.add(TextSegment(text: ' '));
    }

    // Cập nhật cache trước để Renderer không xử lý đè lên
    final newFullText = currentText.replaceRange(
      replaceStart,
      replaceEnd,
      mentionDisplay + suffix,
    );
    state.cacheDisplayText = newFullText;
    state.cacheSelection = TextSelection.collapsed(
      offset: replaceStart + mentionDisplay.length + suffix.length,
    );

    // Chèn nguyên tử (Atomic insertion)
    tfController.replaceRangeWithSegments(
      replaceStart,
      replaceEnd,
      insertSegments,
    );

    _syncSelectedMentionInfos(value);
  }

  /// Inserts an entity at the very beginning of the text field.
  void insertEntityAtStart({required T entity, String trigger = '@'}) {
    final mentionDisplay = '$trigger${entity.name}';
    final suffix = state.appendSpaceOnAdd ? ' ' : '';

    final mentionSegment = TextSegment(
      text: mentionDisplay,
      attributes: {
        'mention': {'id': entity.id, 'name': entity.name, 'trigger': trigger},
      },
    );

    final List<TextSegment> insertSegments = [mentionSegment];
    if (state.appendSpaceOnAdd) {
      insertSegments.add(TextSegment(text: ' '));
    }

    // Cập nhật cache trước
    final newFullText = mentionDisplay + suffix + tfController.text;
    state.cacheDisplayText = newFullText;
    state.cacheSelection = TextSelection.collapsed(
      offset: mentionDisplay.length + suffix.length,
    );

    tfController.replaceRangeWithSegments(0, 0, insertSegments);

    _syncSelectedMentionInfos(entity);
  }

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
      triggerSymbols: triggerSymbols.isEmpty ? ['@', '#'] : triggerSymbols,
      allowSpace: state.allowSpace,
    );
    state.setSelectedMentionLengths(result);
  }

  void renderMentionListener() {
    final result = mentionTextRenderer.execute(
      cacheDisplayText: state.cacheDisplayText,
      tfController: tfController,
      cacheSelection: state.cacheSelection,
      enableLinkReplacement: state.enableLinkReplacement,
      linkReplacementText: state.linkReplacementText,
    );

    // Cập nhật segments trước khi cập nhật value của Controller
    if (result.segments != null) {
      tfController.segmentsInternal = result.segments!;
    }

    state.cacheSelection = result.selection;
    state.cacheDisplayText = result.cacheDisplayText;

    final newText = result.text ?? tfController.text;

    if (tfController.text != newText ||
        tfController.selection != result.selection) {
      tfController.value = TextEditingValue(
        text: newText,
        selection: result.selection,
      );
    }
  }
}
