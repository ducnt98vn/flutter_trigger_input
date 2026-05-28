import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'controllers/trigger_input_controller.dart';
import 'core/constant.dart';
import 'modal/suggestion_info.dart';

class TriggerInputField<T extends SuggestionInfo> extends StatefulWidget {
  const TriggerInputField({
    super.key,
    this.focusNode,
    this.decoration = const InputDecoration(),
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.style,
    this.textAlign = TextAlign.start,
    this.textDirection,
    this.autofocus = false,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.maxLines = 1,
    this.minLines,
    this.expands = false,
    this.readOnly = false,
    this.showCursor,
    this.maxLength,
    this.maxLengthEnforcement = MaxLengthEnforcement.none,
    this.onEditingComplete,
    this.onSubmitted,
    this.enabled,
    this.cursorWidth = 2.0,
    this.cursorRadius,
    this.cursorColor,
    this.keyboardAppearance,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.enableInteractiveSelection = true,
    this.onTap,
    this.buildCounter,
    this.scrollPhysics,
    this.scrollController,
    this.autofillHints,
    this.hideSuggestionList = false,

    required this.controller,
    required this.initSuggestList,
    required this.onMentionSearchChanged,
  });

  final TriggerInputController controller;

  final List<T> initSuggestList;

  final bool hideSuggestionList;

  final SuggestionExecuteCallback<T> onMentionSearchChanged;

  /// Focus node for controlling the focus of the Input.
  final FocusNode? focusNode;

  /// The decoration to show around the text field.
  final InputDecoration decoration;

  /// {@macro flutter.widgets.editableText.keyboardType}
  final TextInputType? keyboardType;

  /// {@macro flutter.widgets.editableText.textInputAction}
  final TextInputAction? textInputAction;

  /// {@macro flutter.widgets.editableText.textCapitalization}
  final TextCapitalization textCapitalization;

  /// {@macro flutter.widgets.editableText.style}
  final TextStyle? style;

  /// {@macro flutter.widgets.editableText.textAlign}
  final TextAlign textAlign;

  /// {@macro flutter.widgets.editableText.textDirection}
  final TextDirection? textDirection;

  /// {@macro flutter.widgets.editableText.autofocus}
  final bool autofocus;

  /// {@macro flutter.widgets.editableText.autocorrect}
  final bool autocorrect;

  /// {@macro flutter.services.textInput.enableSuggestions}
  final bool enableSuggestions;

  /// {@macro flutter.widgets.editableText.maxLines}
  final int maxLines;

  /// {@macro flutter.widgets.editableText.minLines}
  final int? minLines;

  /// {@macro flutter.widgets.editableText.expands}
  final bool expands;

  /// {@macro flutter.widgets.editableText.readOnly}
  final bool readOnly;

  /// {@macro flutter.widgets.editableText.showCursor}
  final bool? showCursor;

  /// {@macro flutter.widgets.editableText.maxLength}
  final int? maxLength;

  /// {@macro flutter.widgets.editableText.maxLengthEnforcement}
  final MaxLengthEnforcement maxLengthEnforcement;

  /// {@macro flutter.widgets.editableText.onEditingComplete}
  final VoidCallback? onEditingComplete;

  /// {@macro flutter.widgets.editableText.onSubmitted}
  final ValueChanged<String>? onSubmitted;

  /// {@macro flutter.widgets.editableText.enabled}
  final bool? enabled;

  /// {@macro flutter.widgets.editableText.cursorWidth}
  final double cursorWidth;

  /// {@macro flutter.widgets.editableText.cursorRadius}
  final Radius? cursorRadius;

  /// {@macro flutter.widgets.editableText.cursorColor}
  final Color? cursorColor;

  /// {@macro flutter.widgets.editableText.keyboardAppearance}
  final Brightness? keyboardAppearance;

  /// {@macro flutter.widgets.editableText.scrollPadding}
  final EdgeInsets scrollPadding;

  /// {@macro flutter.widgets.editableText.enableInteractiveSelection}
  final bool enableInteractiveSelection;

  /// {@macro flutter.rendering.editable.selectionEnabled}
  bool get selectionEnabled => enableInteractiveSelection;

  /// {@macro flutter.rendering.editable.onTap}
  final GestureTapCallback? onTap;

  /// {@macro flutter.rendering.editable.buildCounter}
  final InputCounterWidgetBuilder? buildCounter;

  /// {@macro flutter.widgets.editableText.scrollPhysics}
  final ScrollPhysics? scrollPhysics;

  /// {@macro flutter.widgets.editableText.scrollController}
  final ScrollController? scrollController;

  /// {@macro flutter.widgets.editableText.autofillHints}
  final Iterable<String>? autofillHints;

  @override
  TriggerInputFieldState createState() => TriggerInputFieldState();
}

class TriggerInputFieldState extends State<TriggerInputField> {
  @override
  void initState() {
    widget.controller.state.canMentions.value = widget.initSuggestList;

    widget.controller.tfController.addListener(
      () => widget.controller.renderMentionListener(),
    );

    widget.controller.tfController.addListener(_suggestionListener);

    widget.controller.tfController.addListener(_tfTextInputListeners);

    widget.controller.tfController.addListener(_inputListeners);

    super.initState();
  }

  @override
  void dispose() {
    widget.controller.tfController.removeListener(_suggestionListener);
    widget.controller.tfController.removeListener(_tfTextInputListeners);
    widget.controller.tfController.removeListener(_inputListeners);

    super.dispose();
  }

  void _suggestionListener() {
    widget.controller.suggestionListener();
  }

  void _tfTextInputListeners() {
    if (widget.controller.tfController.text.trim().isEmpty) {
      widget.controller.state.setSelectedMentionInfos([]);
      widget.controller.tfController.mentionedStrs.clear();
    }
  }

  void _inputListeners() {
    final mentionState = widget.controller.state.selectedMentionLengths.value;

    if (mentionState?.displayStr case final String triggeredKey?) {
      final textController = widget.controller.tfController;

      final triggerSymbol = triggeredKey[0];
      final keyword = triggeredKey.substring(1);

      final cursorPos = textController.selection.baseOffset;
      final triggerPos = cursorPos - triggeredKey.length + 1;

      final bool isOverlapping = textController.mentionedStrs.any(
        (m) => m.start < triggerPos && triggerPos <= m.end,
      );

      bool shouldShowSuggestions = triggerPos <= 0 || !isOverlapping;

      if (shouldShowSuggestions) {
        widget.controller.state.suggestionInfos.value = widget
            .onMentionSearchChanged
            .call(triggerSymbol, keyword);
      }
    } else if (widget.controller.state.suggestionInfos.value.isNotEmpty) {
      widget.controller.state.suggestionInfos.value = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller.tfController,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      focusNode: widget.focusNode,
      keyboardType: widget.keyboardType,
      keyboardAppearance: widget.keyboardAppearance,
      textInputAction: widget.textInputAction,
      textCapitalization: widget.textCapitalization,
      style: widget.style,
      textAlign: widget.textAlign,
      textDirection: widget.textDirection,
      readOnly: widget.readOnly,
      showCursor: widget.showCursor,
      autofocus: widget.autofocus,
      autocorrect: widget.autocorrect,
      maxLengthEnforcement: widget.maxLengthEnforcement,
      cursorColor: widget.cursorColor,
      cursorRadius: widget.cursorRadius,
      cursorWidth: widget.cursorWidth,
      buildCounter: widget.buildCounter,
      autofillHints: widget.autofillHints,
      decoration: widget.decoration,
      expands: widget.expands,
      onEditingComplete: widget.onEditingComplete,
      onTap: widget.onTap,
      onSubmitted: widget.onSubmitted,
      enabled: widget.enabled,
      enableInteractiveSelection: widget.enableInteractiveSelection,
      enableSuggestions: widget.enableSuggestions,
      scrollController: widget.scrollController,
      scrollPadding: widget.scrollPadding,
      scrollPhysics: widget.scrollPhysics,
    );
  }
}
