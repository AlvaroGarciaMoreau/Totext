class AppConfig {
  // Firebase Configuration
  static const String firebaseApiKey = 'your-firebase-api-key';
  static const String firebaseAppId = 'your-firebase-app-id';
  static const String firebaseProjectId = 'your-firebase-project-id';
  static const String firebaseStorageBucket = 'your-firebase-storage-bucket';
  
  // Translation API Configuration
  static const String translationApiKey = 'your-translation-api-key';
  
  // OCR Languages supported
  static const List<String> supportedOcrLanguages = [
    'es', // Spanish
    'en', // English
    'fr', // French
    'de', // German
    'it', // Italian
    'pt', // Portuguese
    'ru', // Russian
    'zh', // Chinese
    'ja', // Japanese
    'ko', // Korean
    'ar', // Arabic
    'hi', // Hindi
  ];
  
  // Translation Languages
  static const Map<String, String> translationLanguages = {
    'es': 'Español',
    'en': 'English',
    'fr': 'Français',
    'de': 'Deutsch',
    'it': 'Italiano',
    'pt': 'Português',
    'ru': 'Русский',
    'zh': '中文',
    'ja': '日本語',
    'ko': '한국어',
    'ar': 'العربية',
    'hi': 'हिन्दी',
  };
  
  // Voice Commands Configuration
  static const Map<String, List<String>> voiceCommands = {
    'camera': ['abrir cámara', 'tomar foto', 'open camera', 'take photo'],
    'gallery': ['abrir galería', 'seleccionar imagen', 'open gallery', 'select image'],
    'speech': ['escuchar', 'grabar voz', 'listen', 'record voice'],
    'history': ['mostrar historial', 'ver historial', 'show history', 'view history'],
    'export': ['exportar', 'guardar', 'export', 'save'],
    'translate': ['traducir', 'translate'],
    'search': ['buscar', 'search'],
  };
  
  // Categories for text classification
  static const List<String> textCategories = [
    'Documento',
    'Recibo',
    'Tarjeta de Visita',
    'Texto Manuscrito',
    'Menú',
    'Señal',
    'Libro',
    'Artículo',
    'Nota',
    'Otro',
  ];
  
  // Export formats
  static const List<String> exportFormats = [
    'TXT',
    'JSON',
    'PDF',
  ];
  
  // Batch processing limits
  static const int maxBatchImages = 10;
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  
  // Compression settings
  static const int imageCompressionQuality = 85;
  static const int maxImageDimension = 1920;
  
  // Database configuration
  static const String databaseName = 'totext_database.db';
  static const int databaseVersion = 1;
  
  // Theme configuration
  static const String themePreferenceKey = 'theme_mode';
  static const String languagePreferenceKey = 'app_language';
  static const String ocrLanguagePreferenceKey = 'ocr_language';
  static const String categoryPreferenceKey = 'default_category';
  
  // Cloud sync configuration
  static const String lastSyncKey = 'last_sync_timestamp';
  static const String autoSyncKey = 'auto_sync_enabled';
  static const Duration syncInterval = Duration(minutes: 30);
  
  // Accessibility settings
  static const double minFontSize = 12.0;
  static const double maxFontSize = 24.0;
  static const double defaultFontSize = 16.0;
  
  // Animation durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 400);
  static const Duration longAnimationDuration = Duration(milliseconds: 600);
}
