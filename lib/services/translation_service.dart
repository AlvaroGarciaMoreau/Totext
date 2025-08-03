import 'package:translator/translator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/app_config.dart';

class TranslationService {
  static final GoogleTranslator _translator = GoogleTranslator();
  static final Map<String, String> _cache = {};

  static Future<String?> translateText(
    String text,
    String targetLanguage, {
    String? sourceLanguage,
  }) async {
    if (text.isEmpty) return null;

    // Verificar caché
    String cacheKey = '${sourceLanguage ?? 'auto'}_${targetLanguage}_${text.hashCode}';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey];
    }

    try {
      Translation translation;
      
      if (sourceLanguage != null) {
        translation = await _translator.translate(
          text,
          from: sourceLanguage,
          to: targetLanguage,
        );
      } else {
        translation = await _translator.translate(
          text,
          to: targetLanguage,
        );
      }

      String translatedText = translation.text;
      
      // Guardar en caché
      _cache[cacheKey] = translatedText;
      
      // Limitar tamaño del caché
      if (_cache.length > 100) {
        _cache.clear();
      }

      return translatedText;
    } catch (e) {
      // Error translating text: $e
      return null;
    }
  }

  static Future<String?> detectLanguage(String text) async {
    if (text.isEmpty) return null;

    try {
      // Usar la API de detección de idioma de Google Translate
      const String baseUrl = 'https://translation.googleapis.com/language/translate/v2/detect';
      final String url = '$baseUrl?key=${AppConfig.translationApiKey}';

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'q': text,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final detections = data['data']['detections'][0];
        if (detections.isNotEmpty) {
          return detections[0]['language'];
        }
      }
    } catch (e) {
      // Error detecting language: $e
    }

    // Fallback: usar el detector local simple
    return _detectLanguageLocal(text);
  }

  static String? _detectLanguageLocal(String text) {
    // Detector simple basado en patrones de caracteres
    if (RegExp(r'[一-龯]').hasMatch(text)) return 'zh';
    if (RegExp(r'[ひらがなカタカナ]').hasMatch(text)) return 'ja';
    if (RegExp(r'[ㄱ-ㅣ가-힣]').hasMatch(text)) return 'ko';
    if (RegExp(r'[а-яё]', caseSensitive: false).hasMatch(text)) return 'ru';
    if (RegExp(r'[أ-ي]').hasMatch(text)) return 'ar';
    if (RegExp(r'[ñáéíóúü]', caseSensitive: false).hasMatch(text)) return 'es';
    if (RegExp(r'[àâäéèêëïîôöùûüÿç]', caseSensitive: false).hasMatch(text)) return 'fr';
    if (RegExp(r'[äöüß]', caseSensitive: false).hasMatch(text)) return 'de';
    if (RegExp(r'[àáâãçéêíóôõú]', caseSensitive: false).hasMatch(text)) return 'pt';
    if (RegExp(r'[àèìòù]', caseSensitive: false).hasMatch(text)) return 'it';
    
    return 'en'; // Fallback to English
  }

  static Future<List<String>> translateBatch(
    List<String> texts,
    String targetLanguage, {
    String? sourceLanguage,
    Function(int, int)? onProgress,
  }) async {
    List<String> results = [];
    
    for (int i = 0; i < texts.length; i++) {
      try {
        String? translated = await translateText(
          texts[i],
          targetLanguage,
          sourceLanguage: sourceLanguage,
        );
        results.add(translated ?? texts[i]);
        onProgress?.call(i + 1, texts.length);
      } catch (e) {
        results.add(texts[i]); // Return original if translation fails
        onProgress?.call(i + 1, texts.length);
      }
    }
    
    return results;
  }

  static Map<String, String> getSupportedLanguages() {
    return AppConfig.translationLanguages;
  }

  static void clearCache() {
    _cache.clear();
  }

  static bool isLanguageSupported(String languageCode) {
    return AppConfig.translationLanguages.containsKey(languageCode);
  }

  static String getLanguageName(String languageCode) {
    return AppConfig.translationLanguages[languageCode] ?? languageCode;
  }
}
