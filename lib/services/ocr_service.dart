import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../constants/app_constants.dart';
import '../config/app_config.dart';

class OcrService {
  static TextRecognizer? _textRecognizer;
  static String _currentLanguage = 'es';

  static TextRecognizer _getRecognizer(String languageCode) {
    TextRecognitionScript script;
    
    switch (languageCode) {
      case 'zh':
        script = TextRecognitionScript.chinese;
        break;
      case 'ja':
        script = TextRecognitionScript.japanese;
        break;
      case 'ko':
        script = TextRecognitionScript.korean;
        break;
      default:
        script = TextRecognitionScript.latin;
    }
    
    return TextRecognizer(script: script);
  }

  static Future<void> setLanguage(String languageCode) async {
    if (_currentLanguage != languageCode) {
      _textRecognizer?.close();
      _textRecognizer = _getRecognizer(languageCode);
      _currentLanguage = languageCode;
    }
  }

  static Future<Map<String, dynamic>> extractTextFromImage(
    File imageFile, {
    String? languageCode,
    bool detectHandwriting = false,
  }) async {
    try {
      final lang = languageCode ?? _currentLanguage;
      await setLanguage(lang);
      
      _textRecognizer ??= _getRecognizer(lang);
      
      final inputImage = InputImage.fromFile(imageFile);
      final RecognizedText recognizedText = await _textRecognizer!.processImage(inputImage);
      
      String extractedText = recognizedText.text;
      
      // Calcular confianza promedio
      double totalConfidence = 0;
      int blockCount = 0;
      
      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          // Nota: ML Kit no proporciona confianza directamente
          // Esto es una estimación basada en la longitud del texto
          totalConfidence += _estimateConfidence(line.text);
          blockCount++;
        }
      }
      
      double averageConfidence = blockCount > 0 ? totalConfidence / blockCount : 0.0;
      
      // Detectar si es texto manuscrito (heurística simple)
      bool isHandwritten = detectHandwriting ? _detectHandwriting(recognizedText) : false;
      
      return {
        'text': extractedText.isNotEmpty ? extractedText : AppConstants.statusNoTextFound,
        'confidence': averageConfidence,
        'language': lang,
        'isHandwritten': isHandwritten,
        'blocks': recognizedText.blocks.length,
      };
    } catch (e) {
      throw Exception('${AppConstants.errorProcessImage}: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> extractTextFromImages(
    List<File> imageFiles, {
    String? languageCode,
    bool detectHandwriting = false,
    Function(int, int)? onProgress,
  }) async {
    List<Map<String, dynamic>> results = [];
    
    for (int i = 0; i < imageFiles.length; i++) {
      try {
        final result = await extractTextFromImage(
          imageFiles[i],
          languageCode: languageCode,
          detectHandwriting: detectHandwriting,
        );
        
        results.add({
          'file': imageFiles[i].path,
          'index': i,
          'success': true,
          'result': result,
        });
        
        onProgress?.call(i + 1, imageFiles.length);
      } catch (e) {
        results.add({
          'file': imageFiles[i].path,
          'index': i,
          'success': false,
          'error': e.toString(),
        });
        
        onProgress?.call(i + 1, imageFiles.length);
      }
    }
    
    return results;
  }

  static double _estimateConfidence(String text) {
    // Heurística simple para estimar confianza
    // Basada en la presencia de caracteres especiales y longitud
    if (text.isEmpty) return 0.0;
    
    int specialChars = text.split('').where((char) => 
      !RegExp(r'[a-zA-Z0-9\s]').hasMatch(char)).length;
    
    double specialCharRatio = specialChars / text.length;
    double lengthScore = text.length > 3 ? 1.0 : text.length / 3.0;
    
    return (1.0 - specialCharRatio) * lengthScore * 100;
  }

  static bool _detectHandwriting(RecognizedText recognizedText) {
    // Heurística simple para detectar texto manuscrito
    // Basada en la irregularidad de las líneas y bloques
    
    if (recognizedText.blocks.isEmpty) return false;
    
    int totalLines = 0;
    int irregularLines = 0;
    
    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        totalLines++;
        
        // Considerar línea irregular si tiene pocos elementos o ángulo inusual
        if (line.elements.length < 3) {
          irregularLines++;
        }
      }
    }
    
    return totalLines > 0 && (irregularLines / totalLines) > 0.3;
  }

  static List<String> getSupportedLanguages() {
    return AppConfig.supportedOcrLanguages;
  }

  static String getCurrentLanguage() {
    return _currentLanguage;
  }

  static void dispose() {
    _textRecognizer?.close();
    _textRecognizer = null;
  }
}
