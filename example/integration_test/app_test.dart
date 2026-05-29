import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_trigger_input_example/main.dart' as app;
import 'package:flutter_trigger_input/flutter_trigger_input.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-End Tests', () {
    testWidgets('Basic Lifecycle: Add, Delete, Replace, and Insert Start',
        (tester) async {
      app.main();
      await tester.pumpAndSettle();

      final triggerInputItem = find.text('Trigger Input');
      await tester.tap(triggerInputItem);
      await tester.pumpAndSettle();

      final inputFieldFinder = find.byType(TriggerInputField<SuggestionInfo>);
      final editableTextFinder = find.descendant(
        of: inputFieldFinder,
        matching: find.byType(EditableText),
      );

      // 1. Add Mention
      await tester.enterText(inputFieldFinder, 'Hello @');
      await tester.pumpAndSettle();
      
      final suggestionFinder = find.byType(ListTile);
      expect(suggestionFinder, findsWidgets);
      
      final firstSuggestion = tester.widget<ListTile>(suggestionFinder.first);
      final String suggestionName = (firstSuggestion.title as Text).data!;

      await tester.tap(suggestionFinder.first);
      await tester.pumpAndSettle();

      var controller = (tester.widget(editableTextFinder) as EditableText).controller;
      expect(controller.text, contains('@$suggestionName'));

      // 2. Atomic Deletion
      // Note: A space is appended after adding a mention. 
      // To trigger atomic deletion of the entity, we must delete at least 
      // the space AND one character of the mention name.
      final textBeforeDelete = controller.text;
      await tester.enterText(inputFieldFinder, textBeforeDelete.substring(0, textBeforeDelete.length - 2));
      await tester.pumpAndSettle();
      
      // Now it should be completely gone, but the space after "Hello" should stay.
      // Result should be "Hello  " (if there was a space before mention and we kept the trailing one)
      expect(controller.text.trim(), equals('Hello'));

      // 3. Add Hashtag
      await tester.enterText(inputFieldFinder, 'Topic #');
      await tester.pumpAndSettle();
      await tester.tap(find.text('flutter'));
      await tester.pumpAndSettle();
      expect(controller.text, contains('#flutter'));

      // 4. Insert at Start
      await tester.tap(find.text('Add @Mention'));
      await tester.pumpAndSettle();
      expect(controller.text.startsWith('@'), isTrue);

      // 5. Replace
      final currentText = controller.text;
      await tester.enterText(inputFieldFinder, currentText.replaceFirst('#flutter', 'replaced'));
      await tester.pumpAndSettle();
      expect(controller.text, contains('replaced'));
    });

    testWidgets('Advanced Scenarios: Spaces, Multiline, Emojis, and Vietnamese IME',
        (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Trigger Input'));
      await tester.pumpAndSettle();

      final inputFieldFinder = find.byType(TriggerInputField<SuggestionInfo>);
      final editableTextFinder = find.descendant(
        of: inputFieldFinder,
        matching: find.byType(EditableText),
      );
      var controller = (tester.widget(editableTextFinder) as EditableText).controller;

      // TC_KeywordSpace_01: Keyword with spaces
      // Note: allowSpace must be true.
      // We search for '@' then some characters to ensure we find a real suggestion from the list.
      await tester.enterText(inputFieldFinder, '@');
      await tester.pumpAndSettle();
      
      final firstSuggestion = tester.widget<ListTile>(find.byType(ListTile).first);
      final String fullName = (firstSuggestion.title as Text).data!;
      
      // Simulate gõing the full name with spaces
      await tester.enterText(inputFieldFinder, '@$fullName');
      await tester.pumpAndSettle();
      
      // Suggestion panel should still be visible because allowSpace is true
      expect(find.byType(ListTile), findsWidgets); 
      await tester.tap(find.byType(ListTile).first);
      await tester.pumpAndSettle();
      expect(controller.text, startsWith('@'));

      // TC_PasteMarkup_01: Paste BBCode
      final bbcode = '[mention trigger="@" id="u123" name="Alice"][/mention]';
      await tester.enterText(inputFieldFinder, 'Check $bbcode');
      await tester.pumpAndSettle();
      expect(controller.text, contains('@Alice'));
      expect(controller.text, isNot(contains('[mention')));

      // TC_MultilineMention_01: Multiline
      await tester.enterText(inputFieldFinder, 'Line 1\nLine 2 @');
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ListTile).first);
      await tester.pumpAndSettle();
      expect(controller.text, contains('\nLine 2 @'));

      // TC_EmojiBoundary_01: Emojis
      await tester.enterText(inputFieldFinder, 'Emoji 🔥 @');
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ListTile).first);
      await tester.pumpAndSettle();
      expect(controller.text, contains('🔥 @'));

      // TC_VietnameseIME_01: sao + s -> sáo
      await tester.enterText(inputFieldFinder, 'sao');
      await tester.pumpAndSettle();
      await tester.enterText(inputFieldFinder, 'sáo');
      await tester.pumpAndSettle();
      expect(controller.text, equals('sáo'));

      // TC_DuplicateTrigger_01: @@James
      await tester.enterText(inputFieldFinder, '@@');
      await tester.pumpAndSettle();
      expect(find.byType(ListTile), findsWidgets);
    });
  });
}
