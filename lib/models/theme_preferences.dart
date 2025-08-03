enum AppThemeMode {
  light,
  dark,
  system,
}

class ThemePreferences {
  final AppThemeMode themeMode;
  final String language;
  final String ocrLanguage;
  final double fontSize;
  final bool highContrast;
  final bool reducedAnimations;
  final bool autoSyncEnabled;
  final String defaultCategory;

  ThemePreferences({
    this.themeMode = AppThemeMode.system,
    this.language = 'es',
    this.ocrLanguage = 'es',
    this.fontSize = 16.0,
    this.highContrast = false,
    this.reducedAnimations = false,
    this.autoSyncEnabled = true,
    this.defaultCategory = 'Otro',
  });

  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode.index,
      'language': language,
      'ocrLanguage': ocrLanguage,
      'fontSize': fontSize,
      'highContrast': highContrast,
      'reducedAnimations': reducedAnimations,
      'autoSyncEnabled': autoSyncEnabled,
      'defaultCategory': defaultCategory,
    };
  }

  factory ThemePreferences.fromJson(Map<String, dynamic> json) {
    return ThemePreferences(
      themeMode: AppThemeMode.values[json['themeMode'] ?? 0],
      language: json['language'] ?? 'es',
      ocrLanguage: json['ocrLanguage'] ?? 'es',
      fontSize: json['fontSize']?.toDouble() ?? 16.0,
      highContrast: json['highContrast'] ?? false,
      reducedAnimations: json['reducedAnimations'] ?? false,
      autoSyncEnabled: json['autoSyncEnabled'] ?? true,
      defaultCategory: json['defaultCategory'] ?? 'Otro',
    );
  }

  ThemePreferences copyWith({
    AppThemeMode? themeMode,
    String? language,
    String? ocrLanguage,
    double? fontSize,
    bool? highContrast,
    bool? reducedAnimations,
    bool? autoSyncEnabled,
    String? defaultCategory,
  }) {
    return ThemePreferences(
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      ocrLanguage: ocrLanguage ?? this.ocrLanguage,
      fontSize: fontSize ?? this.fontSize,
      highContrast: highContrast ?? this.highContrast,
      reducedAnimations: reducedAnimations ?? this.reducedAnimations,
      autoSyncEnabled: autoSyncEnabled ?? this.autoSyncEnabled,
      defaultCategory: defaultCategory ?? this.defaultCategory,
    );
  }
}
