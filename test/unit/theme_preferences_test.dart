import 'package:flutter_test/flutter_test.dart';
import 'package:totext/models/theme_preferences.dart';

void main() {
  group('ThemePreferences Model Tests', () {
    test('should create with default values', () {
      final prefs = ThemePreferences();

      expect(prefs.themeMode, AppThemeMode.system);
      expect(prefs.language, 'es');
      expect(prefs.ocrLanguage, 'es');
      expect(prefs.fontSize, 16.0);
      expect(prefs.highContrast, false);
      expect(prefs.reducedAnimations, false);
      expect(prefs.autoSyncEnabled, true);
      expect(prefs.defaultCategory, 'Otro');
    });

    test('should create with custom values', () {
      final prefs = ThemePreferences(
        themeMode: AppThemeMode.dark,
        language: 'en',
        ocrLanguage: 'fr',
        fontSize: 18.0,
        highContrast: true,
        reducedAnimations: true,
        autoSyncEnabled: false,
        defaultCategory: 'Documento',
      );

      expect(prefs.themeMode, AppThemeMode.dark);
      expect(prefs.language, 'en');
      expect(prefs.ocrLanguage, 'fr');
      expect(prefs.fontSize, 18.0);
      expect(prefs.highContrast, true);
      expect(prefs.reducedAnimations, true);
      expect(prefs.autoSyncEnabled, false);
      expect(prefs.defaultCategory, 'Documento');
    });

    test('should convert to JSON correctly', () {
      final prefs = ThemePreferences(
        themeMode: AppThemeMode.light,
        language: 'en',
        fontSize: 20.0,
        highContrast: true,
      );

      final json = prefs.toJson();

      expect(json['themeMode'], 0); // AppThemeMode.light.index
      expect(json['language'], 'en');
      expect(json['fontSize'], 20.0);
      expect(json['highContrast'], true);
    });

    test('should create from JSON correctly', () {
      final json = {
        'themeMode': 1, // AppThemeMode.dark.index
        'language': 'fr',
        'ocrLanguage': 'de',
        'fontSize': 14.0,
        'highContrast': false,
        'reducedAnimations': true,
        'autoSyncEnabled': false,
        'defaultCategory': 'Recibo',
      };

      final prefs = ThemePreferences.fromJson(json);

      expect(prefs.themeMode, AppThemeMode.dark);
      expect(prefs.language, 'fr');
      expect(prefs.ocrLanguage, 'de');
      expect(prefs.fontSize, 14.0);
      expect(prefs.highContrast, false);
      expect(prefs.reducedAnimations, true);
      expect(prefs.autoSyncEnabled, false);
      expect(prefs.defaultCategory, 'Recibo');
    });

    test('should handle copyWith correctly', () {
      final originalPrefs = ThemePreferences(
        themeMode: AppThemeMode.system,
        language: 'es',
        fontSize: 16.0,
      );

      final copiedPrefs = originalPrefs.copyWith(
        themeMode: AppThemeMode.dark,
        fontSize: 18.0,
      );

      expect(copiedPrefs.themeMode, AppThemeMode.dark); // changed
      expect(copiedPrefs.language, 'es'); // unchanged
      expect(copiedPrefs.fontSize, 18.0); // changed
      expect(copiedPrefs.ocrLanguage, 'es'); // unchanged (original default)
    });

    test('should handle missing JSON properties with defaults', () {
      final json = {
        'themeMode': 2, // AppThemeMode.system.index
        'language': 'it',
        // missing other properties
      };

      final prefs = ThemePreferences.fromJson(json);

      expect(prefs.themeMode, AppThemeMode.system);
      expect(prefs.language, 'it');
      expect(prefs.ocrLanguage, 'es'); // default
      expect(prefs.fontSize, 16.0); // default
      expect(prefs.highContrast, false); // default
      expect(prefs.reducedAnimations, false); // default
      expect(prefs.autoSyncEnabled, true); // default
      expect(prefs.defaultCategory, 'Otro'); // default
    });

    test('should handle invalid theme mode index', () {
      final json = {
        'themeMode': 99, // invalid index
      };

      expect(() => ThemePreferences.fromJson(json), throwsRangeError);
    });

    test('should preserve all properties in copyWith when no changes', () {
      final originalPrefs = ThemePreferences(
        themeMode: AppThemeMode.light,
        language: 'de',
        ocrLanguage: 'en',
        fontSize: 20.0,
        highContrast: true,
        reducedAnimations: true,
        autoSyncEnabled: false,
        defaultCategory: 'Documento',
      );

      final copiedPrefs = originalPrefs.copyWith();

      expect(copiedPrefs.themeMode, originalPrefs.themeMode);
      expect(copiedPrefs.language, originalPrefs.language);
      expect(copiedPrefs.ocrLanguage, originalPrefs.ocrLanguage);
      expect(copiedPrefs.fontSize, originalPrefs.fontSize);
      expect(copiedPrefs.highContrast, originalPrefs.highContrast);
      expect(copiedPrefs.reducedAnimations, originalPrefs.reducedAnimations);
      expect(copiedPrefs.autoSyncEnabled, originalPrefs.autoSyncEnabled);
      expect(copiedPrefs.defaultCategory, originalPrefs.defaultCategory);
    });
  });

  group('AppThemeMode Enum Tests', () {
    test('should have correct enum values', () {
      expect(AppThemeMode.light.index, 0);
      expect(AppThemeMode.dark.index, 1);
      expect(AppThemeMode.system.index, 2);
    });

    test('should have correct number of values', () {
      expect(AppThemeMode.values.length, 3);
    });
  });
}
