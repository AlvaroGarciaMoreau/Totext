import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:totext/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('ToText App Integration Tests', () {
    testWidgets('App starts and shows main interface', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Verify that the main screen is displayed
      expect(find.text('ToText'), findsOneWidget);
      
      // Check for main navigation elements
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      
      // Verify main action buttons are present
      expect(find.byIcon(Icons.camera_alt), findsWidgets);
      expect(find.byIcon(Icons.mic), findsWidgets);
    });

    testWidgets('Navigation between tabs works', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Find the bottom navigation bar
      final bottomNavBar = find.byType(BottomNavigationBar);
      expect(bottomNavBar, findsOneWidget);

      // Navigate to history tab (assuming it's the second tab)
      await tester.tap(find.byIcon(Icons.history));
      await tester.pumpAndSettle();

      // Verify we're on the history page
      expect(find.text('Historial'), findsOneWidget);

      // Navigate back to home
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();
    });

    testWidgets('Camera options sheet opens', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Find and tap camera button
      final cameraButton = find.byIcon(Icons.camera_alt);
      expect(cameraButton, findsWidgets);
      
      await tester.tap(cameraButton.first);
      await tester.pumpAndSettle();

      // Verify camera options are shown
      expect(find.text('Tomar Foto'), findsOneWidget);
      expect(find.text('Seleccionar de Galería'), findsOneWidget);
    });

    testWidgets('Settings screen navigation works', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Find and tap settings/menu button
      final settingsButton = find.byIcon(Icons.settings).first;
      await tester.tap(settingsButton);
      await tester.pumpAndSettle();

      // Verify settings screen is displayed
      expect(find.text('Configuración'), findsOneWidget);

      // Check for main settings sections
      expect(find.text('Tema'), findsOneWidget);
      expect(find.text('Idioma'), findsOneWidget);
      expect(find.text('Accesibilidad'), findsOneWidget);
    });

    testWidgets('Theme switching works', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to settings
      await tester.tap(find.byIcon(Icons.settings).first);
      await tester.pumpAndSettle();

      // Find and tap dark theme option
      await tester.tap(find.text('Oscuro'));
      await tester.pumpAndSettle();

      // Go back to verify theme change
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Verify the app uses dark theme
      final MaterialApp materialApp = tester.widget(find.byType(MaterialApp));
      expect(materialApp.themeMode, ThemeMode.dark);
    });

    testWidgets('Search functionality works', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to search/history tab
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Find search field and enter text
      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      await tester.enterText(searchField, 'test search');
      await tester.pumpAndSettle();

      // Verify search results area is shown
      expect(find.text('Resultados:'), findsOneWidget);
    });

    testWidgets('Voice recording interface shows', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Find and tap microphone button
      final micButton = find.byIcon(Icons.mic);
      expect(micButton, findsWidgets);

      await tester.tap(micButton.first);
      await tester.pumpAndSettle();

      // Verify voice recording interface appears
      // Note: Actual recording may not work in test environment
      expect(find.byType(FloatingActionButton), findsWidgets);
    });

    testWidgets('App handles empty state gracefully', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to history when no entries exist
      await tester.tap(find.byIcon(Icons.history));
      await tester.pumpAndSettle();

      // Verify empty state is handled
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('App navigation persistence works', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to different tab
      await tester.tap(find.byIcon(Icons.history));
      await tester.pumpAndSettle();

      // Simulate app being recreated (like orientation change)
      await tester.restartAndRestore();
      await tester.pumpAndSettle();

      // App should still function normally
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('Error states are handled properly', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // The app should not crash on startup and should handle
      // any potential permission or initialization errors gracefully
      
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Accessibility features work', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to settings
      await tester.tap(find.byIcon(Icons.settings).first);
      await tester.pumpAndSettle();

      // Find accessibility section
      expect(find.text('Accesibilidad'), findsOneWidget);

      // Test font size adjustment
      final fontSizeSlider = find.byType(Slider);
      if (fontSizeSlider.evaluate().isNotEmpty) {
        await tester.tap(fontSizeSlider);
        await tester.pumpAndSettle();
      }

      // Test high contrast toggle
      final highContrastSwitch = find.text('Alto contraste');
      if (highContrastSwitch.evaluate().isNotEmpty) {
        await tester.tap(highContrastSwitch);
        await tester.pumpAndSettle();
      }
    });
  });
}
