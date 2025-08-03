import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/theme_preferences.dart';
import '../config/app_config.dart';

class ThemeProvider extends ChangeNotifier {
  ThemePreferences _preferences = ThemePreferences();
  late SharedPreferences _prefs;
  bool _isInitialized = false;

  ThemePreferences get preferences => _preferences;
  bool get isInitialized => _isInitialized;

  ThemeMode get themeMode {
    switch (_preferences.themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _prefs = await SharedPreferences.getInstance();
    await _loadPreferences();
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _loadPreferences() async {
    try {
      String? prefsJson = _prefs.getString('theme_preferences');
      if (prefsJson != null) {
        Map<String, dynamic> prefsMap = {};
        // En una implementación real, parsearías el JSON aquí
        // prefsMap = json.decode(prefsJson);
        _preferences = ThemePreferences.fromJson(prefsMap);
      }
    } catch (e) {
      // Error loading theme preferences: $e
      _preferences = ThemePreferences(); // Usar valores por defecto
    }
  }

  Future<void> _savePreferences() async {
    try {
      // En una implementación real, convertirías a JSON aquí
      // String prefsJson = json.encode(_preferences.toJson());
      // await _prefs.setString('theme_preferences', prefsJson);
      
      // Por ahora, guardamos las preferencias individuales
      await _prefs.setInt('theme_mode', _preferences.themeMode.index);
      await _prefs.setString('language', _preferences.language);
      await _prefs.setString('ocr_language', _preferences.ocrLanguage);
      await _prefs.setDouble('font_size', _preferences.fontSize);
      await _prefs.setBool('high_contrast', _preferences.highContrast);
      await _prefs.setBool('reduced_animations', _preferences.reducedAnimations);
      await _prefs.setBool('auto_sync_enabled', _preferences.autoSyncEnabled);
      await _prefs.setString('default_category', _preferences.defaultCategory);
    } catch (e) {
      // Error saving theme preferences: $e
    }
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    _preferences = _preferences.copyWith(themeMode: mode);
    await _savePreferences();
    notifyListeners();
  }

  Future<void> setLanguage(String language) async {
    _preferences = _preferences.copyWith(language: language);
    await _savePreferences();
    notifyListeners();
  }

  Future<void> setOcrLanguage(String language) async {
    _preferences = _preferences.copyWith(ocrLanguage: language);
    await _savePreferences();
    notifyListeners();
  }

  Future<void> setFontSize(double fontSize) async {
    fontSize = fontSize.clamp(AppConfig.minFontSize, AppConfig.maxFontSize);
    _preferences = _preferences.copyWith(fontSize: fontSize);
    await _savePreferences();
    notifyListeners();
  }

  Future<void> setHighContrast(bool enabled) async {
    _preferences = _preferences.copyWith(highContrast: enabled);
    await _savePreferences();
    notifyListeners();
  }

  Future<void> setReducedAnimations(bool enabled) async {
    _preferences = _preferences.copyWith(reducedAnimations: enabled);
    await _savePreferences();
    notifyListeners();
  }

  Future<void> setAutoSyncEnabled(bool enabled) async {
    _preferences = _preferences.copyWith(autoSyncEnabled: enabled);
    await _savePreferences();
    notifyListeners();
  }

  Future<void> setDefaultCategory(String category) async {
    _preferences = _preferences.copyWith(defaultCategory: category);
    await _savePreferences();
    notifyListeners();
  }

  Future<void> resetToDefaults() async {
    _preferences = ThemePreferences();
    await _savePreferences();
    notifyListeners();
  }

  // Getters for theme data
  ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: _preferences.highContrast
          ? _highContrastLightColorScheme
          : ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.light,
            ),
      textTheme: _getTextTheme(Brightness.light),
      appBarTheme: AppBarTheme(
        backgroundColor: _preferences.highContrast ? Colors.white : null,
        foregroundColor: _preferences.highContrast ? Colors.black : null,
      ),
    );
  }

  ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: _preferences.highContrast
          ? _highContrastDarkColorScheme
          : ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.dark,
            ),
      textTheme: _getTextTheme(Brightness.dark),
      appBarTheme: AppBarTheme(
        backgroundColor: _preferences.highContrast ? Colors.black : null,
        foregroundColor: _preferences.highContrast ? Colors.white : null,
      ),
    );
  }

  TextTheme _getTextTheme(Brightness brightness) {
    return ThemeData(brightness: brightness).textTheme.copyWith(
      bodyLarge: TextStyle(fontSize: _preferences.fontSize),
      bodyMedium: TextStyle(fontSize: _preferences.fontSize - 2),
      bodySmall: TextStyle(fontSize: _preferences.fontSize - 4),
      headlineLarge: TextStyle(fontSize: _preferences.fontSize + 16),
      headlineMedium: TextStyle(fontSize: _preferences.fontSize + 12),
      headlineSmall: TextStyle(fontSize: _preferences.fontSize + 8),
      titleLarge: TextStyle(fontSize: _preferences.fontSize + 6),
      titleMedium: TextStyle(fontSize: _preferences.fontSize + 4),
      titleSmall: TextStyle(fontSize: _preferences.fontSize + 2),
    );
  }

  ColorScheme get _highContrastLightColorScheme {
    return const ColorScheme.light(
      primary: Colors.black,
      onPrimary: Colors.white,
      secondary: Colors.black,
      onSecondary: Colors.white,
      surface: Colors.white,
      onSurface: Colors.black,
      error: Colors.red,
      onError: Colors.white,
    );
  }

  ColorScheme get _highContrastDarkColorScheme {
    return const ColorScheme.dark(
      primary: Colors.white,
      onPrimary: Colors.black,
      secondary: Colors.white,
      onSecondary: Colors.black,
      surface: Colors.black,
      onSurface: Colors.white,
      error: Colors.red,
      onError: Colors.white,
    );
  }

  Duration get animationDuration {
    if (_preferences.reducedAnimations) {
      return const Duration(milliseconds: 100);
    }
    return AppConfig.mediumAnimationDuration;
  }

  Duration get shortAnimationDuration {
    if (_preferences.reducedAnimations) {
      return const Duration(milliseconds: 50);
    }
    return AppConfig.shortAnimationDuration;
  }

  Duration get longAnimationDuration {
    if (_preferences.reducedAnimations) {
      return const Duration(milliseconds: 200);
    }
    return AppConfig.longAnimationDuration;
  }
}
