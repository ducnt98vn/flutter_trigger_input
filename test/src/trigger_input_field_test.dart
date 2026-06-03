import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_trigger_input/flutter_trigger_input.dart';

void main() {
  late TriggerInputController controller;

  setUp(() {
    controller = TriggerInputController(
      triggers: [
        Mention(
          trigger: '@',
          style: const TextStyle(color: Colors.blue),
        ),
      ],
    );
  });

  Widget buildTestWidget({
    bool allowSpace = false,
    Function(String, String)? onMentionSearchChanged,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: TriggerInputField(
          controller: controller,
          onMentionSearchChanged: onMentionSearchChanged ?? (t, k) {},
          allowSpace: allowSpace,
          decoration: const InputDecoration(hintText: 'Type something'),
        ),
      ),
    );
  }

  testWidgets('TriggerInputField renders correctly with hint text',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildTestWidget());

    expect(find.text('Type something'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('Typing @ trigger calls onMentionSearchChanged',
      (WidgetTester tester) async {
    String capturedTrigger = '';
    String capturedKeyword = '';

    await tester.pumpWidget(buildTestWidget(
      onMentionSearchChanged: (trigger, keyword) {
        capturedTrigger = trigger;
        capturedKeyword = keyword;
      },
    ));

    // Simulate typing "@j"
    await tester.enterText(find.byType(TextField), '@j');
    await tester.pump();

    expect(capturedTrigger, '@');
    expect(capturedKeyword, 'j');
  });

  testWidgets('didUpdateWidget updates controller allowSpace state',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildTestWidget(allowSpace: false));
    expect(controller.state.allowSpace, isFalse);

    // Update the widget with allowSpace: true
    await tester.pumpWidget(buildTestWidget(allowSpace: true));
    expect(controller.state.allowSpace, isTrue);
  });

  testWidgets('Tapping on a mention automatically selects the whole entity',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildTestWidget());

    // Setup state correctly to avoid duplication from MentionTextRenderer
    final text = '@John';
    final segment = TextSegment(text: text, attributes: {
      'mention': {'id': '1', 'name': 'John', 'trigger': '@'}
    });

    // Sync cache BEFORE updating controller, just like TriggerInputController does
    controller.state.cacheDisplayText = text;
    controller.state.cacheSelection = const TextSelection.collapsed(offset: 5);
    controller.tfController.segmentsInternal = [segment];
    controller.tfController.value = TextEditingValue(
      text: text,
      selection: const TextSelection.collapsed(offset: 5),
    );

    await tester.pumpAndSettle();
    expect(controller.tfController.text, '@John');

    // Tap in the middle of the mention
    // We use tapAt with coordinates from the render box to be precise
    final RenderBox textField = tester.renderObject(find.byType(TextField));
    final Offset tapPosition =
        textField.localToGlobal(Offset(10, textField.size.height / 2));

    await tester.tapAt(tapPosition);
    await tester.pumpAndSettle();

    // The selection logic in _handleTapSelection runs in a microtask
    await tester.pump(Duration.zero);

    final selection = controller.tfController.selection;
    expect(selection.start, 0);
    expect(selection.end, 5);
  });

  testWidgets('Double space at the end of keyword stops suggestions',
      (WidgetTester tester) async {
    int callCount = 0;
    String lastKeyword = '';

    await tester.pumpWidget(buildTestWidget(
      allowSpace: true,
      onMentionSearchChanged: (trigger, keyword) {
        callCount++;
        lastKeyword = keyword;
      },
    ));

    final textField = find.byType(TextField);

    // 1. Type "@abc " (one space) - should trigger suggestion
    await tester.enterText(textField, '@abc ');
    await tester.pump();
    expect(callCount, 1);
    expect(lastKeyword, 'abc ');

    // Pre-fill some suggestions to check if they get cleared
    controller.state.suggestionInfos.value = [
      SuggestionInfo(id: '1', name: 'Test')
    ];

    // 2. Type "@abc  " (two spaces) - should NOT trigger suggestion and should clear list
    await tester.enterText(textField, '@abc  ');
    await tester.pump();

    expect(callCount, 1,
        reason: 'Callback should not be called for double space');
    expect(controller.state.suggestionInfos.value, isEmpty,
        reason: 'Suggestions should be cleared');
  });
}
