import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'controllers/trigger_input_controller.dart';
import 'core/constant.dart';
import 'modal/length_map.dart';
import 'modal/mention.dart';
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
    required this.onMentionSearchChanged,
    this.allowSpace = false,
    this.enableLinkReplacement = true,
    this.linkReplacementText = 'See link',
  });

  final TriggerInputController controller;

  final bool hideSuggestionList;

  final bool allowSpace;

  final bool enableLinkReplacement;

  final String linkReplacementText;

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
  TriggerInputFieldState<T> createState() => TriggerInputFieldState<T>();
}

class TriggerInputFieldState<T extends SuggestionInfo>
    extends State<TriggerInputField<T>> {
  final GlobalKey _textFieldKey = GlobalKey();

  @override
  void initState() {
    widget.controller.state.allowSpace = widget.allowSpace;
    widget.controller.state.enableLinkReplacement =
        widget.enableLinkReplacement;
    widget.controller.state.linkReplacementText = widget.linkReplacementText;

    widget.controller.tfController.addListener(
      () => widget.controller.renderMentionListener(),
    );

    widget.controller.tfController.addListener(_suggestionListener);

    widget.controller.tfController.addListener(_tfTextInputListeners);

    widget.controller.tfController.addListener(_inputListeners);

    super.initState();
  }

  @override
  void didUpdateWidget(covariant TriggerInputField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.allowSpace != oldWidget.allowSpace) {
      widget.controller.state.allowSpace = widget.allowSpace;
    }
    if (widget.enableLinkReplacement != oldWidget.enableLinkReplacement) {
      widget.controller.state.enableLinkReplacement =
          widget.enableLinkReplacement;
    }
    if (widget.linkReplacementText != oldWidget.linkReplacementText) {
      widget.controller.state.linkReplacementText = widget.linkReplacementText;
    }
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
      // Logic xóa metadata hiện đã được tự động hóa trong DeltaProcessor
    }
  }

  void _inputListeners() {
    final mentionState = widget.controller.state.selectedMentionLengths.value;

    if (mentionState?.displayStr case final String triggeredKey?) {
      final textController = widget.controller.tfController;

      final triggerSymbol = triggeredKey[0];
      final keyword = triggeredKey.substring(1);

      final cursorPos = textController.selection.baseOffset;
      final triggerStartPos = cursorPos - triggeredKey.length;

      final bool isOverlapping = textController.mentionedStrs.any(
        (m) => triggerStartPos < m.end && cursorPos > m.start,
      );

      bool shouldShowSuggestions = !isOverlapping;

      if (shouldShowSuggestions) {
        widget.onMentionSearchChanged.call(triggerSymbol, keyword);
      }
    } else if (widget.controller.state.suggestionInfos.value.isNotEmpty) {
      widget.controller.state.suggestionInfos.value = [];
    }
  }

  void _handleTapSelection() {
    widget.onTap?.call();

    // Sử dụng microtask để đợi framework cập nhật vị trí con trỏ sau khi tap
    Future.microtask(() {
      if (!mounted) return;

      final controller = widget.controller.tfController;
      final selection = controller.selection;

      // Chỉ xử lý nếu là tap (không phải đang bôi đen thủ công)
      if (!selection.isCollapsed) return;

      final offset = selection.baseOffset;

      if (offset >= 0) {
        for (final mention in controller.mentionedStrs) {
          // Nếu vị trí chạm nằm trong hoặc sát biên của một mention
          if (offset >= mention.start && offset <= mention.end) {
            controller.selection = TextSelection(
              baseOffset: mention.start,
              extentOffset: mention.end,
            );

            // Hiển thị Context Menu sau khi bôi đen
            _showContextMenu();
            break;
          }
        }
      }
    });
  }

  void _showContextMenu() {
    void findAndShowToolbar(Element element) {
      if (element.widget is EditableText) {
        final state = (element as StatefulElement).state as EditableTextState;
        state.showToolbar();
        return;
      }
      element.visitChildren(findAndShowToolbar);
    }

    final context = _textFieldKey.currentContext;
    if (context != null) {
      context.visitChildElements(findAndShowToolbar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: _textFieldKey,
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
      onTap: _handleTapSelection,
      onSubmitted: widget.onSubmitted,
      enabled: widget.enabled,
      enableInteractiveSelection: widget.enableInteractiveSelection,
      enableSuggestions: widget.enableSuggestions,
      scrollController: widget.scrollController,
      scrollPadding: widget.scrollPadding,
      scrollPhysics: widget.scrollPhysics,
      contextMenuBuilder: (context, editableTextState) {
        final controller = widget.controller.tfController;
        final selection = controller.selection;

        // Check if selection matches exactly one mention
        LengthMap? targetMention;
        for (final m in controller.mentionedStrs) {
          if (m.start == selection.start && m.end == selection.end) {
            targetMention = m;
            break;
          }
        }

        if (targetMention != null) {
          final trigger = targetMention.trigger;
          Mention? config;
          for (final t in widget.controller.state.triggers.value) {
            if (t.trigger == trigger) {
              config = t;
              break;
            }
          }

          if (config != null) {
            final label = config.contextMenuLabel ?? 'Copy Raw';
            final markup = targetMention.originStr;

            return AdaptiveTextSelectionToolbar.buttonItems(
              anchors: editableTextState.contextMenuAnchors,
              buttonItems: [
                ...editableTextState.contextMenuButtonItems,
                ContextMenuButtonItem(
                  label: label,
                  onPressed: () {
                    if (config?.onContextMenuPressed != null) {
                      config!.onContextMenuPressed!(markup);
                    } else {
                      Clipboard.setData(ClipboardData(text: markup));
                    }
                    editableTextState.hideToolbar();
                  },
                ),
              ],
            );
          }
        }

        return AdaptiveTextSelectionToolbar.editableText(
          editableTextState: editableTextState,
        );
      },
    );
  }
}
