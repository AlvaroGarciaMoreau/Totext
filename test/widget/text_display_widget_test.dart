import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:totext/widgets/text_display_widget.dart';

void main() {
  group('TextDisplayWidget Tests', () {
    testWidgets('should display text correctly', (WidgetTester tester) async {
      const testText = 'Hello World Test';
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TextDisplayWidget(
              text: testText,
              isLoading: false,
              isEditing: false,
            ),
          ),
        ),
      );

      expect(find.textContaining(testText), findsOneWidget);
    });

    testWidgets('should show loading indicator when loading', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TextDisplayWidget(
              text: 'Test',
              isLoading: true,
              isEditing: false,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show TextFormField when editing', (WidgetTester tester) async {
      const testText = 'Editable text';
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextDisplayWidget(
              text: testText,
              isLoading: false,
              isEditing: true,
              controller: TextEditingController(text: testText),
              onChanged: (text) {},
            ),
          ),
        ),
      );

      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('should call onChanged when text is modified', (WidgetTester tester) async {
      String? changedText;
      const initialText = 'Initial text';
      const newText = 'Modified text';
      final controller = TextEditingController(text: initialText);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextDisplayWidget(
              text: initialText,
              isLoading: false,
              isEditing: true,
              controller: controller,
              onChanged: (text) {
                changedText = text;
              },
            ),
          ),
        ),
      );

      // Find the TextFormField and enter new text
      await tester.enterText(find.byType(TextFormField), newText);
      
      expect(changedText, newText);
    });

    testWidgets('should handle empty text gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TextDisplayWidget(
              text: '',
              isLoading: false,
              isEditing: false,
            ),
          ),
        ),
      );

      // Should show placeholder text for empty text
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('should handle long text with scrolling', (WidgetTester tester) async {
      final longText = 'Long text ' * 100; // Very long text
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextDisplayWidget(
              text: longText,
              isLoading: false,
              isEditing: false,
            ),
          ),
        ),
      );

      // Should find scrollable widget for long text
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('should handle tap when not editing', (WidgetTester tester) async {
      bool tapped = false;
      const testText = 'Tappable text';
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextDisplayWidget(
              text: testText,
              isLoading: false,
              isEditing: false,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(GestureDetector));
      expect(tapped, true);
    });

    testWidgets('should not allow tap on empty text', (WidgetTester tester) async {
      bool tapped = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextDisplayWidget(
              text: '',
              isLoading: false,
              isEditing: false,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(GestureDetector));
      expect(tapped, false);
    });
  });
}
