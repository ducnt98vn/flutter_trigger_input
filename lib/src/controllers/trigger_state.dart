import 'package:flutter/material.dart' show TextSelection, TextAffinity;
import 'package:flutter_trigger_input/flutter_trigger_input.dart';
import 'package:flutter_trigger_input/src/modal/length_map.dart';
import 'package:flutter_trigger_input/src/utils/safe_value_notifier.dart';

class TriggerState<T extends SuggestionInfo> {
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // SECTION: CORE STATE & CONFIGURATION
  // These variables manage the primary data flow and UI state for mentions.
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// List of mentions currently present in the input field.
  final SafeValueNotifier<List<T>> _selectedMentionInfos =
      SafeValueNotifier<List<T>>([]);

  /// List of suggestion items to be displayed in the overlay/modal.
  final SafeValueNotifier<List<T>> suggestionInfos = SafeValueNotifier<List<T>>(
    [],
  );

  /// List of users or items that are available to be mentioned.
  final SafeValueNotifier<List<T>> canMentions = SafeValueNotifier<List<T>>([]);

  /// Controls the visibility of the suggestion overlay.
  final SafeValueNotifier<bool> showSuggestions = SafeValueNotifier<bool>(
    false,
  );

  /// Configuration for different mention types (e.g., '@' for users, '#' for topics).
  // final SafeValueNotifier<List<Mention>> mentions =
  //     SafeValueNotifier<List<Mention>>([
  //       Mention(
  //         trigger: '@',
  //         style: const TextStyle(color: Colors.green),
  //         markupBuilder: (trigger, mention, value) =>
  //             Bbob.createMentionBbob(id: mention, name: value),
  //         data: [],
  //       ),
  //     ]);

  /// Tracks the specific mention item currently being interacted with (e.g., during editing).
  final SafeValueNotifier<LengthMap?> _selectedMentionLengths =
      SafeValueNotifier<LengthMap?>(null);

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // SECTION: CACHE STATE
  // Variables to store temporary state for logic optimization and change detection.
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// hether to automatically append a space after a tag is selected.
  bool appendSpaceOnAdd = true;

  /// Stores the previous selection to detect cursor movement or state changes.
  TextSelection cacheSelection = const TextSelection(
    affinity: TextAffinity.downstream,
    baseOffset: -1,
    extentOffset: -1,
  );

  /// Caches the previous text content to detect meaningful updates.
  String cacheDisplayText = '';

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // SECTION: STATE ACCESSORS
  // Provides controlled access to update state and listen to changes.
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  void setSelectedMentionInfos(List<T> newData) {
    if (!selectedMentionInfos.isDisposed) _selectedMentionInfos.value = newData;
  }

  void setSelectedMentionLengths(LengthMap? newData) {
    if (!_selectedMentionLengths.isDisposed) {
      _selectedMentionLengths.value = newData;
    }
  }

  SafeValueNotifier<List<T>> get selectedMentionInfos => _selectedMentionInfos;

  SafeValueNotifier<LengthMap?> get selectedMentionLengths =>
      _selectedMentionLengths;
}
