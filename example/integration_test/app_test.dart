import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_trigger_input_example/main.dart' as app;
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-End Tests', () {
    testWidgets('Full workflow', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Trigger Input'));
      await tester.pumpAndSettle();

      final inputFinder = find.byType(TextField);

      // 1. Basic @mention
      await tester.tap(inputFinder);
      await tester.enterText(inputFinder, '@');
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.byType(ListTile), findsWidgets);
      final firstUser =
          (tester.widget<ListTile>(find.byType(ListTile).first).title as Text)
              .data!;
      await tester.tap(find.byType(ListTile).first);
      await tester.pumpAndSettle();

      final controller = tester.widget<TextField>(inputFinder).controller!;
      expect(controller.text, contains('@$firstUser'));

      // 2. Atomic Deletion
      await tester.enterText(inputFinder,
          controller.text.substring(0, controller.text.length - 2));
      await tester.pumpAndSettle();
      expect(controller.text.trim(), isNot(contains(firstUser)));

      // 3. #hashtag
      await tester.enterText(inputFinder, 'Check #');
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();
      await tester.tap(find.text('flutter'));
      await tester.pumpAndSettle();
      expect(controller.text, contains('#flutter'));

      // 4. Keyword with spaces (allowSpace: true)
      await tester.enterText(inputFinder, 'Search @');
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      final secondUser =
          (tester.widget<ListTile>(find.byType(ListTile).first).title as Text)
              .data!;
      // Split name to test partial search with space
      final parts = secondUser.split(' ');
      if (parts.length > 1) {
        await tester.enterText(inputFinder, 'Search @${parts[0]} ');
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();
        // Should still show suggestions
        expect(find.byType(ListTile), findsWidgets);
        await tester.tap(find.byType(ListTile).first);
        await tester.pumpAndSettle();
      } else {
        await tester.tap(find.byType(ListTile).first);
        await tester.pumpAndSettle();
      }

      // 5. BBCode Paste
      await tester.enterText(inputFinder, '');
      await tester.pumpAndSettle();
      final bbcode = '[mention trigger="@" id="1" name="Alice"][/mention]';
      await tester.enterText(inputFinder, 'Hi $bbcode');
      await tester.pumpAndSettle();
      expect(controller.text, contains('@Alice'));
    });
  });
}
