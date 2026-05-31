import 'package:flutter/material.dart' show TextSelection, TextAffinity;
import 'package:flutter_trigger_input/flutter_trigger_input.dart';
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

  /// Configuration for different mention types (e.g., '@' for users, '#' for topics).
  final SafeValueNotifier<List<Mention<T>>> triggers =
      SafeValueNotifier<List<Mention<T>>>([]);

  /// Tracks the specific mention item currently being interacted with (e.g., during editing).
  final SafeValueNotifier<LengthMap?> _selectedMentionLengths =
      SafeValueNotifier<LengthMap?>(null);

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // SECTION: CACHE STATE
  // Variables to store temporary state for logic optimization and change detection.
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Whether to automatically append a space after a tag is selected.
  bool appendSpaceOnAdd = true;

  /// Whether to allow spaces in the keyword after a trigger.
  bool allowSpace = false;

  /// Whether to enable automatic link replacement when pasting.
  bool enableLinkReplacement = true;

  /// Text to display instead of the raw URL when link replacement is enabled.
  String linkReplacementText = 'See link';

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
